From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Help: nfs not able to mount large (loopback) directory
Date: Sat, 04 Jun 2005 00:26:20 -0400
Message-ID: <1117859180.11099.12.camel@lade.trondhjem.org>
References: <20050604031908.D58E8198C8@medulla.enet.sharplabs.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DeQF9-0005wB-Fx
	for nfs@lists.sourceforge.net; Fri, 03 Jun 2005 21:26:43 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DeQF7-0002bO-Ly
	for nfs@lists.sourceforge.net; Fri, 03 Jun 2005 21:26:43 -0700
To: "Dean S. Messing" <deanm@sharplabs.com>
In-Reply-To: <20050604031908.D58E8198C8@medulla.enet.sharplabs.com>
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

fr den 03.06.2005 Klokka 20:19 (-0700) skreiv Dean S. Messing:
> 
> I have a large .iso image (4GB) on machine B which I have loopback
> mounted to directory /mnt/disk.
> 
> When I try to nfs mount B:/mnt/disk to machine A I get a "permission
> denied" error.
> 
> If I replace the 4GB image on machine B with, say, a 700MB .iso image, I have
> no problem with the NFS mount on machine A.
> 
> I'm running the latest version of MandrivaLinux (2005LE == Mandrake 10.2)
> on machine B and MandrakeLinux 10.0 on machine A so the nfs utilites
> on machine B (the server) should be nearly current.
> In fact:
> 
> [root@neuron ~]# rpcinfo -p
>    program vers proto   port
>     100000    2   tcp    111  portmapper
>     100000    2   udp    111  portmapper
>     100003    2   udp   2049  nfs
>     100003    3   udp   2049  nfs
>     100003    4   udp   2049  nfs
>     100003    2   tcp   2049  nfs
>     100003    3   tcp   2049  nfs
>     100003    4   tcp   2049  nfs
>     100021    1   udp  34593  nlockmgr
>     100021    3   udp  34593  nlockmgr
>     100021    4   udp  34593  nlockmgr
>     100021    1   tcp  33635  nlockmgr
>     100021    3   tcp  33635  nlockmgr
>     100021    4   tcp  33635  nlockmgr
>     100005    1   udp    846  mountd
>     100005    1   tcp    849  mountd
>     100005    2   udp    846  mountd
>     100005    2   tcp    849  mountd
>     100005    3   udp    846  mountd
>     100005    3   tcp    849  mountd
>     100024    1   udp    888  status
>     100024    1   tcp    891  status
> 
> 
> Is it the case that nfs (mountd?) can't handle "large" files?

It is true that NFS version 2 cannot handle files > 2GB, but as far as I
gathered you are not exporting the ISO as a single file. Besides, NFSv3
and NFSv4 should be quite capable of dealing with a 4GB file.

This therefore sounds more like it might be some strange interaction
between the loopback driver and nfsd or mountd.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
