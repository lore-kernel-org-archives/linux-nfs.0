From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Unable to copy large files to NFS server
Date: Mon, 31 Jul 2006 12:43:15 -0400
Message-ID: <44CE3323.3080502@RedHat.com>
References: <E092A2FD32592642884987B611E09A09024BAB@ukth008-2kaex-t.eckoh.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G7arb-0002pR-4U
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 09:43:31 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G7arb-0006zt-Af
	for nfs@lists.sourceforge.net; Mon, 31 Jul 2006 09:43:31 -0700
To: Dan McNulty <dan.mcnulty@eckoh.com>
In-Reply-To: <E092A2FD32592642884987B611E09A09024BAB@ukth008-2kaex-t.eckoh.com>
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

Dan McNulty wrote:
> Hi,
> =

>  =

> =

> We have recently purchased a new EMC NAS solution. I have successfully =

> configured our newer (Fedora4) servers to access this successfully.
> =

>  =

> =

> However we have a number of RedHat 7.2 servers (kernel 2.4.18), which I =

> have successfully mounted to the Server, and can copy small files OK. =

> However, when I try to copy larger files to the Server, the system just =

> hangs, and then the mount becomes unusable; I=92m unable to kill the hung =

> process and cannot unmount. I have tried to edit the rsize/wsize options =

> but this hasn=92t worked. The current entry in /etc/fstab looks like this:
> =

>  =

> =

> Servername:/path1/path2/Production    /mnt/Production nfs     =

> rsize=3D4096,wsize=3D4096,nfsvers=3D3 0 0
> =

>  =

> =

> In /var/log/messages I see lots of these errors:
> =

>  =

> =

> Jul 31 16:29:51 client1 kernel: nfs: server Servername not responding, =

> still trying
> =

> Jul 31 16:31:40 client1 kernel: nfs: task 189 can't get a request slot
> =

> Jul 31 16:31:40 client1 kernel: nfs: task 190 can't get a request slot
> =

>  =

> =

> The main problem is that I can write small files and it works OK. As =

> soon as I try to transfer a larger file, the client writes a 0 byte file =

> to the server (with the correct filename) then just hangs. I then can=92t =

> do anything with the mount. Any help on what I should be looking at =

> would be much appreciated!
Are you using UDP or TCP mounts? If udp, switch to TCP.. also,
use 'tethereal -w /tmp/data.pcap host <server>' to capture this
hang to see which side stop sending (meaning is the client waiting
for a reply or is the server waiting for another request).

I know in the past, EMC server had an issue with how FC and RHEL kernels
handled ESTALE messages... but I doubt that is happening in this
case... but you might want to rummage around in both bug database
(assuming you have access to EMC's) and see if this a known issue and
if there is a fix to it..

steved.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
