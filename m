From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [PATCH 1/2] VFS: Make d_materialise_unique() enforce
	directory	uniqueness
Date: Thu, 19 Oct 2006 22:51:20 +0200
Message-ID: <E1GaerI-0007Af-00@dorka.pomaz.szeredi.hu>
References: <20061019171113.8593.8585.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: torvalds@osdl.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, viro@ftp.linux.org.uk
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gaerq-0007ld-UI
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 13:51:54 -0700
Received: from mail-gw2.sa.eol.hu ([212.108.200.109])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gaerq-0006vf-Cx
	for nfs@lists.sourceforge.net; Thu, 19 Oct 2006 13:51:56 -0700
To: Trond.Myklebust@netapp.com
In-reply-to: <20061019171113.8593.8585.stgit@lade.trondhjem.org> (message from
	Trond Myklebust on Thu, 19 Oct 2006 13:11:13 -0400)
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

> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> If the caller tries to instantiate a directory using an inode that already
> has a dentry alias, then we attempt to rename the existing dentry instead
> of instantiating a new one. Fail with an ELOOP error if the rename would
> affect one of our parent directories.
> 
> This behaviour is needed in order to avoid issues such as
> 
>   http://bugzilla.kernel.org/show_bug.cgi?id=7178
>

This looks like a stale patch.  You posted one on -fsdevel that did
i_mutex locking as well.

Miklos

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
