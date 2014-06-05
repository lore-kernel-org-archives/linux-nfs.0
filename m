Return-Path: linux-nfs-owner@vger.kernel.org
Received: from andre.telenet-ops.be ([195.130.132.53]:38211 "EHLO
	andre.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbaFEHXN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Jun 2014 03:23:13 -0400
Message-ID: <53901ADB.9020405@acm.org>
Date: Thu, 05 Jun 2014 09:23:07 +0200
From: Bart Van Assche <bvanassche@acm.org>
MIME-Version: 1.0
To: Steve Wise <swise@opengridcomputing.com>, bfields@fieldses.org
CC: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
        tom@opengridcomputing.com
Subject: Re: [PATCH] svcrdma: Fence LOCAL_INV work requests
References: <20140602171433.31076.5634.stgit@build.ogc.int>
In-Reply-To: <20140602171433.31076.5634.stgit@build.ogc.int>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/02/14 19:14, Steve Wise wrote:
> Fencing forces the invalidate to only happen after all subsequent send
> work requests have been completed.

Shouldn't that read "prior" instead of "subsequent" ?

Bart.
