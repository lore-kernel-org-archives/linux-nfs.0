From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Detectiong Network and umount / mount NFS
Date: Thu, 21 Apr 2005 09:49:48 -0400
Message-ID: <1114091388.10727.36.camel@lade.trondhjem.org>
References: <1114027379.4266b57354785@webmail.tusofona.com>
	 <4266C21D.9030305@RedHat.com>
	 <1114038052.4266df245e54e@webmail.tusofona.com>
	 <1114042784.17214.11.camel@lade.trondhjem.org>
	 <Pine.LNX.4.61.0504211009380.3889@maggie.lkpg.cendio.se>
	 <1114088708.10727.9.camel@lade.trondhjem.org>
	 <1114090112.4267aa8096c00@webmail.tusofona.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter =?ISO-8859-1?Q?=C5strand?= <astrand@cendio.se>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOc4G-0007Jf-Qm
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 06:50:08 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DOc4E-00027c-UU
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 06:50:08 -0700
To: esqueleto@tusofona.com
In-Reply-To: <1114090112.4267aa8096c00@webmail.tusofona.com>
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

to den 21.04.2005 Klokka 14:28 (+0100) skreiv esqueleto@tusofona.com:
> now, when I change for 1 or 2 seconds there will be no network and the NFS does
> not resume the connection after the netwoek is up (or is not immediately).
> What I want if for the NFS it self umount when the network connection does not
> exists.
> If this happen i can mount again when the network is up again.

No, you don't appear to understand.

umount requires you to kill all applications that are using a partition.
That is true for ALL filesystems, and is enforced in the VFS. Try
umounting "/" or "/home" while you are logged in.

So, one thing that we are thinking of implementing is a so-called
"disconnected" mode, in which NFS switches over to using local disk when
you disconnect from the network (like AFS is somewhat able to do).
That will enable you to continue working without killing off processes,
but it requires something like cachefs to ensure that your in-use files
are backed by local disk. Don't expect this to be ready anytime in the
near future...

Alternatively, you should look into using something like the
"intermezzo" filesystem. The latter is available on 2.4 kernels (but is
unmaintained and was therefore kicked out of 2.6), and is designed to
work in laptop-like environments.

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.Net email is sponsored by: New Crystal Reports XI.
Version 11 adds new functionality designed to reduce time involved in
creating, integrating, and deploying reporting solutions. Free runtime info,
new features, or free trial, at: http://www.businessobjects.com/devxi/728
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
