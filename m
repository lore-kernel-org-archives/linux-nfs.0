From: Dean Hildebrand <seattleplus@gmail.com>
Subject: Re: [PATCH 0/1] SUNRPC: Add sysctl variables for server TCP snd/rcv
 buffer values
Date: Tue, 17 Jun 2008 15:03:39 -0700
Message-ID: <485834BB.8010207@gmail.com>
References: <484ECDE4.6030108@gmail.com> <7F44A14A-F811-4D41-BAFF-E019E9904B6A@oracle.com> <48518F18.2010703@gmail.com> <C04F3083-91B2-464B-8F5C-958B243EB46C@oracle.com> <485319DA.9040706@gmail.com> <E2085423-A587-403E-833D-BBAC5C96CB64@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.175]:1381 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760273AbYFQWDq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2008 18:03:46 -0400
Received: by wf-out-1314.google.com with SMTP id 27so5925653wfd.4
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jun 2008 15:03:43 -0700 (PDT)
In-Reply-To: <E2085423-A587-403E-833D-BBAC5C96CB64@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here is my view of the situation:

We have a full picture of TCP.  TCP is well known, there are lots of 
papers/info on it, I have no doubt on what is occurring with TCP as I 
have traces that clearly show what is happening.  All documents and 
information clearly state that the buffer size is a critical part of 
improving TCP performance in the WAN.  In addition, the congestion 
control algorithm does NOT control the maximum size of the TCP window.  
The CCA controls how quickly the window reaches the maximum size, what 
happens when a packet is dropped and when to close the window.  The only 
item that controls the maximum size of the TCP window is the buffer 
values that I want a sysctl to tweak (just to be in line with the 
existing tcp buffer sysctls in Documentation/networking/ip-sysctl.txt)

What we don't have is a full picture of the other parts of transferring 
data from client to server, e.g., Trond just fixed a bug with regards to 
the writeback cache which should help write performance, that was an 
unknown up until this point.

Multiple TCP Streams
===============
There is a really big downside to multiple TCP streams: you have 
multiple TCP streams :)  Each one has its own overhead, setup connection 
cost, and of course  TCP window.  With a WAN rtt  of 200 ms (typical 
over satellite) and the current buffer size of 4MB, the nfs client would 
need 50+ TCP connections to achieve the correct performance.  That is a 
lot of overhead when comparing it with simply following the standard TCP 
tuning knowhow of increasing the buffer sizes. 

The main documentation the show that multiple tcp streams helps over the 
WAN is from GridFTP experiments.  They go over the pos and neg of the 
approach, but also talk about how tcp buffer size is also very 
important.  Multiple tcp streams is not a replacement for a proper 
buffer size 
(http://www.globus.org/alliance/publications/clusterworld/0904GridFinal.pdf)

If you have documentation counteracting these experiments I would be 
very interested to see them.

One Variable or Two
===============
I'd be happy with using a single variable for both the send and receive 
buffers, but since we are essentially doing the same thing as the 
net.ipv4.tcp_wmem/rmem variables, I think nfsd_tcp_max_mem would be more 
in line with existing Linux terminology. (also, we are talking about 
nfsd, not nfs, so I'd prefer to make that clear in the variable name)

Summary
=======
I'm providing you with all the information I have with regards to my 
experiments with NFS and TCP.  I agree that a better default is needed 
and my patch allows further experimentation to get to that value.    My 
patch does not add modify current NFS behaviour.  It changes a hard 
coded value for the server buffer size to be a variable in /proc.  
Blocking a method to modify this hard coded value means blocking further 
experimentation to find a better default value.  My patch is a first 
step toward trying to find a good default tcp server buffer value.

Dean




>
> Since what we really want to limit is the maximum size of the TCP 
> receive window, it would be more precise to change the name of the new 
> sysctl to something like nfs_tcp_max_window_size.

>
>>>> Another point is that setting the buffer size isn't always a 
>>>> straightforward process. All papers I've read on the subject, and 
>>>> my experience confirms this, is that setting tcp buffer sizes is 
>>>> more of an art.
>>>>
>>>> So having the server set a good default value is half the battle, 
>>>> but allowing users to twiddle with this value is vital.
>>>
>>>>>> The uses the current buffer sizes in the code are as minimum 
>>>>>> values, which the user cannot decrease. If the user sets a value 
>>>>>> of 0 in either /proc entry, it resets the buffer size to the 
>>>>>> default value. The set /proc values are utilized when the TCP 
>>>>>> connection is initialized (mount time). The values are bounded 
>>>>>> above by the *minimum* of the /proc values and the network TCP 
>>>>>> sysctls.
>>>>>>
>>>>>> To demonstrate the usefulness of this patch, details of an 
>>>>>> experiment between 2 computers with a rtt of 30ms is provided 
>>>>>> below. In this experiment, increasing the server 
>>>>>> /proc/sys/sunrpc/tcp_rcvbuf value doubles write performance.
>>>>>>
>>>>>> EXPERIMENT
>>>>>> ==========
>>>>>> This experiment simulates a WAN by using tc together with netem 
>>>>>> to add a 30 ms delay to all packets on a nfs client. The goal is 
>>>>>> to show that by only changing tcp_rcvbuf, the nfs client can 
>>>>>> increase write performance in the WAN. To verify the patch has 
>>>>>> the desired effect on the TCP window, I created two tcptrace 
>>>>>> plots that show the difference in tcp window behaviour before and 
>>>>>> after the server TCP rcvbuf size is increased. When using the 
>>>>>> default server tcpbuf value of 6M, we can see the TCP window top 
>>>>>> out around 4.6 M, whereas increasing the server tcpbuf value to 
>>>>>> 32M, we can see that the TCP window tops out around 13M. 
>>>>>> Performance jumps from 43 MB/s to 90 MB/s.
>>>>>>
>>>>>> Hardware:
>>>>>> 2 dual-core opteron blades
>>>>>> GigE, Broadcom NetXtreme II BCM57065 cards
>>>>>> A single gigabit switch in the middle
>>>>>> 1500 MTU
>>>>>> 8 GB memory
>>>>>>
>>>>>> Software:
>>>>>> Kernel: Bruce's 2.6.25-rc9-CITI_NFS4_ALL-1 tree
>>>>>> RHEL4
>>>>>>
>>>>>> NFS Configuration:
>>>>>> 64 rpc slots
>>>>>> 32 nfsds
>>>>>> Export ext3 file system. This disk is quite slow, I therefore 
>>>>>> exported using async to reduce the effect of the disk on the back 
>>>>>> end. This way, the experiments record the time it takes for the 
>>>>>> data to get to the server (not to the disk).
>>>>>> # exportfs -v
>>>>>> /export 
>>>>>> <world>(rw,async,wdelay,nohide,insecure,no_root_squash,fsid=0)
>>>>>>
>>>>>> # cat /proc/mounts
>>>>>> bear109:/export /mnt nfs 
>>>>>> rw,vers=3,rsize=1048576,wsize=1048576,namlen=255,hard,nointr,proto=tcp,timeo=600,retrans=2,sec=sys,mountproto=udp,addr=9.1.74.144 
>>>>>> 0 0
>>>>>>
>>>>>> fs.nfs.nfs_congestion_kb = 91840
>>>>>> net.ipv4.tcp_congestion_control = cubic
>>>>>>
>>>>>> Network tc Command executed on client:
>>>>>> tc qdisc add dev eth0 root netem delay 30ms
>>>>>> rtt from client (bear108) to server (bear109)
>>>>>> #ping bear109
>>>>>> PING bear109.almaden.ibm.com (9.1.74.144) 56(84) bytes of data.
>>>>>> 64 bytes from bear109.almaden.ibm.com (9.1.74.144): icmp_seq=0 
>>>>>> ttl=64 time=31.4 ms
>>>>>> 64 bytes from bear109.almaden.ibm.com (9.1.74.144): icmp_seq=1 
>>>>>> ttl=64 time=32.0 ms
>>>>>>
>>>>>> TCP Configuration on client and server:
>>>>>> # Controls IP packet forwarding
>>>>>> net.ipv4.ip_forward = 0
>>>>>> # Controls source route verification
>>>>>> net.ipv4.conf.default.rp_filter = 1
>>>>>> # Do not accept source routing
>>>>>> net.ipv4.conf.default.accept_source_route = 0
>>>>>> # Controls the System Request debugging functionality of the kernel
>>>>>> kernel.sysrq = 0
>>>>>> # Controls whether core dumps will append the PID to the core 
>>>>>> filename
>>>>>> # Useful for debugging multi-threaded applications
>>>>>> kernel.core_uses_pid = 1
>>>>>> # Controls the use of TCP syncookies
>>>>>> net.ipv4.tcp_syncookies = 1
>>>>>> # Controls the maximum size of a message, in bytes
>>>>>> kernel.msgmnb = 65536
>>>>>> # Controls the default maxmimum size of a mesage queue
>>>>>> kernel.msgmax = 65536
>>>>>> # Controls the maximum shared segment size, in bytes
>>>>>> kernel.shmmax = 68719476736
>>>>>> # Controls the maximum number of shared memory segments, in pages
>>>>>> kernel.shmall = 4294967296
>>>>>> ### IPV4 specific settings
>>>>>> net.ipv4.tcp_timestamps = 0
>>>>>> net.ipv4.tcp_sack = 1
>>>>>> # on systems with a VERY fast bus -> memory interface this is the 
>>>>>> big gainer
>>>>>> net.ipv4.tcp_rmem = 4096 16777216 16777216
>>>>>> net.ipv4.tcp_wmem = 4096 16777216 16777216
>>>>>> net.ipv4.tcp_mem = 4096 16777216 16777216
>>>>>> ### CORE settings (mostly for socket and UDP effect)
>>>>>> net.core.rmem_max = 16777216
>>>>>> net.core.wmem_max = 16777216
>>>>>> net.core.rmem_default = 16777216
>>>>>> net.core.wmem_default = 16777216
>>>>>> net.core.optmem_max = 16777216
>>>>>> net.core.netdev_max_backlog = 300000
>>>>>> # Don't cache ssthresh from previous connection
>>>>>> net.ipv4.tcp_no_metrics_save = 1
>>>>>> # make sure we don't run out of memory
>>>>>> vm.min_free_kbytes = 32768
>>>>>>
>>>>>> Experiments:
>>>>>>
>>>>>> On Server: (note that the real tcp buffer size is double tcp_rcvbuf)
>>>>>> [root@bear109 ~]# echo 0 > /proc/sys/sunrpc/tcp_rcvbuf
>>>>>> [root@bear109 ~]# cat /proc/sys/sunrpc/tcp_rcvbuf
>>>>>> 3158016
>>>>>>
>>>>>> On Client:
>>>>>> mount -t nfs bear109:/export /mnt
>>>>>> [root@bear108 ~]# iozone -aec -i 0 -+n -f /mnt/test -r 1M -s 500M
>>>>>> ...
>>>>>> KB reclen write
>>>>>> 512000 1024 43252 umount /mnt
>>>>>>
>>>>>> On server:
>>>>>> [root@bear109 ~]# echo 16777216 > /proc/sys/sunrpc/tcp_rcvbuf
>>>>>> [root@bear109 ~]# cat /proc/sys/sunrpc/tcp_rcvbuf
>>>>>> 16777216
>>>>>>
>>>>>> On Client:
>>>>>> mount -t nfs bear109:/export /mnt
>>>>>> [root@bear108 ~]# iozone -aec -i 0 -+n -f /mnt/test -r 1M -s 500M
>>>>>> ...
>>>>>> KB reclen write
>>>>>> 512000 1024 90396
>>>>>
>>>>> The numbers you have here are averages over the whole run. 
>>>>> Performing these tests using a variety of record lengths and file 
>>>>> sizes (up to several tens of gigabytes) would be useful to see 
>>>>> where different memory and network latencies kick in.
>>>> Definitely useful, although I'm not sure how this relates to this 
>>>> patch.
>>>
>>> It relates to the whole idea that this is a valid and useful 
>>> parameter to tweak.
>>>
>>> What your experiment shows is that there is some improvement when 
>>> the TCP window is allowed to expand. It does not demonstrate that 
>>> the *best* way to provide this facility is to allow administrators 
>>> to tune the server's TCP buffer sizes.
>> By definition of how TCP is designed, tweaking the send and receive 
>> buffer sizes is a useful. Please see the tcp tuning guides in my 
>> other post. I would characterize tweaking the buffers as a necessary 
>> condition but not a sufficient condition to achieve good throughput 
>> with tcp over long distances.
>>>
>>> A single average number can hide a host of underlying sins. This 
>>> simple experiment, for example, does not demonstrate that TCP window 
>>> size is the most significant issue here.
>> I would say it slightly differently, that it demonstrates that it is 
>> significant, but maybe not the *most* significant. There are many 
>> possible bottlenecks and possible knobs to tweak. For example, I'm 
>> still not achieving link speeds, so I'm sure there are other 
>> bottlenecks that are causing reduced performance.
>
> I think that's my basic point.  We don't have the full picture yet.  
> There are benefits to adjusting the maximum window size, but as we 
> learn more it may turn out that we want an entirely different knob or 
> knobs.

>
>>> It does not show that it is more or less effective to adjust the 
>>> window size than to select an appropriate congestion control 
>>> algorithm (say, BIC).
>> Any tcp cong. control algorithm is highly dependent on the tcp buffer 
>> size. The choice of algorithm changes the behaviour when packets are 
>> dropped and in the initial opening of the window, but once the window 
>> is open and no packets are being dropped, the algorithm is 
>> irrelevant. So BIC, or westwood, or highspeed might do better in the 
>> face of dropped packets, but since the current receive buffer is so 
>> small, dropped packets are not the problem. Once we can use the 
>> sysctl's to tweak the server buffer size, only then is the choice of 
>> algorithm going to be important.
>
> Maybe my use of the terminology is imprecise, but clearly the 
> congestion control algorithm matters for determining the TCP window 
> size, which is exactly what we're discussing here.

>
>>> It does not show whether the client and server are using TCP optimally.
>> I'm not sure what you mean by *optimally*. They use tcp the only way 
>> they know how non?
>
> I'm talking about whether they use Nagle, when they PUSH, how they use 
> the window (servers can close a window when they are busy, for 
> example), and of course whether they can or should use multiple 
> connections.

>
>>> It does not expose problems related to having a single data stream 
>>> with one blocking head (eg SCTP can allow multiple streams over the 
>>> same connection; or better performance might be achieved with 
>>> multiple TCP connections, even if they allow only small windows).
>> Yes, using multiple tcp connections might be useful, but that doesn't 
>> mean you wouldn't want to adjust the tcp window of each one using my 
>> patch. Actually, I can't seem to find the quote, but I read somewhere 
>> that achieving performance in the WAN can be done 2 different ways: 
>> a) If you can tune the buffer sizes that is the best way to go, but 
>> b) if you don't have root access to change the linux tcp settings 
>> then using multiple tcp streams can compensate for small buffer sizes.
>>
>> Andy has/had a patch to add multiple tcp streams to NFS. I think his 
>> patch and my patch work in collaboration to improve wan performance.
>
> Yep, I've discussed this work with him several times.  This might be a 
> more practical solution than allowing larger window sizes (one reason 
> being the dangers of allowing the window to get too large).
>
> While the use of multiple streams has benefits besides increasing the 
> effective TCP window size, only the client side controls the number of 
> connections.  The server wouldn't have much to say about it.

>
>>>> This patch isn't trying to alter default values, or predict buffer 
>>>> sizes based on rtt values, or dynamically alter the tcp window 
>>>> based on dropped packets, etc, it is just giving users the ability 
>>>> to customize the server tcp buffer size.
>>>
>>> I know you posted this patch because of the experiments at CITI with 
>>> long-run 10GbE, and it's handy to now have this to experiment with.
>> Actually at IBM we have our own reasons for using NFS over the WAN. I 
>> would like to get these 2 knobs into the kernel as it is hard to tell 
>> customers to apply kernel patches....
>
>>> It might also be helpful if we had a patch that made the server 
>>> perform better in common environments, so a better default setting 
>>> it seems to me would have greater value than simply creating a new 
>>> tuning knob.
>> I think there are possibly 2 (or more) patches. One that improves the 
>> default buffer sizes and one that lets sysadmins tweak the value. I 
>> don't see why they are mutually exclusive.
>
> They are not.  I'm OK with studying the problem and adjusting the 
> defaults appropriately.
>
> The issue is whether adding this knob is the right approach to 
> adjusting the server.  I don't think we have enough information to 
> understand if this is the most useful approach.  In other words, it 
> seems like a band-aid right now, but in the long run it might be the 
> correct answer.

>
>> My patch is a first step towards allowing NFS into WAN environments. 
>> Linux currently has sysctl values for the TCP parameters for exactly 
>> this reason, it is impossible to predict the network environment of a 
>> linux machine.
>
>> If the Linux nfs server isn't going to build off of the existing 
>> Linux TCP values (which all sysadmins know how to tweak), then it 
>> must allow sysadmins to tweak the NFS server tcp values, either using 
>> my patch or some other related patch. I'm open to how the server tcp 
>> buffers are tweaked, they just need to be able to be tweaked. For 
>> example, if all tcp buffer values in linux were taken out of the 
>> /proc file system and hardcoded, I think there would be a revolt.
>
> I'm not arguing for no tweaking.  What I'm saying is we should provide 
> knobs that are as useful as possible, and include metrics and clear 
> instructions for when and how to set the knob.
>
> You've shown there is improvement, but not that this is the best 
> solution.   It just feels like the work isn't done yet.

>
>>> Would it be hard to add a metric or two with this tweak that would 
>>> allow admins to see how often a socket buffer was completely full, 
>>> completely empty, or how often the window size is being aggressively 
>>> cut?
>> So I've done this using tcpdump in combination with tcptrace. I've 
>> shown people at citi how the tcp window grows in the experiment I 
>> describe.
>
> No, I mean as a part of the patch that adds the tweak, it should 
> report various new statistics that can allow admins to see that they 
> need adjustment, or that there isn't a problem at all in this area.
>
> Scientific system tuning means assessing the problem, trying a change, 
> then measuring to see if it was effective, or if it caused more 
> trouble.  Lather, rinse, repeat.

>
>>> While we may not be able to determine a single optimal buffer size 
>>> for all BDPs, are there diminishing returns in most common cases for 
>>> increasing the buffer size past, say, 16MB?
>> Good question. It all depends on how much data you are transferring. 
>> In order to fully open a 128MB tcp window over a very long WAN, you 
>> will need to transfer at least a few gigabytes of data. If you only 
>> transfer 100 MB at a time, then you will probably be fine with a 16 
>> MB window as you are not transferring enough data to open the window 
>> anyways. In our environment, we are expecting to transfer 100s of GB 
>> if not even more, so the 16 MB window would be very limiting.
>
> What about for a fast LAN?

>
>>>> The information you are curious about is more relevant to creating 
>>>> better default values of the tcp buffer size. This could be useful, 
>>>> but would be a long process and there are so many variables that 
>>>> I'm not sure that you could pick proper default values anyways. The 
>>>> important thing is that the client can currently set its tcp buffer 
>>>> size via the sysctl's, this is useless if the server is stuck at a 
>>>> fixed value since the tcp window will be the minimum of the client 
>>>> and server's tcp buffer sizes.
>>>
>>>
>>> Well, Linux servers are not the only servers that a Linux client 
>>> will ever encounter, so the client-side sysctl isn't as bad as 
>>> useless. But one can argue whether that knob is ever tweaked by 
>>> client administrators, and how useful it is.
>> Definitely not useless. Doing a google search for 'tcp_rmem' returns 
>> over 11000 hits describing how to configure tcp settings. (ok, I 
>> didn't review every result, but the first few pages of results are 
>> telling) It doesn't really matter what OS the client and server use, 
>> as long as both have the ability to tweak the tcp buffer size.
>
> The number of hits may reflect the desperation that many have had over 
> the years to get better performance from the Linux NFS 
> implementation.  These days we have better performance out of the box, 
> so there is less need for this kind of after-market tweaking.
>
> I think we would be in a much better place if the client and server 
> implementations worked "well enough" in nearly any network or 
> environment.  That's been my goal since I started working on Linux NFS 
> seven years ago.
>
>>> What is an appropriate setting for a server that has to handle a mix 
>>> of local and remote clients, for example, or a client that has to 
>>> connect to a mix of local and remote servers?
>> Yes, this is a tricky one. I believe the best way to handle it is to 
>> set the server tcp buffer to the MAX(local, remote) and then let the 
>> local client set a smaller tcp buffer and the remote client set a 
>> larger tcp buffer. The problem there is that then what if the local 
>> client is also a remote client of another nfs server?? At this point 
>> there seems to be some limitations.....
>
> Using multiple connections solves this problem pretty well, I think.
>
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
