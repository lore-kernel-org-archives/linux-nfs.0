From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] introduce version field to struct nfs_clone_mount
Date: Tue, 8 May 2007 10:41:20 +0100
Message-ID: <20070508094120.GA11417@infradead.org>
References: <1178560513.3898.32.camel@dhcp59-235.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: sds@tycho.nsa.gov, nfs@lists.sourceforge.net,
	selinux@tycho.nsa.gov
To: Eric Paris <eparis@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlMCA-0007Le-Em
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 02:41:22 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HlMCC-000569-Vm
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 02:41:25 -0700
In-Reply-To: <1178560513.3898.32.camel@dhcp59-235.rdu.redhat.com>
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

On Mon, May 07, 2007 at 01:55:13PM -0400, Eric Paris wrote:
> When selinux attempts to do its part of mounting a new FS it checks the
> mount data for selinux context information.  For most FS's this is a
> text string but for NFS this is a data blob (struct nfs_mount_data)
> Version 6 and later of this struct have a context field which selinux
> can use to pass context information from userspace to where it is used
> by selinux (security/selinux/hooks.c:try_context_mount())

selinux has no business sniffing mount data at all, so the proper fix
is to remove this code entirely.  If selinux wants to have it's own
mount options it needs either:

 - get a mount option at the vfs level.  These are only bit flags, so
   it's probably not useful for what selinux is currently doing
 - hook into every filesystem, which is the part of the kernel controlling
   the text (or in a few cases binary) options.

> The code in try_context_mount then casts the data to a struct
> nfs_mount_data.

Note that this will soon stop to work completely because nfs is moving
towards proper ascii mount options.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
