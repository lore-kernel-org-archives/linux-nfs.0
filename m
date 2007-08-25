From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/9] mount.nfs: Don't allow the user to specify
 addr= or clientaddr=.
Date: Sat, 25 Aug 2007 07:07:10 -0400
Message-ID: <20070825070710.67e0be3f.jlayton@redhat.com>
References: <20070824171116.10418.56059.stgit@monet.1015granger.net>
	<20070824172529.GA6690@fieldses.org> <46CF2088.3080903@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>, neilb@suse.de,
	nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOtU3-0004Yb-0g
	for nfs@lists.sourceforge.net; Sat, 25 Aug 2007 04:07:15 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOtU7-0004ky-4F
	for nfs@lists.sourceforge.net; Sat, 25 Aug 2007 04:07:19 -0700
In-Reply-To: <46CF2088.3080903@oracle.com>
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

On Fri, 24 Aug 2007 14:16:40 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> J. Bruce Fields wrote:
> > On Fri, Aug 24, 2007 at 01:11:16PM -0400, Chuck Lever wrote:
> >> The current mount.nfs implementation doesn't allow users to specify their
> >> own addr= or clientaddr= option.
> > 
> > Don't we need clientaddr= in some cases to get the callback channel
> > working?
> 
> The mount.nfs command adds a clientaddr option of its own before doing 
> the syscall.  The point of the patch is to prevent passing in a 
> user-created clientaddr=.
> 
> Does anyone know of a use case where an exposed clientaddr= is needed?
> 

Mounting through a NAT router. The callback address that mount.nfs adds
might not be reachable by the server, so the user will need to specify
it.

> >> The new string-based interface does allow this, even though nfs(5)
> >> does not document 'addr=' and specifically forbids adding
> >> 'clientaddr='.
> > 
> > It says that it's currently ignored, which isn't the same as forbidding
> > it.
> 
> nfs(5) is likely incorrect.  It's arguable what "currently ignored" 
> means -- it probably means the mount command ignores it, if specified, 
> and uses its own address anyway.
> 

mount.nfs should definitely pass this info to the kernel (if it doesn't
already).

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
