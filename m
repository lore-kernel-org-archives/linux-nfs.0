From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: NFS mount problem (2000 NFS filesystems) of linux clients
 to a solaris server
Date: Fri, 09 Mar 2007 08:09:27 -0500
Message-ID: <EXNANE01VuMhvqgStMV00000097@exnane01.hq.netapp.com>
References: <45F004BD.1070500@biochem.mpg.de>
	<EXNANE01FRaqbC8wSA10000007f@exnane01.hq.netapp.com>
	<45F15018.1060804@biochem.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: NFS@lists.sourceforge.net
To: Bernhard Busch <bbusch@biochem.mpg.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <45F15018.1060804@biochem.mpg.de>
References: <45F004BD.1070500@biochem.mpg.de>
	<EXNANE01FRaqbC8wSA10000007f@exnane01.hq.netapp.com>
	<45F15018.1060804@biochem.mpg.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Well, I know what's happening but I'm having a little difficulty coming
up with a clean workaround.

The mount command creates and binds a socket in userspace, then
passes it to the kernel for connecting to the server. Newer kernels
don't use this socket however, and it is closed when the mount
completes. However, it's a TCP socket and is bound to a privileged
port, the socket isn't destroyed immediately, it sticks around for
a short time.

The problem is that you are creating two thousand of these, and
the mounts are completing faster than these sockets are destroyed.
It's the mount command which is failing now, not the actual mount.

One solution may be to lower the maximum number of system tcp
orphans, which would prevent too many of these from clogging up
the TCP port space.
	echo 100 >/proc/sys/net/ipv4/tcp_max_orphans
This is a really crude fix though, the default is 131072 and it is
not good for TCP correctness to destroy endpoints so readily.
So, I'd try saving and restorng this value around the mounts.
Maybe someone here can come up with a better workaround.

I think the better solution for you would be to think through how
you could use fewer mounts, maybe demand-mounting using an
automounter, or some other scheme. 2000+ mounts per client is
really way over the top in normal use, for most installations. Imagine
the traffic at boot time or network breakage, just to mount them
all. And if you have more than one client, the server sees Nx2000
connections!

I hope this helps.

Tom.

At 07:16 AM 3/9/2007, Bernhard Busch wrote:
>Talpey, Thomas wrote:
>
>
>
>
>Hello  Tom
>
>
>Thank you very much for your help.
>I was able to mount the 2000 NFS files after your modifications
>via:
>
>for i in `seq 1 2000`
>do
>     mount   -t nfs -o intr,hard,tcp  solaris10-02:/fs/DISK/disk$i  =

>/fs/solaris10-02/DISK/disk$i
>    sleep  1
> done
>
>
>But , if i remove the sleep command the
>
>nfs bindresvport: Address already in use
>
>error appears again.
>
>On solaris and sgi clients the above command works correctly without the =

>sleep command.
>
>So the machine takes about 1 hour to mount all nfs filesystems.
>
>Any idea?
>
>Best wishes
>
>Bernhard
>
>
>
>
>> At 07:42 AM 3/8/2007, Bernhard Busch wrote:
>>   =

>>> It is possible to export these 2000 filesystems on the server (sun sola=
ris)
>>> and  to  mount these 2000 nfs filesystem on sgi and solaris
>>> clients without any problems.
>>>
>>>
>>> On Linux Clients (SLES10, Suse10.2)  i get =

>>> error messages like the following ones:
>>>
>>> nfs bindresvport: Address already in use
>>> nfs bindresvport: Address already in use
>>> nfs bindresvport: Address already in use
>>> mount: solaris10-02:/fs/DISK/disk1998: can't read superblock
>>> mount: solaris10-02:/fs/DISK/disk1999: can't read superblock
>>> mount: solaris10-02:/fs/DISK/disk2000: can't read superblock
>>>     =

>>
>> You need to increase the number of ports available on the Linux NFS
>> client.
>>
>> echo 65535 >/proc/sys/sunrpc/max_resvport
>>
>> This will raise it to the maximum, you could use smaller values but
>> because you are creating so many mounts, that would quite possibly
>> start to collide with other reserved ports.
>>
>> In fact, you might want to set /proc/sys/sunrpc/min_resvport to
>> something large (32768), also in order to avoid collisions. However
>> that in turn might require reconfiguring some of your NFS servers to
>> accept "nonprivileged" ports (Linux server export option "insecure",
>> others see documentation).
>>
>> Tom.
>>
>>
>>
>>   =

>
>
>-- =

>Dr. Bernhard Busch
>Max-Planck-Institut f=FCr Biochemie
>Rechenzentrum
>Am Klopferspitz 18a
>D-82152 Martinsried
>Tel: +49(89)8578-2582
>Fax: +49(89)8578-2479
>Email bbusch@biochem.mpg.de
>
>
>


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
