From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] NFS: Add the mount option "nosharecache"
Date: Fri, 18 May 2007 09:20:02 -0400
Message-ID: <1179494402.6488.13.camel@heimdal.trondhjem.org>
References: <17994.32412.173039.15055@notabene.brown>
	<20070517021318.32447.94991.stgit@heimdal.trondhjem.org>
	<1179457946.3726.3.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, Paul Krizak <paul.krizak@amd.com>,
	nfs@lists.sourceforge.net
To: Ian Kent <raven@themaw.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hp2NU-00062M-1i
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 06:20:16 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hp2NV-0008QZ-Hf
	for nfs@lists.sourceforge.net; Fri, 18 May 2007 06:20:18 -0700
In-Reply-To: <1179457946.3726.3.camel@raven.themaw.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 2007-05-18 at 11:12 +0800, Ian Kent wrote:
> How will the "read-only bind mounts" VFS changes affect this?

They won't. Dave's patches move the MS_RDONLY flag out of the
super_block and into the vfsmount. That makes it possible to share the
same super_block (and hence the same inode/dentry caches) between a
read-only mount and a read-write mount.

If you want to change any of the other flags, though, you will still
have to use nosharecache to do so: for instance if you want to set up a
'noac' mount for one directory, but want all other directories to cache
attributes, then you will have to mount the "noac" directory using the
nosharecache flag.

> When the fscache patches are merged how will this it be affect by this?

I'd suggest simply returning an error if the user tries to set both
fscache and nosharecache. David's reasoning is still valid: if two
superblocks try to write to the same fscache inode, then caching havoc
will ensue.

Note, however, that the fscache patches already have a problem. I found
out recently that RHEL-5 uses NFS_MOUNT_FSCACHE==0x4000, which is taken
by NFS_MOUNT_NORDIRPLUS in mainline.

Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
