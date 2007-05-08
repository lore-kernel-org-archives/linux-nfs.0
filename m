From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH] introduce version field to struct nfs_clone_mount
Date: Tue, 08 May 2007 08:10:29 -0400
Message-ID: <1178626229.10325.155.camel@moss-spartans.epoch.ncsc.mil>
References: <1178560513.3898.32.camel@dhcp59-235.rdu.redhat.com>
	<20070508094120.GA11417@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, selinux@tycho.nsa.gov,
	Eric Paris <eparis@redhat.com>, James Morris <jmorris@namei.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlOWf-0006gm-8P
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 05:10:41 -0700
Received: from zombie.ncsc.mil ([144.51.88.131] helo=jazzdrum.ncsc.mil)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HlOWh-0002ix-Ku
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 05:10:44 -0700
In-Reply-To: <20070508094120.GA11417@infradead.org>
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

On Tue, 2007-05-08 at 10:41 +0100, Christoph Hellwig wrote:
> On Mon, May 07, 2007 at 01:55:13PM -0400, Eric Paris wrote:
> > When selinux attempts to do its part of mounting a new FS it checks the
> > mount data for selinux context information.  For most FS's this is a
> > text string but for NFS this is a data blob (struct nfs_mount_data)
> > Version 6 and later of this struct have a context field which selinux
> > can use to pass context information from userspace to where it is used
> > by selinux (security/selinux/hooks.c:try_context_mount())
> 
> selinux has no business sniffing mount data at all, so the proper fix
> is to remove this code entirely.  If selinux wants to have it's own
> mount options it needs either:
> 
>  - get a mount option at the vfs level.  These are only bit flags, so
>    it's probably not useful for what selinux is currently doing
>  - hook into every filesystem, which is the part of the kernel controlling
>    the text (or in a few cases binary) options.
> 
> > The code in try_context_mount then casts the data to a struct
> > nfs_mount_data.
> 
> Note that this will soon stop to work completely because nfs is moving
> towards proper ascii mount options.

The context= mount support in selinux already deals with ascii mount
options; it is only the binary ones that need special handling.  And
this isn't new functionality in selinux - it went upstream in 2004.
Eric's patch is just fixing this corner case, not introducing new
functionality.

http://marc.info/?l=git-commits-head&m=107695907809907&w=2
http://marc.info/?l=git-commits-head&m=107695907911284&w=2
http://marc.info/?l=git-commits-head&m=107695950928758&w=2

-- 
Stephen Smalley
National Security Agency


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
