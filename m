From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 2 / 2] Move NFS mount code from util-linux to
	nfs-utils
Date: Fri, 9 Jun 2006 16:21:42 +1000
Message-ID: <17545.4982.578027.897964@cse.unsw.edu.au>
References: <44887673.1030003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-list2-b.sourceforge.net ([10.3.1.8]
	helo=sc8-sf-list2.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FoaNo-0002KX-JW
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 23:22:12 -0700
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FoaNo-0000mI-FN
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 23:22:12 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FoaNn-0000ey-2y
	for nfs@lists.sourceforge.net; Thu, 08 Jun 2006 23:22:12 -0700
To: Amit Gud <agud@redhat.com>
In-Reply-To: message from Amit Gud on Thursday June 8
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

On Thursday June 8, agud@redhat.com wrote:
> 
> 
> AG
> -- 
> May the source be with you.
> http://www.cis.ksu.edu/~gud
> 
> Adds the support functions needed for mount and umount. This
> functionality will someday be available in the form of shared mount
> library. 

Is it really big enough to deserve a shared library? I suspect not.

> diff -uprN nfs-utils-1.0.8/support/include/nfs_paths.h nfs-utils-1.0.8-ag/support/include/nfs_paths.h
> --- nfs-utils-1.0.8/support/include/nfs_paths.h	1969-12-31 19:00:00.000000000 -0500
> +++ nfs-utils-1.0.8-ag/support/include/nfs_paths.h	2006-06-08 11:22:25.896916000 -0400
> @@ -0,0 +1,16 @@
> +#ifndef _NFS_PATHS_H
> +#define _NFS_PATHS_H
> +
> +#include <paths.h>
> +#define _PATH_FSTAB	"/etc/fstab"
> +#ifdef _PATH_MOUNTED
> +#define MOUNTED_LOCK	_PATH_MOUNTED "~"
> +#define MOUNTED_TEMP	_PATH_MOUNTED ".tmp"
> +#else
> +#define MOUNTED_LOCK	"/etc/mtab~"
> +#define MOUNTED_TEMP	"/etc/mtab.tmp"
> +#endif

How about:

 #ifndef _PATH_MOUNTED
 #define _PATH_MOUNTED "/etc/fstab"
 #endif
 #define MOUNTED_LOCK	_PATH_MOUNTED "~"
 #define MOUNTED_TEMP	_PATH_MOUNTED ".tmp"

Looks cleaner to me.


Thanks.
I'll look forward to the next version.

NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
