From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problems with crossmnt since 1.2.1
Date: Mon, 1 Mar 2010 15:40:10 -0500
Message-ID: <20100301204010.GE23539@fieldses.org>
References: <20100228100643.GG26178@teal.hq.k1024.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Iustin Pop <iusty-JC6qDa14zzLYtjvyW6yDsg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55758 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750947Ab0CAUjE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Mar 2010 15:39:04 -0500
In-Reply-To: <20100228100643.GG26178-kWFYwFCQMdQkLqoNrXjPMti2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 28, 2010 at 11:06:43AM +0100, Iustin Pop wrote:
> Since nfs-utils 1.2.1, there are some problems with crossmnt usage. See
> Debian bug http://bugs.debian.org/567546, but in short the problem seems
> to be that sub-mounts (/a/b) take the top-level mount (/a) options
> instead of their own, due to a bug in how mountd generates the crossmnt
> subexports.
> 
> I checked that reverting the write_secinfo changes in commit
> bc0a6ab03089fc1ea4fea26ed9635c2cc918b01b fix the issue, but that might
> only be a side effect, not the actual cause.
> 
> A short test:
> - have /a and /a/b exported, with different flags (e.g. ro on /a, rw on
>   /a/b)
> - restart the mountd, clear exports, etc.
> - try a mount on the client of /a/b, it gets readonly
> - umount & remount, it's now r/w
> - however, clearing the kernel export table (exportfs -f), makes the
>   next mount again get read-only 
> 
> Disabling crossmnt fixes the issue completely, so I would venture to
> guess that the subexports creation code has some issue, but I don't know
> enough of this to be able to debug it.

Thanks for the report.  What's the latest nfs-utils version you've
tested?

On a quick skim of the latest code I see one clear bug
(path[strlen(path)] will never be '/'!), but that should have caused
crossmnt to never get enforced at all rather than to override anything.

Could you retest the latest from the upstream git, with this patch
applied, and see if the problem is still present?

Then if it is I'll try to go reproduce it myself....

--b.

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index d63e10a..ff27bbf 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -619,7 +619,7 @@ static int is_subdirectory(char *subpath, char *path)
 	int l = strlen(path);
 
 	return strcmp(subpath, path) == 0
-		|| (strncmp(subpath, path, l) == 0 && path[l] == '/');
+		|| (strncmp(subpath, path, l) == 0 && subpath[l] == '/');
 }
 
 static int path_matches(nfs_export *exp, char *path)
