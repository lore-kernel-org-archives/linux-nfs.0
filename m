Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:57504 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752575AbaGJTvM convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2014 15:51:12 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: <bfields@fieldses.org>
Cc: <linux-rdma@vger.kernel.org>, <linux-nfs@vger.kernel.org>, <tom@ogc.us>
References: <20140709184914.22217.59770.stgit@build.ogc.int>
In-Reply-To: <20140709184914.22217.59770.stgit@build.ogc.int>
Subject: RE: [PATCH] svcrdma: send_write() must not overflow the device's max sge
Date: Thu, 10 Jul 2014 14:51:16 -0500
Message-ID: <005d01cf9c78$4fa621d0$eef26570$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I tested this with nfsv3 and v4, over cxgb4 and mlx4: cthon04, iozone, fio, and xfs.  No regressions seen...

Steve.

