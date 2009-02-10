From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: processes in D state too long too often
Date: Tue, 10 Feb 2009 11:02:58 -0500
Message-ID: <20090210160258.GD29075@fieldses.org>
References: <W322075763216621234232313@webmail8>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "Gary L. Grobe" <gary-QhKe0p0S2m1eoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:40655 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754583AbZBJQCv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Feb 2009 11:02:51 -0500
In-Reply-To: <W322075763216621234232313@webmail8>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 10, 2009 at 02:18:33AM +0000, Gary L. Grobe wrote:
> 
> >>The more likely explanation is that you just switched to a more recent
> >>distro where "sync" (as opposed to "async") is the option.  Depending on
> >>workload, "async" may improve performance a great deal, at the expense
> >>of possible data corruption on server reboot!
> >>
> >>If you're doing a lot of writing and using NFSv2, then switching to
> >>NFSv3 may give you performance close to the "async" performance without
> >>the corruption worries.
> 
> Just a small update about our rollback I need to correct. Turns out our problem has been solved by going with the 2.6.20-r10 of the gentoo-sources patched kernel. Although gentoo marks this as unstable for amd64, it's working fine. I've made no other changes than going back a few versions on the kernel and adjusting the .config w/ the same settings. 
> 
> Tomorrow I'll likely give the next marked stable patched gentoo-sources kernel another try which was 2.6.24-r10 and recheck my configs and try to gather anything else I can gather from it.

Sounds good, thanks.

--b.
