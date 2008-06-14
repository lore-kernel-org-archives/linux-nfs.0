From: Dean Hildebrand <seattleplus@gmail.com>
Subject: Re: [PATCH 0/1] SUNRPC: Add sysctl variables for server TCP snd/rcv
 buffer values
Date: Fri, 13 Jun 2008 18:07:38 -0700
Message-ID: <485319DA.9040706@gmail.com>
References: <484ECDE4.6030108@gmail.com> <7F44A14A-F811-4D41-BAFF-E019E9904B6A@oracle.com> <48518F18.2010703@gmail.com> <C04F3083-91B2-464B-8F5C-958B243EB46C@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:32375 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754990AbYFNBHo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jun 2008 21:07:44 -0400
Received: by wf-out-1314.google.com with SMTP id 27so4356394wfd.4
        for <linux-nfs@vger.kernel.org>; Fri, 13 Jun 2008 18:07:43 -0700 (PDT)
In-Reply-To: <C04F3083-91B2-464B-8F5C-958B243EB46C@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> On Jun 12, 2008, at 5:03 PM, Dean Hildebrand wrote:
>> Hi Chuck,
>>
>> Chuck Lever wrote:
>>> Howdy Dean-
>>>
>>> On Jun 10, 2008, at 2:54 PM, Dean Hildebrand wrote:
>>>> The motivation for this patch is improved WAN write performance=20
>>>> plus greater user control on the server of the TCP buffer values=20
>>>> (window size). The TCP window determines the amount of outstanding=
=20
>>>> data that a client can have on the wire and should be large enough=
=20
>>>> that a NFS client can fill up the pipe (the bandwidth * delay=20
>>>> product). Currently the TCP receive buffer size (used for client=20
>>>> writes) is set very low, which prevents a client from filling up a=
=20
>>>> network pipe with a large bandwidth * delay product.
>>>>
>>>> Currently, the server TCP send window is set to accommodate the=20
>>>> maximum number of outstanding NFSD read requests (# nfsds *=20
>>>> maxiosize), while the server TCP receive window is set to a fixed=20
>>>> value which can hold a few requests. While these values set a TCP=20
>>>> window size that is fine in LAN environments with a small BDP, WAN=
=20
>>>> environments can require a much larger TCP window size, e.g.,=20
>>>> 10GigE transatlantic link with a rtt of 120 ms has a BDP of approx=
=20
>>>> 60MB.
>>>
>>> Was the receive buffer size computation adjusted when support for=20
>>> large transfer sizes was recently added to the NFS server?
>> Yes, it is based on the transfer size. So in the current code, havin=
g=20
>> a larger transfer size can improve efficiency PLUS help create a=20
>> larger possible TCP window. The issue seems to be that tcp window, #=
=20
>> of NFSDs, and transfer size are all independent variables that need=20
>> to be tuned individually depending on rtt, network bandwidth, disk=20
>> bandwidth, etc etc... We can adjust the last 2, so this patch helps=20
>> adjust the first (tcp window).
>>>
>>>> I have a patch to net/svc/svcsock.c that allows a user to manually=
=20
>>>> set the server TCP send and receive buffer through the sysctl=20
>>>> interface. to suit the required TCP window of their network=20
>>>> architecture. It adds two /proc entries, one for the receive buffe=
r=20
>>>> size and one for the send buffer size:
>>>> /proc/sys/sunrpc/tcp_sndbuf
>>>> /proc/sys/sunrpc/tcp_rcvbuf
>>>
>>> What I'm wondering is if we can find some algorithm to set the=20
>>> buffer and window sizes *automatically*. Why can't the NFS server=20
>>> select an appropriately large socket buffer size by default?
>>
>>>
>>> Since the socket buffer size is just a limit (no memory is=20
>>> allocated) why, for example, shouldn't the buffer size be large for=
=20
>>> all environments that have sufficient physical memory?
>> I think the problem there is that the only way to set the buffer siz=
e=20
>> automatically would be to know the rtt and bandwidth of the network=20
>> connection. Excessive numbers of packets can get dropped if the TCP=20
>> buffer is set too large for a specific network connection.
>
>> In this case, the window opens too wide and lets too many packets ou=
t=20
>> into the system, somewhere along the path buffers start overflowing=20
>> and packets are lost, TCP congestion avoidance kicks in and cuts the=
=20
>> window size dramatically and performance along with it. This type of=
=20
>> behaviour creates a sawtooth pattern for the TCP window, which is=20
>> less favourable than a more steady state pattern that is created if=20
>> the TCP buffer size is set appropriately.
>
> Agreed it is a performance problem, but I thought some of the newer=20
> TCP congestion algorithms were specifically designed to address this=20
> by not closing the window as aggressively.
Yes, every tcp algorithm seems to have its own niche. Personally, I hav=
e=20
found bic the best in the WAN as it is pretty aggressive at returning t=
o=20
the original window size. Since cubic is now the Linux default, and=20
changing the tcp cong control algorithm is done for an entire system=20
(meaning local clients could be adversely affected by choosing one=20
designed for specialized networks), I think we should try to optimize c=
ubic.
>
> Once the window is wide open, then, it would appear that choosing a=20
> good congestion avoidance algorithm is also important.
Yes, but it is always important to avoid ever letting the window get to=
o=20
wide, as this will cause a hiccup every single time you try to send a=20
bunch of data (a tcp window closes very quickly after data is=20
transmitted, so waiting 1 second causing you to start from the beginnin=
g=20
with a small window)
>
>> Another point is that setting the buffer size isn't always a=20
>> straightforward process. All papers I've read on the subject, and my=
=20
>> experience confirms this, is that setting tcp buffer sizes is more o=
f=20
>> an art.
>>
>> So having the server set a good default value is half the battle, bu=
t=20
>> allowing users to twiddle with this value is vital.
>
>>>> The uses the current buffer sizes in the code are as minimum=20
>>>> values, which the user cannot decrease. If the user sets a value o=
f=20
>>>> 0 in either /proc entry, it resets the buffer size to the default=20
>>>> value. The set /proc values are utilized when the TCP connection i=
s=20
>>>> initialized (mount time). The values are bounded above by the=20
>>>> *minimum* of the /proc values and the network TCP sysctls.
>>>>
>>>> To demonstrate the usefulness of this patch, details of an=20
>>>> experiment between 2 computers with a rtt of 30ms is provided=20
>>>> below. In this experiment, increasing the server=20
>>>> /proc/sys/sunrpc/tcp_rcvbuf value doubles write performance.
>>>>
>>>> EXPERIMENT
>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>> This experiment simulates a WAN by using tc together with netem to=
=20
>>>> add a 30 ms delay to all packets on a nfs client. The goal is to=20
>>>> show that by only changing tcp_rcvbuf, the nfs client can increase=
=20
>>>> write performance in the WAN. To verify the patch has the desired=20
>>>> effect on the TCP window, I created two tcptrace plots that show=20
>>>> the difference in tcp window behaviour before and after the server=
=20
>>>> TCP rcvbuf size is increased. When using the default server tcpbuf=
=20
>>>> value of 6M, we can see the TCP window top out around 4.6 M,=20
>>>> whereas increasing the server tcpbuf value to 32M, we can see that=
=20
>>>> the TCP window tops out around 13M. Performance jumps from 43 MB/s=
=20
>>>> to 90 MB/s.
>>>>
>>>> Hardware:
>>>> 2 dual-core opteron blades
>>>> GigE, Broadcom NetXtreme II BCM57065 cards
>>>> A single gigabit switch in the middle
>>>> 1500 MTU
>>>> 8 GB memory
>>>>
>>>> Software:
>>>> Kernel: Bruce's 2.6.25-rc9-CITI_NFS4_ALL-1 tree
>>>> RHEL4
>>>>
>>>> NFS Configuration:
>>>> 64 rpc slots
>>>> 32 nfsds
>>>> Export ext3 file system. This disk is quite slow, I therefore=20
>>>> exported using async to reduce the effect of the disk on the back=20
>>>> end. This way, the experiments record the time it takes for the=20
>>>> data to get to the server (not to the disk).
>>>> # exportfs -v
>>>> /export <world>(rw,async,wdelay,nohide,insecure,no_root_squash,fsi=
d=3D0)
>>>>
>>>> # cat /proc/mounts
>>>> bear109:/export /mnt nfs=20
>>>> rw,vers=3D3,rsize=3D1048576,wsize=3D1048576,namlen=3D255,hard,noin=
tr,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,mountproto=3Dudp,addr=3D=
9.1.74.144=20
>>>> 0 0
>>>>
>>>> fs.nfs.nfs_congestion_kb =3D 91840
>>>> net.ipv4.tcp_congestion_control =3D cubic
>>>>
>>>> Network tc Command executed on client:
>>>> tc qdisc add dev eth0 root netem delay 30ms
>>>> rtt from client (bear108) to server (bear109)
>>>> #ping bear109
>>>> PING bear109.almaden.ibm.com (9.1.74.144) 56(84) bytes of data.
>>>> 64 bytes from bear109.almaden.ibm.com (9.1.74.144): icmp_seq=3D0=20
>>>> ttl=3D64 time=3D31.4 ms
>>>> 64 bytes from bear109.almaden.ibm.com (9.1.74.144): icmp_seq=3D1=20
>>>> ttl=3D64 time=3D32.0 ms
>>>>
>>>> TCP Configuration on client and server:
>>>> # Controls IP packet forwarding
>>>> net.ipv4.ip_forward =3D 0
>>>> # Controls source route verification
>>>> net.ipv4.conf.default.rp_filter =3D 1
>>>> # Do not accept source routing
>>>> net.ipv4.conf.default.accept_source_route =3D 0
>>>> # Controls the System Request debugging functionality of the kerne=
l
>>>> kernel.sysrq =3D 0
>>>> # Controls whether core dumps will append the PID to the core file=
name
>>>> # Useful for debugging multi-threaded applications
>>>> kernel.core_uses_pid =3D 1
>>>> # Controls the use of TCP syncookies
>>>> net.ipv4.tcp_syncookies =3D 1
>>>> # Controls the maximum size of a message, in bytes
>>>> kernel.msgmnb =3D 65536
>>>> # Controls the default maxmimum size of a mesage queue
>>>> kernel.msgmax =3D 65536
>>>> # Controls the maximum shared segment size, in bytes
>>>> kernel.shmmax =3D 68719476736
>>>> # Controls the maximum number of shared memory segments, in pages
>>>> kernel.shmall =3D 4294967296
>>>> ### IPV4 specific settings
>>>> net.ipv4.tcp_timestamps =3D 0
>>>> net.ipv4.tcp_sack =3D 1
>>>> # on systems with a VERY fast bus -> memory interface this is the=20
>>>> big gainer
>>>> net.ipv4.tcp_rmem =3D 4096 16777216 16777216
>>>> net.ipv4.tcp_wmem =3D 4096 16777216 16777216
>>>> net.ipv4.tcp_mem =3D 4096 16777216 16777216
>>>> ### CORE settings (mostly for socket and UDP effect)
>>>> net.core.rmem_max =3D 16777216
>>>> net.core.wmem_max =3D 16777216
>>>> net.core.rmem_default =3D 16777216
>>>> net.core.wmem_default =3D 16777216
>>>> net.core.optmem_max =3D 16777216
>>>> net.core.netdev_max_backlog =3D 300000
>>>> # Don't cache ssthresh from previous connection
>>>> net.ipv4.tcp_no_metrics_save =3D 1
>>>> # make sure we don't run out of memory
>>>> vm.min_free_kbytes =3D 32768
>>>>
>>>> Experiments:
>>>>
>>>> On Server: (note that the real tcp buffer size is double tcp_rcvbu=
f)
>>>> [root@bear109 ~]# echo 0 > /proc/sys/sunrpc/tcp_rcvbuf
>>>> [root@bear109 ~]# cat /proc/sys/sunrpc/tcp_rcvbuf
>>>> 3158016
>>>>
>>>> On Client:
>>>> mount -t nfs bear109:/export /mnt
>>>> [root@bear108 ~]# iozone -aec -i 0 -+n -f /mnt/test -r 1M -s 500M
>>>> ...
>>>> KB reclen write
>>>> 512000 1024 43252 umount /mnt
>>>>
>>>> On server:
>>>> [root@bear109 ~]# echo 16777216 > /proc/sys/sunrpc/tcp_rcvbuf
>>>> [root@bear109 ~]# cat /proc/sys/sunrpc/tcp_rcvbuf
>>>> 16777216
>>>>
>>>> On Client:
>>>> mount -t nfs bear109:/export /mnt
>>>> [root@bear108 ~]# iozone -aec -i 0 -+n -f /mnt/test -r 1M -s 500M
>>>> ...
>>>> KB reclen write
>>>> 512000 1024 90396
>>>
>>> The numbers you have here are averages over the whole run.=20
>>> Performing these tests using a variety of record lengths and file=20
>>> sizes (up to several tens of gigabytes) would be useful to see wher=
e=20
>>> different memory and network latencies kick in.
>> Definitely useful, although I'm not sure how this relates to this pa=
tch.
>
> It relates to the whole idea that this is a valid and useful paramete=
r=20
> to tweak.
>
> What your experiment shows is that there is some improvement when the=
=20
> TCP window is allowed to expand. It does not demonstrate that the=20
> *best* way to provide this facility is to allow administrators to tun=
e=20
> the server's TCP buffer sizes.
By definition of how TCP is designed, tweaking the send and receive=20
buffer sizes is a useful. Please see the tcp tuning guides in my other=20
post. I would characterize tweaking the buffers as a necessary conditio=
n=20
but not a sufficient condition to achieve good throughput with tcp over=
=20
long distances.
>
> A single average number can hide a host of underlying sins. This=20
> simple experiment, for example, does not demonstrate that TCP window=20
> size is the most significant issue here.
I would say it slightly differently, that it demonstrates that it is=20
significant, but maybe not the *most* significant. There are many=20
possible bottlenecks and possible knobs to tweak. For example, I'm stil=
l=20
not achieving link speeds, so I'm sure there are other bottlenecks that=
=20
are causing reduced performance.
> It does not show that it is more or less effective to adjust the=20
> window size than to select an appropriate congestion control algorith=
m=20
> (say, BIC).
Any tcp cong. control algorithm is highly dependent on the tcp buffer=20
size. The choice of algorithm changes the behaviour when packets are=20
dropped and in the initial opening of the window, but once the window i=
s=20
open and no packets are being dropped, the algorithm is irrelevant. So=20
BIC, or westwood, or highspeed might do better in the face of dropped=20
packets, but since the current receive buffer is so small, dropped=20
packets are not the problem. Once we can use the sysctl's to tweak the=20
server buffer size, only then is the choice of algorithm going to be=20
important.
> It does not show whether the client and server are using TCP optimall=
y.
I'm not sure what you mean by *optimally*. They use tcp the only way=20
they know how non?
> It does not expose problems related to having a single data stream=20
> with one blocking head (eg SCTP can allow multiple streams over the=20
> same connection; or better performance might be achieved with multipl=
e=20
> TCP connections, even if they allow only small windows).
Yes, using multiple tcp connections might be useful, but that doesn't=20
mean you wouldn't want to adjust the tcp window of each one using my=20
patch. Actually, I can't seem to find the quote, but I read somewhere=20
that achieving performance in the WAN can be done 2 different ways: a)=20
If you can tune the buffer sizes that is the best way to go, but b) if=20
you don't have root access to change the linux tcp settings then using=20
multiple tcp streams can compensate for small buffer sizes.

Andy has/had a patch to add multiple tcp streams to NFS. I think his=20
patch and my patch work in collaboration to improve wan performance.
>
>> This patch isn't trying to alter default values, or predict buffer=20
>> sizes based on rtt values, or dynamically alter the tcp window based=
=20
>> on dropped packets, etc, it is just giving users the ability to=20
>> customize the server tcp buffer size.
>
> I know you posted this patch because of the experiments at CITI with=20
> long-run 10GbE, and it's handy to now have this to experiment with.
Actually at IBM we have our own reasons for using NFS over the WAN. I=20
would like to get these 2 knobs into the kernel as it is hard to tell=20
customers to apply kernel patches....
>
> It might also be helpful if we had a patch that made the server=20
> perform better in common environments, so a better default setting it=
=20
> seems to me would have greater value than simply creating a new tunin=
g=20
> knob.
I think there are possibly 2 (or more) patches. One that improves the=20
default buffer sizes and one that lets sysadmins tweak the value. I=20
don't see why they are mutually exclusive. My patch is a first step=20
towards allowing NFS into WAN environments. Linux currently has sysctl=20
values for the TCP parameters for exactly this reason, it is impossible=
=20
to predict the network environment of a linux machine. If the Linux nfs=
=20
server isn't going to build off of the existing Linux TCP values (which=
=20
all sysadmins know how to tweak), then it must allow sysadmins to tweak=
=20
the NFS server tcp values, either using my patch or some other related=20
patch. I'm open to how the server tcp buffers are teaked, they just nee=
d=20
to be able to be tweaked. For example, if all tcp buffer values in linu=
x=20
were taken out of the /proc file system and hardcoded, I think there=20
would be a revolt.
>
> Would it be hard to add a metric or two with this tweak that would=20
> allow admins to see how often a socket buffer was completely full,=20
> completely empty, or how often the window size is being aggressively =
cut?
So I've done this using tcpdump in combination with tcptrace. I've show=
n=20
people at citi how the tcp window grows in the experiment I describe.
>
> While we may not be able to determine a single optimal buffer size fo=
r=20
> all BDPs, are there diminishing returns in most common cases for=20
> increasing the buffer size past, say, 16MB?
Good question. It all depends on how much data you are transferring. In=
=20
order to fully open a 128MB tcp window over a very long WAN, you will=20
need to transfer at least a few gigabytes of data. If you only transfer=
=20
100 MB at a time, then you will probably be fine with a 16 MB window as=
=20
you are not transferring enough data to open the window anyways. In our=
=20
environment, we are expecting to transfer 100s of GB if not even more,=20
so the 16 MB window would be very limiting.
>
>> The information you are curious about is more relevant to creating=20
>> better default values of the tcp buffer size. This could be useful,=20
>> but would be a long process and there are so many variables that I'm=
=20
>> not sure that you could pick proper default values anyways. The=20
>> important thing is that the client can currently set its tcp buffer=20
>> size via the sysctl's, this is useless if the server is stuck at a=20
>> fixed value since the tcp window will be the minimum of the client=20
>> and server's tcp buffer sizes.
>
>
> Well, Linux servers are not the only servers that a Linux client will=
=20
> ever encounter, so the client-side sysctl isn't as bad as useless. Bu=
t=20
> one can argue whether that knob is ever tweaked by client=20
> administrators, and how useful it is.
Definitely not useless. Doing a google search for 'tcp_rmem' returns=20
over 11000 hits describing how to configure tcp settings. (ok, I didn't=
=20
review every result, but the first few pages of results are telling) It=
=20
doesn't really matter what OS the client and server use, as long as bot=
h=20
have the ability to tweak the tcp buffer size.
>
>> The server cannot do just the same thing as the client since it=20
>> cannot just rely on the tcp sysctl's since it also needs to ensure i=
t=20
>> has enough buffer space for each NFSD.
>
> I agree the server's current logic is too conservative.
>
> However, the server has an automatic load-leveling feature -- it can=20
> close sockets if it notices it is running out of resources, and the=20
> Linux server does this already. I don't think it would be terribly=20
> harmful to overcommit the socket buffer space since we have such a=20
> safety valve.
The tcp tuning guides in my other post comment on exactly my point that=
=20
proving too large a tcp window can be harmful to performance.
>
>> My goal with this patch is to provide users with the same flexibilit=
y=20
>> that the client has regarding tcp buffer sizes, but also ensure that=
=20
>> the minimum amount of buffer space that the NFSDs require is allocat=
ed.
>
> What is the formula you used to determine the value to poke into the=20
> sysctl, btw?
I like this doc: http://acs.lbl.gov/TCP-tuning/tcp-wan-perf.pdf
The optimal buffer size is twice the bandwidth * delay product of the l=
ink:
buffer size =3D bandwidth * RTT

Here is the entire relevant part:

"""
2.0 TCP Buffer Sizes
TCP uses what it calls the =93congestion window,=94 or CWND, to determi=
ne=20
how many
packets can be sent at one time. The larger the congestion window size,=
=20
the higher the
throughput. The TCP =93slow start=94 and =93congestion avoidance=94 alg=
orithms=20
determine the
size of the congestion window. The maximum congestion window is related=
=20
to the
amount of buffer space that the kernel allocates for each socket. For=20
each socket, there
is a default value for the buffer size, which can be changed by the=20
program using a system
library call just before opening the socket. There is also a kernel=20
enforced maximum
buffer size. The buffer size can be adjusted for both the send and=20
receive ends of
the socket.
To achieve maximal throughput it is critical to use optimal TCP send an=
d=20
receive socket
buffer sizes for the link you are using. If the buffers are too small,=20
the TCP congestion
window will never fully open up. If the buffers are too large, the=20
sender can overrun the
receiver, and the TCP window will shut down. For more information, see=20
the references
on page 38.
Users often wonder why, on a network where the slowest hop from site A=20
to site B is
100 Mbps (about 12 MB/sec), using ftp they can only get a throughput of=
=20
500 KB/sec.
The answer is obvious if you consider the following: typical latency=20
across the US is
about 25 ms, and many operating systems use a default TCP buffer size o=
f=20
either 24 or
32 KB (Linux is only 8 KB). Assuming a default TCP buffer of 24KB, the=20
maximum utilization
of the pipe will only be 24/300 =3D 8% (.96 MB/sec), even under ideal=20
conditions.
In fact, the buffer size typically needs to be double the TCP congestio=
n=20
window
size to keep the pipe full, so in reality only about 4% utilization of=20
the network is
achieved, or about 500 KB/sec. Therefore if you are using untuned TCP=20
buffers you=92ll
often get less than 5% of the possible bandwidth across a high-speed WA=
N=20
path. This is
why it is essential to tune the TCP buffers to the optimal value.
The optimal buffer size is twice the bandwidth * delay product of the l=
ink:
buffer size =3D 2 * bandwidth * delay
The ping program can be used to get the delay, and pipechar or pchar,=20
described below,
can be used to get the bandwidth of the slowest hop in your path. Since=
=20
ping gives the
round-trip time (RTT), this formula can be used instead of the previous=
 one:
buffer size =3D bandwidth * RTT
=46or example, if your ping time is 50 ms, and the end-to-end network=20
consists of all
100BT Ethernet and OC3 (155 Mbps), the TCP buffers should be 0.05 sec *=
=20
10 MB/sec
=3D 500 KB. If you are connected via a T1 line (1 Mbps) or less, the=20
default buffers are
fine, but if you are using a network faster than that, you will almost=20
certainly benefit
from some buffer tuning.
Two TCP settings need to be considered: the default TCP send and receiv=
e=20
buffer size
and the maximum TCP send and receive buffer size. Note that most of=20
today=92s UNIX
OSes by default have a maximum TCP buffer size of only 256 KB (and the=20
default maximum
for Linux is only 64 KB!). For instructions on how to increase the maxi=
mum
TCP buffer, see Appendix A. Setting the default TCP buffer size greater=
=20
than 128 KB
will adversely affect LAN performance. Instead, the UNIX setsockopt cal=
l=20
should be
used in your sender and receiver to set the optimal buffer size for the=
=20
link you are
using. Use of setsockopt is described in Appendix B.
It is not necessary to set both the send and receive buffer to the=20
optimal value, as the
socket will use the smaller of the two values. However, it is necessary=
=20
to make sure both
are large enough. A common technique is to set the buffer in the server=
=20
quite large
(e.g., 512 KB) and then let the client determine and set the correct=20
=93optimal=94 value.
""
>
> What is an appropriate setting for a server that has to handle a mix=20
> of local and remote clients, for example, or a client that has to=20
> connect to a mix of local and remote servers?
Yes, this is a tricky one. I believe the best way to handle it is to se=
t=20
the server tcp buffer to the MAX(local, remote) and then let the local=20
client set a smaller tcp buffer and the remote client set a larger tcp=20
buffer. The problem there is that then what if the local client is also=
=20
a remote client of another nfs server?? At this point there seems to be=
=20
some limitations.....

btw, here is another good paper with regards to tcp buffer sizing in th=
e=20
WAN:
"Optimizing 10-Gigabit Ethernet for Networks of Workstations, Clusters,=
=20
and Grids: A Case Study"
http://portal.acm.org/citation.cfm?id=3D1050200

I also found the parts in this page regarding tcp setting very very=20
useful (it also briefly talks about multiple tcp streams):
http://pcbunn.cithep.caltech.edu/bbcp/using_bbcp.htm
Dean
