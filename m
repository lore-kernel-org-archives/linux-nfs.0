From: esqueleto@tusofona.com
Subject: Re: Detectiong Network and umount / mount NFS
Date: Thu, 21 Apr 2005 15:04:40 +0100
Message-ID: <1114092280.4267b2f83bb27@webmail.tusofona.com>
References: <1114027379.4266b57354785@webmail.tusofona.com>  <4266C21D.9030305@RedHat.com>  <1114038052.4266df245e54e@webmail.tusofona.com>  <1114042784.17214.11.camel@lade.trondhjem.org>  <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se>  <1114088708.10727.9.camel@lade.trondhjem.org>  <1114090112.4267aa8096c00@webmail.tusofona.com> <1114091388.10727.36.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOcIN-00083F-GD
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 07:04:43 -0700
Received: from [81.92.210.10] (helo=agata.100limite.pt)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOcIM-0000Nh-Os
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 07:04:43 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1114091388.10727.36.camel@lade.trondhjem.org>
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

Ok

now I undestand what is the problem. May be this will be a big problem (v=
oted in
Bugzilla) and develop this feature fast.

I will wait for this.

tkx

Esqueleto
Odivelas - Portugal


> No, you don't appear to understand.
>
> umount requires you to kill all applications that are using a partition=
.
> That is true for ALL filesystems, and is enforced in the VFS. Try
> umounting "/" or "/home" while you are logged in.
>
> So, one thing that we are thinking of implementing is a so-called
> "disconnected" mode, in which NFS switches over to using local disk whe=
n
> you disconnect from the network (like AFS is somewhat able to do).
> That will enable you to continue working without killing off processes,
> but it requires something like cachefs to ensure that your in-use files
> are backed by local disk. Don't expect this to be ready anytime in the
> near future...
>
> Alternatively, you should look into using something like the
> "intermezzo" filesystem. The latter is available on 2.4 kernels (but is
> unmaintained and was therefore kicked out of 2.6), and is designed to
> work in laptop-like environments.
>
> Cheers,
>   Trond
> --
> Trond Myklebust <trond.myklebust@fys.uio.no>
>
>




----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.



-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime in=
fo,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
