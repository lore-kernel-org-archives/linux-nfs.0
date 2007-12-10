From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: V3 ACCESS call fails after server reboot
Date: Mon, 10 Dec 2007 12:41:17 -0500
Message-ID: <20071210174117.GK17209@fieldses.org>
References: <20071210172004.GA8094@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39758 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753029AbXLJRlT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Dec 2007 12:41:19 -0500
In-Reply-To: <20071210172004.GA8094@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 10, 2007 at 06:20:04PM +0100, Frank van Maarseveen wrote:
> Tested on 2.6.22.10 and 2.6.23.9, client and server running same version.
> export options: rw,sync,no_root_squash,no_subtree_check,mp
> 
> After a substantial amount of time (days) but also after a server
> reboot a process loses access to its current working directory when
> access to a parent directory two (or more) levels up has been revoked:
> 
> 	$ cd /mnt
> 	$ mkdir -p a/b/c
> 	$ cd a/b/c
> 	$ chmod 0 ../..
> 	$ ls -a
> 	. ..
> 	$
> 		(wait a loong time or reboot server)
> 	$ ls -a
> 	ls: .: Permission denied
> 
> Network traffic capture showed a V3 ACCESS call for above "." failing
> on the server after the reboot with NFS3ERR_ACCES. It succeeded before.
> 
> I have the impression the server is internally rechecking the entire
> path when its caches have been flushed. This behavior is problematic
> for daemons which change uid, for example.

What are your export options?  (Do you have nosubtreecheck turned on?)

--b.

> Note on a different (client) issue: Trying the above with the direct
> parent (i.e. chmod 0 ..) fails with ESTALE due to lookup of "c" in "b"
> to which access has been revoked (no reboot needed):
> 
> 	$ mkdir -p a/b/c
> 	$ cd a/b/c
> 	$ chmod 0 ..
> 	$ ls -a
> 	ls: .: Stale NFS file handle
> 	$ chmod 755 ..
> 	$ ls -a
> 	.  ..
> 	$
> 
> -- 
> Frank
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
