From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Doc for adding new NFS export option
Date: Wed, 9 Jul 2008 11:02:34 -0400
Message-ID: <20080709150234.GA5780@fieldses.org>
References: <48718FF4.4030200@cse.unsw.edu.au> <18545.47041.516146.605353@notabene.brown> <4874263B.50902@cse.unsw.edu.au> <18548.14177.493986.264761@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shehjar Tikoo <shehjart-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:37176 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755708AbYGIPCj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Jul 2008 11:02:39 -0400
In-Reply-To: <18548.14177.493986.264761-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 09, 2008 at 01:58:25PM +1000, Neil Brown wrote:
> NFSv3 writes do not have to be stable.  The client will usually
> request DATA_UNSTABLE, and then send a COMMIT a while later.  This
> should give the filesystem time to do delayed allocation.
> NFSv4 is much the same.
> NFSv2 does require stable writes, but it should not be used by anyone
> interested in good write performance on large files.
> 
> It isn't clear to me that this is something that should be an option
> in /etc/exports.
> When would a sysadmin want to turn it off?  Or if a sysadmin did want
> control, sure the level of control required would be the size of the
> preallocation. 

An export option might be a useful for testing as a way to get quick
before vs after comparisons.

But, yeah, before merging it into mainline it'd be better if it was
something that could safely just be turned on all the time.

--b.

> 
> I would strongly suggest demonstrating that you can improve some
> measure of performance using preallocation before you even begin to
> think about having an export option to select it.
> 
> NeilBrown
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
