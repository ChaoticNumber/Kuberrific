As with any learning experience, I keep being reminded, that documentation is key. As the mythbusters used to say, its not really science, until you write it down. 

I'll simply start here and format this as I go. 
I am on day 3 of this current kubernetes learning sprint and I feel like this time i need to write it all down, as it seems to be the most comprehensive sprint so far. 

Each and every one of us has different learning styles, mine is hands on, breaking things, fixing things, checking documentation, forums and so on. It is by far my fastest way to absorb information, by doing.


    Day 0 (?)


I was trying to put together a monitoring solution for my testing cluster and I hit quite a few roadblocks because my lack of knowledge on how things work on a more basic level. I was using tools such as rancher-desktop, microk8s, kubeadm and so on, they were great for spinning up a quick dev-env, but they did nothing but keep me in ignoranceville and expand my landscape knowledge a bit. Great tools, I'll come back to them once I know more. They are however the trigger to my frustrations, the fact that I have large, gaping holes in my containerization knoledge. So I completely nuked my dev-env and I am embarking on a journey of discovery, by setting up a kubernetes cluster completely manually.
I spent a few hours checking the prerequisites, dos and dont's (mostly dont's). Every tutorial and guide warn people to stay away, here be dragons. 


    Day 1


As with any topic that I enjoy, I find myself doing deep dives, here it is no different so I decided to start with the basics, the very very basic part of how kubernetes clusters function. 
That is to say, that it is a journey of discovery and I have no clue if it is the right approach, but at least it is the path of most resistance, starting with the basics, so I will eventually have to pass through most topics.

So what have I learned on day1 ? 
I really wish I would have written this down earlier because I really don't have a photographic memory, better late than never.

I had trouble understanding how the control plane and the data plane interact, how does a pod come to exist, what does it run on, what orchestrates the whole process, what are the configs, jsons and yamls that put everything together.
I find it funny that my "k8 lingo" is progressing as I learn and I'm sure this will be hilarious for me to read once I gather some more knowledge than I already have.

So on the topic of how, I needed an overview to start asking more pertinent questions so I settled on this one I found with a google search:

--Insert k8 cluster overview here--

I realize now (this is written on day 3) that it may not be 100% accurate, but it serves the purpose.

One way I wrap my head around how things work is to understand what happens, step by step. For example when I switched from windows to linux as my daily driver, the first thing I wanted to know is how does it boot.
It may seem simple enough to most people in the tech field, but I didn't have a clue. So I dug trough forums, documentation to find out. That basically bios calls the bootloader (grub for example), the bootloader reads the config file to determine the kernel that needs loading from /boot/vmlinuz, then initramfs in boot/initrd and so on trough init, services and startx.

That being said, the above process took me a couple of days of installing and destroying linux distros until I figured out what goes were. 

So how does kubernetes work on the most basic of levels? 

The first part has to do with the control plane, the master nodes. The same way I learned about linux, I started with the boot process, the files that make up a control plane and the boot order. 

    - etcd, as its the datastore, it starts first. It is deployed as a service, its executable usually found in /usr/local/bin and the datastore usually found in /var/lib/etcd, this is set by the data-dir config param.
    - the API server is next, because it is the primary management interface for the cluster and most components communicate trough it
    - controller manager follows as it is dependant on etcd and the API server to function, it holds the replicaset controller, deployment controller, stateful set controller, job and cronjob controllers and a few others.
    - lastly the scheduler starts (but usually at the same time as controller manager), also because it relies on the API server and etcd to function, it is responsible for the scheduline of workloads onto worker nodes

During the last part of day 1 I read about qemu and how it operates, created a script to automate my machines creation. This was a surprisingly useful excercise because I found out about cloud-init, completely by chance. I was doing some digging into how can the vm creation process be automated and I came across quite a few scripts that always seemed to pass some values into the image creation process. Then I realized that k8 control planes require very very little to operate, so values such as ssh keys or no-vid, network settings and so on are simply passed into the built image via either a config or a script. 

Its amazing stuff if you think about the level of automation that can be achieved here, then again this is the whole point of creating a k8s cluster from scratch. I now understand a bit better how tools like kubeadm or microk8s function. 


    Day 2


Here is where I started to attempt some image building with varying levels of (in)success. I also tried to hone the VM creation script by adding more things into it, like error handling, the image conversion process that was an external script before, called from within the main script and so on. 

Destroyed quite a few deployments attempting to piece together the k8 control plane, without success. 
It was mostly a day of troubleshooting, libvirt wasted quite a bit of my time, as I had to find the right repo to install it from. These are the headaches of not using a debian-derived linux as the development platform. It seems that ubuntu server is most suited for kubernetes setups, because canonical is pushing hard on this front. It is also the reason I settled on the ubuntu server cloud image as the os that will host the worker nodes and the control plane. 


    Day 3


I slowed down the learning process for day 3, I realized that I am not documenting anything, it would be a shame not to be able to retrace my steps. I spent most of my time documenting what I have learned in the previous days and cleaning up the environment because I already had a home folder that was filled with yamls, countelss bash scripts and images that were used to test things like the image conversion to qcow2 for qemu and so on. So now everything more or less looks better and  bit more organized. 

I am spending the last part of the day reading up on worker node details such as what components it has, where do they run, how do they interact with container runtimes, what CRIs can I use, how should I use them. For example, I never used CRI-O before and it seems the people are recomending it for certain clusters that run a bit lighter. I also didn't know you can mix CRIs together, as docker does with containerd, using it as its default runtime and leveraging its benefits. 


    Day 4 

On this day the main focus is to simply troubleshoot the qemu script, to make sure its properly polished, so I don't have to spend too much time worrying about every issue. 
The first thing that came to mind was being able to pass cloud-init variables into the image, this was added to the script by adding the variable and defining a condition if we are running the script with or without a cloud-init file.
Second thing, more of an annoyance than anything else, added checking for existing files and appending the name so the script does not hang every time there is an existing file. In the future, adding the functionality of the VM cleaning up after itself would probably be better. [ TODO ]
