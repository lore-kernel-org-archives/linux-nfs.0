From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: Re: [NFS] NFSv2/3 broken exporting/mounting (permission denied) in
	2.6.24-rc4
Date: Fri, 7 Dec 2007 15:32:42 -0500
Message-ID: <200712072032.lB7KWgTr015620@agora.fsl.cs.sunysb.edu>
References: <20071207200655.GD2204@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43652 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758200AbXLGUdB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2007 15:33:01 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J0jsZ-0007cs-2E
	for linux-nfs@vger.kernel.org; Sat, 08 Dec 2007 07:32:59 +1100
In-reply-to: Your message of "Fri, 07 Dec 2007 15:06:55 EST."
	<20071207200655.GD2204@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In message <20071207200655.GD2204@fieldses.org>, "J. Bruce Fields" writes:
> On Fri, Dec 07, 2007 at 03:00:13PM -0500, Erez Zadok wrote:
[...]
> Those files are actually in a separate filesystem (of type "nfsd") which
> is supposed to be mounted on /proc/fs/nfsd/.   So that mount must have
> failed in the bad case?  It's not immediately obvious to me what this
> patch has to do with that.  Hm.

Yes, it is indeed a separate mount in both cases, but in the broken case,
/proc/fs/nfsd is empty.

The patch in question introduces a proc ->d_revalidate method which does
this:

static int proc_revalidate_dentry(struct dentry *dentry, struct nameidata *nd)
{
	d_drop(dentry);
	return 0;
}

I'm not sure why it drops the dentry and then returns OK to the VFS; is it
to force the VFS to revalidate the dentry?  In that case, I think it should
return -ESTALE.  I also don't know why /proc needs a ->d_revalidate in the
first place (it was fine up until now).  Perhaps what proc does now is
correct, but its behavior has changed such that nfsd's /proc/fs/nfsd needs
to do something different (like grab an extra dentry ref?).

Anyway, if I comment out the d_drop line in proc_revalidate_dentry, or
remove proc's ->d_revalidate method, nfs exporting works again.

Someone more familiar with this patch and /proc should investigate.  Until
then, nfsv2/3 exporting are broken in 2.6.24-rc4.

> --b.

Cheers,
Erez.

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

