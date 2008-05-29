From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 0/11] svcrdma: WR context management bug fixes and cleanup
Date: Thu, 29 May 2008 15:26:22 -0700
Message-ID: <adaej7koigh.fsf@cisco.com>
References: <12120836962076-git-send-email-tom@opengridcomputing.com>
	<20080529221000.GE24018@fieldses.org>
	<1212099937.22478.3.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, swise@opengridcomputing.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:6389 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755610AbYE2Wfh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 May 2008 18:35:37 -0400
In-Reply-To: <1212099937.22478.3.camel-SMNkleLxa3ZimH42XvhXlA@public.gmane.org> (Tom Tucker's message
	of "Thu, 29 May 2008 17:25:37 -0500")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 > I'm inclined to say "no". But I'd like to hear if anyone out there is
 > dead in the water due to a bug in the 2.6.26 version.

To be honest I haven't had a chance to do much NFS/RDMA testing with the
current 2.6.26 tree.  But last I looked there were no major regressions
at least (still open issues I think, but definitely better than 2.6.25)
