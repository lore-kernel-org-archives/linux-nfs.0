From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Case sensitivity in NFS files
Date: Thu, 9 Oct 2008 14:36:18 -0400
Message-ID: <20081009183618.GA31168@fieldses.org>
References: <200810091839.49445.sojkam1@fel.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Michal Sojka <sojkam1-jQs2MHkdoM/twjQa/ONI9g@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37797 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753793AbYJISgU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Oct 2008 14:36:20 -0400
In-Reply-To: <200810091839.49445.sojkam1-jQs2MHkdoM/twjQa/ONI9g@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 09, 2008 at 06:39:49PM +0200, Michal Sojka wrote:
> I'm experiencing strange problem with case sensitivity of files on NFS3 
> filesystem. I want to backup my server to a NAS device. The server is:
> Linux rtime 2.6.25-gentoo-r8 #6 SMP Thu Oct 9 13:00:08 CEST 2008 i686
> and NAS is:
> Linux RtimeBackup 2.6.15 #722 Fri Sep 19 20:23:15 CST 2008 armv5tejl unknown

Do you know which filesystem it exports?  I haven't played with exports
of case-insensitive filesystems, but the behavior you saw would seem
consistent with that:

> On NFS, I sometimes get the following (neither "A" nor "a" files existed 
> before execution):
> 
> 1. open(A): Success
> 2. lstat(A): Success
> 3. lstat(a): Success

So we looked up "a" on the filesystem, and it found "A", since it
considers the two names the same.

> 4. unlink(a): Success

And the unlink worked too.

> 5. lstat(A): Stale NFS file handle

But we don't know that it resulted in deleting "A", so we send this stat
with the old filehandle and find the file's gone....

> 6. lstat(a): No such file or directory
> 
> This happens when the program is run for the first time. When I run it for the 
> second time, I get the expected output and file "A" is created.

The second time it's probably cached the non-existance of "a", so just
returns -ENOENT on lstat(a) instead of asking the server about it.

--b.

> After I 
> remove the A file, I get the "wrong" output again.
> 
> Does anybody know, what is causing this behavior?
> 
> Thanks
> Michal
> 
> P.S.: Please CC me when replying.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
