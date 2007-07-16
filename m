From: Jeff Layton <jlayton@redhat.com>
Subject: Re: maintainership question about nfs-utils/util/mount
Date: Mon, 16 Jul 2007 11:42:15 -0400
Message-ID: <20070716114215.81e2ac37.jlayton@redhat.com>
References: <468EA263.5010909@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IASiB-0004cQ-Qg
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 08:42:12 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IASiF-0001uU-4D
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 08:42:15 -0700
In-Reply-To: <468EA263.5010909@oracle.com>
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

On Fri, 06 Jul 2007 16:13:23 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> I'm looking at nfs-utils/utils/mount in order to patch in support for 
> passing a string of mount options to the kernel instead of an 
> nfs_mount_data.
> 
> In mount.c, main() invokes nfsmount() in nfsmount.c.  nfsmount() defines 
> a structure on the stack called "data", then returns a pointer to "data" 
> which is then passed to the kernel by main().
> 
> I think the only way this continues to work is that there are three 1024 
> character buffers defined in nfsmount()'s stack frame before "data," 
> which places "data" far enough up the stack that subsequent function 
> calls in main() don't smash it.
> 
> Although this doesn't cause bad behavior today, it needs to be fixed to 
> prevent future changes from breaking things badly.
> 

In the git tree I'm looking at, "data" is declared static. Does that protect
it from getting smashed?

> Also found an interesting error message in here:
> 
>    permission died - no match for fstab
> 
> Should probably be "permission denied".  I'm not really sure what "no 
> match for fstab" means, but looking at the context, this message appears 
> if a non-root user tries to mount something that isn't already listed in 
> /etc/fstab.
> 
> What's the current blessed procedure for sending patches and fixes for 
> this particular code?  Mail to agud@redhat.com (last touch rule, and 
> author of mount.c) is rejected.
> 


-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
