From: "Gary L. Grobe" <gary-QhKe0p0S2m1eoWH0uzbU5w@public.gmane.org>
Subject: Re:   processes in D state too long too often
Date: Tue, 10 Feb 2009 02:18:33 +0000
Message-ID: <W322075763216621234232313@webmail8>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	"Andrew Morton" <akpm@linux-foundation.org>
To: "Gary L. Grobe" <gary-QhKe0p0S2m1eoWH0uzbU5w@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from omr2.networksolutionsemail.com ([205.178.146.52]:50196 "EHLO
	omr2.networksolutionsemail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752553AbZBJCSf convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Feb 2009 21:18:35 -0500
Received: from mail.networksolutionsemail.com (ns-omr2.mgt.netsol.com [10.49.6.65])
	by omr2.networksolutionsemail.com (8.13.6/8.13.6) with SMTP id n1A2IXT7007298
	for <linux-nfs@vger.kernel.org>; Mon, 9 Feb 2009 21:18:33 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


>>The more likely explanation is that you just switched to a more recent
>>distro where "sync" (as opposed to "async") is the option.  Depending on
>>workload, "async" may improve performance a great deal, at the expense
>>of possible data corruption on server reboot!
>>
>>If you're doing a lot of writing and using NFSv2, then switching to
>>NFSv3 may give you performance close to the "async" performance without
>>the corruption worries.

Just a small update about our rollback I need to correct. Turns out our problem has been solved by going with the 2.6.20-r10 of the gentoo-sources patched kernel. Although gentoo marks this as unstable for amd64, it's working fine. I've made no other changes than going back a few versions on the kernel and adjusting the .config w/ the same settings. 

Tomorrow I'll likely give the next marked stable patched gentoo-sources kernel another try which was 2.6.24-r10 and recheck my configs and try to gather anything else I can gather from it.


