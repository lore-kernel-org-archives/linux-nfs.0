Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59488 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752042Ab2JOWZA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 18:25:00 -0400
Date: Mon, 15 Oct 2012 18:24:55 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: steved@redhat.com, bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/8] Junctions should inherit parent's export options
Message-ID: <20121015222455.GB30649@fieldses.org>
References: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 11, 2012 at 11:10:39AM -0400, Chuck Lever wrote:
> Following suggestions by Steve and Bruce, I've at long last
> implemented a mechanism by which junctions inherit the export
> options of their parent exports.

Thanks!

> While I was there, I took the opportunity to clean up the junction
> resolution logic.

Are bad mullets really specifically a 90's thing?  I thought they were
sort of timeless.

Anyway, that aside, looks reasonable to me.  ACK.

(I still can't get used to ACK.  Whenever I see it I wonder what the
writer's so startled about.  ACK!)

--b.
