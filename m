From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/17] svcrdma: RDMA transport driver close path cleanup
Date: Tue, 6 May 2008 17:46:51 -0400
Message-ID: <20080506214651.GP13484@fieldses.org>
References: <1209745721600-git-send-email-tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40648 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751789AbYEFVqw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2008 17:46:52 -0400
In-Reply-To: <1209745721600-git-send-email-tom@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 11:28:24AM -0500, Tom Tucker wrote:
> Bruce:
> 
> This patchset fixes a number of defects in the close path of the SVCRDMA
> transport provider. The defects were found by injecting errors on the 
> transport at random intervals while running concurrent iozone tests on
> IB and iWARP mounts. With this set of patches applied I was able to run
> the the above tests for several hours without causing a crash or leaking
> resources. The transport recovers correctly on a client reconnect.
> 
> This patchset is based on 2.6 top of tree, however, I think these fixes are
> good candidates for a 2.6.25 dot release as well.

It may be a lot to try to get in to 2.6.25.

Anyway, my (unfortunately superficial) review doesn't catch anything
serious.  Up to you whether you'd like this version submitted or whether
you'd like to fix up those small things first.

--b.
