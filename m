From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Support for NFSv4 READ + WRITE attribute cache consistency
Date: Mon, 23 Dec 2002 09:40:31 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200212230940.31399.trond.myklebust@fys.uio.no>
References: <Pine.LNX.4.44.0212202300440.3439-100000@home.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18QO8f-0006Wb-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Dec 2002 00:40:42 -0800
To: Linus Torvalds <torvalds@transmeta.com>
In-Reply-To: <Pine.LNX.4.44.0212202300440.3439-100000@home.transmeta.com>
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

On Saturday 21 December 2002 08:02, Linus Torvalds wrote:
> I _really_ don't like crud like this.
>
> NFS v4 is still not exactly common, but this change makes the kernel
> uncompilable if you have one of the common NFS clients but didn't enable
> NFS_V4 - those fields are used unconditionally, but they are only defined
> conditionally.
>
> Please don't do this, and please _do_ test with "normal" configurations.

Sorry. I'm still not quite finished looking into how to share the struct 
nfs_fattr between v2, v3, and v4 (in particular, I worry that we are 
currently being fairly careless with space) but I agree that breaking stock 
v2 and v3 in the process is not very productive behaviour 8-)...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
