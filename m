From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/18] kernel NSM support for IPv6 (take 2)
Date: Wed, 5 Nov 2008 14:49:55 -0500
Message-ID: <20081105194955.GA1455@fieldses.org>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:57246 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757632AbYKETt5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 14:49:57 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 05, 2008 at 12:19:18PM -0500, Chuck Lever wrote:
> Hi Bruce-
> 
> Here are patches to implement IPv6 support for the kernel's NSM.
> These are different enough from the last pass that you should look
> these over again.  I've tried to respond to your previous comments,
> and I've provided some additional clean up and enhancement.
> 
> I've tested these patches to ensure that NFSv2/v3 lock recovery over
> IPv4 continues to work with lockd IPv6 support enabled (by a later
> patch).
> 
> Please consider these for 2.6.29.

Thanks, I'll take a look.

By the way, I did some miscellaneous nsm cleanup a few months ago and
never got around to sending it out.  I'll pass that along in a moment.

--b.
