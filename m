Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58206 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751867AbcFOUzw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2016 16:55:52 -0400
Date: Wed, 15 Jun 2016 16:55:52 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/3] Deal with lost delegations and EKEYEXPIRED
Message-ID: <20160615205552.GH3848@fieldses.org>
References: <1466009529-3421-1-git-send-email-aweits@rit.edu>
 <20160615192116.GA3848@fieldses.org>
 <m2k2hqw8fj.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m2k2hqw8fj.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 15, 2016 at 03:36:48PM -0400, Andrew W Elble wrote:
> 
> > I take it you've tested these and verified delegations aren't getting
> > lost?
> 
> These patches have been running in our environment (based on 4.1.22)
> for quite a bit of time now with no lost delegations.
> 
> > Are there client changes needed as well, or is the client already
> > doing the right thing?
> 
> Change for client was taken as commit 99ade3c71b1e40e7174d6527709399a87f3d05e0

Got it, thanks.--b.
