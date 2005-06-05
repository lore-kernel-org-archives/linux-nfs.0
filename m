From: "Dean S. Messing" <deanm@sharplabs.com>
Subject: Re: Help: nfs not able to mount large (loopback) directory
Date: Sat,  4 Jun 2005 23:07:08 -0700 (PDT)
Message-ID: <20050605060708.A7FF4112D0@pons>
References: <20050604031908.D58E8198C8@medulla.enet.sharplabs.com> <1117862910.19354.172.camel@seki.nac.uci.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DeoI7-0004cg-Q3
	for nfs@lists.sourceforge.net; Sat, 04 Jun 2005 23:07:23 -0700
Received: from keymaster.sharplabs.com ([216.65.151.107] helo=sharplabs.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DeoI7-0006c6-C6
	for nfs@lists.sourceforge.net; Sat, 04 Jun 2005 23:07:23 -0700
Received: from admsrvnt02.enet.sharplabs.com (admsrvnt02.enet.sharplabs.com [172.29.225.253])
	by sharplabs.com (8.13.1/8.13.1) with ESMTP id j5567H16006511
	for <nfs@lists.sourceforge.net>; Sat, 4 Jun 2005 23:07:17 -0700 (PDT)
To: nfs@lists.sourceforge.net
In-reply-to: <1117862910.19354.172.camel@seki.nac.uci.edu> (message from Dan
	Stromberg on Fri, 03 Jun 2005 22:28:30 -0700)
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



On Fri, 2005-06-03 at 20:19 -0700, Dean S. Messing wrote:

: > I have a large .iso image (4GB) on machine B which I have loopback
: > mounted to directory /mnt/disk.
: > When I try to nfs mount B:/mnt/disk to machine A I get a "permission
: > denied" error.
: > If I replace the 4GB image on machine B with, say, a 700MB .iso image,
: > I have no problem with the NFS mount on machine A.
: > I'm running the latest version of MandrivaLinux (2005LE == Mandrake 10.2)
: > on machine B and MandrakeLinux 10.0 on machine A so the nfs utilites
: > on machine B (the server) should be nearly current.
: > In fact:
: >
: > [root@neuron ~]# rpcinfo -p
: >    program vers proto   port
: >     100000    2   tcp    111  portmapper
: >     100000    2   udp    111  portmapper
: >     100003    2   udp   2049  nfs
: >     100003    3   udp   2049  nfs
: >     100003    4   udp   2049  nfs
: >     100003    2   tcp   2049  nfs
: >     100003    3   tcp   2049  nfs
: >     100003    4   tcp   2049  nfs
: >     100021    1   udp  34593  nlockmgr
: >     100021    3   udp  34593  nlockmgr
: >     100021    4   udp  34593  nlockmgr
: >     100021    1   tcp  33635  nlockmgr
: >     100021    3   tcp  33635  nlockmgr
: >     100021    4   tcp  33635  nlockmgr
: >     100005    1   udp    846  mountd
: >     100005    1   tcp    849  mountd
: >     100005    2   udp    846  mountd
: >     100005    2   tcp    849  mountd
: >     100005    3   udp    846  mountd
: >     100005    3   tcp    849  mountd
: >     100024    1   udp    888  status
: >     100024    1   tcp    891  status
: >
: > Is it the case that nfs (mountd?) can't handle "large" files?
: > Any help will be much appreciated.
: 
: I also have found that even small ISO images will lead to problems if
: you loopback mount them and NFS export them - EG via NFS v3.
: 
: However, if I loopback mount the ISO image, copy it to an ext3 directory
: with a tar | tar pipeline, and then NFS export that ext3 directory in
: the same way, things work fine.
: 
: I'm finding that often userspace->kernel and kernel->userspace work well
: in linux, but kernel->kernel interfaces seem to have  codepaths that
: aren't always tested that much.


According to the version numbers in the output of rpcinfo, I have nfs
v4 available on the server.  I have no idea if this makes a
difference, but serving a 700MB CD image via loopback has given me no
problems.

But for some reason I can't serve a DVD .iso image.  Of course your
solution of copying the loopback mounted directory into a real
directory is a workaround.  But what a waste of space!

It seems to me that serving a DVD .iso via NFS should be a fairly
commonly done thing.  Is anyone on this list successfully doing this?

Dean


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
