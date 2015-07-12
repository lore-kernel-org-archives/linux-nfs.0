Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:34755 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbbGLObH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jul 2015 10:31:07 -0400
Received: by wgkl9 with SMTP id l9so8729011wgk.1
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 07:31:06 -0700 (PDT)
Subject: Re: [PATCH v1 02/12] xprtrdma: Raise maximum payload size to one
 megabyte
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20150709203242.26247.4848.stgit@manet.1015granger.net>
 <20150709204159.26247.44592.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagig@dev.mellanox.co.il>
Message-ID: <55A27A26.4030306@dev.mellanox.co.il>
Date: Sun, 12 Jul 2015 17:31:02 +0300
MIME-Version: 1.0
In-Reply-To: <20150709204159.26247.44592.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/9/2015 11:41 PM, Chuck Lever wrote:
> The point of larger rsize and wsize is to reduce the per-byte cost
> of memory registration and deregistration. Modern HCAs can typically
> handle a megabyte or more with a single registration operation.

Reviewed-By: Sagi Grimberg <sagig@mellanox.com>
