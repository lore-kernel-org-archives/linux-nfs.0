From: Josh Helmer <joshhelmer@disc-storage.com>
Subject: Copy process hangs
Date: Tue, 5 Nov 2002 17:25:52 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210291725.41186.joshhelmer@disc-storage.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host.disc-storage.com ([207.247.74.82] helo=Headwaiter.discjuke.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189E1r-0001As-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Nov 2002 16:26:43 -0800
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi Folks...

I am not a kernel expert so please bear with me.  I believe that I have=20
stumbled onto a bug with the NFS client.  This problem only seems to occu=
r=20
when using NFS over TCP mounted on the loopback device.

My company is using third party software from a company called QStar.   T=
he=20
QStar software provides it's own NFS server that transparently handles th=
e=20
details of caching and moving/mounting media in our DVD-RAM jukeboxes.  T=
heir=20
software allows us to view the whole jukebox just like a set of directori=
es. =20
It also provides a set of userland tools for managing the jukebox, managi=
ng=20
the media, and registering and mounting media.   The exact mount options =
that=20
their software uses:

localhost:test1 on /jukebox/test1 type nfs=20
(rw,nodev,v3,rsize=3D8192,wsize=3D8192,acregmin=3D5,acdirmin=3D5,hard,tcp=
,lock,addr=3Dlocalhost)

We usually just mount the jukebox locally so all network traffic is just =
going=20
over the loopback device.

In most cases their software works flawlessly, but recently we have notic=
ed a
problem.  If we continually write files > 1M to the jukebox it will work =
for=20
4-5 hours and then the copy process will hang (-D state) and it can not b=
e=20
killed.   After the copy process has been hung we are still able to read =
from=20
the NFS server without problems.  We are also able to write files smaller=
=20
than 978944 bytes.  If we attempt to write a file that is larger than 978=
944=20
bytes then the first 978944 bytes will write correctly and then the copy=20
process will hang.

What appears to be happening is that the NFS server is sending back a rep=
ly=20
for  each write request, but the kernel is not always handling the reply=20
correctly.  When I do a CTRL+Scroll lock and view the log it appears that=
 the=20
copy process is sleeping (nfs_wait_on_request()) and that the PG_BUSY fla=
g=20
in the request is never being cleared.   I have run strace on the copy=20
process and it always seems to hang on the close() or write() system call=
=2E  =20
I also have the raw tcpdump of the packets sent during the copy (download=
 from=20
ftp://65.212.128.228/pub/tcpdump.log.gz - just unzip and load into ethere=
al).

When we run this same test using a 2.4.9 kernel our test runs flawlessly.=
 =20
When we run this test using a 2.4.12 or newer kernel we can consistently=20
reproduce this bug.  (I believe that this will occur with any kernel newe=
r=20
that 2.4.10, but since I believe that I found the code where the problem =
was=20
introduced I have not verified that).  I have tried using a 2.4.19 kernel=
 and=20
applying the latest (as of early last week) "all" patch, but the problem=20
still persists.

After doing a lot of looking and playing I finally think that I have=20
narrowed down the problem to a specific patch.  When I reverse the=20
linux-2.4.9-rpc_smpfixes.dif patch from nfs.sourceforge.net site against =
a=20
redhat 2.4.18-17.7.x kernel our test works without any problems.  I suspe=
ct=20
that in the process of fixing a race condition in SMP another subtle prob=
lem=20
was introduced.

The patch will not reverse itself correctly so I had to do a lot of manua=
l=20
fiddling with a fair amount of code.   I don't fully comprehend all of th=
e=20
code that I have been looking at and I am not completely comfortable with=
=20
what I have done so far.  The patch reversed all the code in clnt.c=20
correctly, and I manually reversed  some of the code in xprt.c.   Mostly =
what=20
I did was to revert the xprt_lock_write() and xprt_release_write() code b=
ack=20
to use xprt_down_transmit() and xprt_up_transmit().   Besides the obvious=
 smp=20
race that I re-introduced  I would not be surprised to find that I have=20
introduced some of my own bugs.  On the upside, after my fiddling I was a=
ble=20
to continiously write data to the jukebox for 31 hours straight without a=
=20
single hickup.  That's about 8x as long as it would run before my hack.

I have sent the tcpdump output to QStar - I don't understand the NFS prot=
ocol=20
well enough to understand all of what if going on by myself.  The develop=
ers=20
at QStar believe that the server is receiving and responding to the reque=
sts=20
properly.   They did express some concern that starting in packet 498 we=20
start to see cases where multiple RPC requests are being merged into a si=
ngle=20
TCP packet.  They thought the perhaps the socket had lost the TCP_NODELAY=
=20
flag, but I can not find anything in the code that would lead to that. =20
Despite their concern they say that they do appear to handle it correctly=
=2E =20
They also theorized that perhaps the kernel RPC layer is not correctly=20
handling the case where multiple responses are packed into a single TCP=20
packet.  They though that perhaps the kernel RPC layer was not reading th=
e=20
second RPC response properly.

Personally, I believe that the problem has to do with the fact that the=20
xprt_lock_write() function will occasionally disable the bottom half and =
then=20
go to sleep while trying to send.  Is it possible that the kernel is sile=
ntly=20
dropping packets if the bottom half is not run often enough (or is disabl=
ed=20
for too long) to handle the incoming traffic over the loopback device?

Since this seems to be the place where the experts reside I was hoping th=
at=20
someone here who knows and understands this code better than I do can giv=
e me=20
a hand in hunting this down and finding a real fix.

Our patched (uh... hacked) kernel is available from=20
ftp://65.212.128.228/pub/opensource/kernel.src.rpm (sorry, we use SRPMs a=
s=20
opposed to tar-gzipped files - for our purposes they are more convenient)=
=2E=20

Thanks
Josh


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
