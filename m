Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:57463 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751499AbaGJTTY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 15:19:24 -0400
Message-ID: <53BEE740.3070404@opengridcomputing.com>
Date: Thu, 10 Jul 2014 14:19:28 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 00/21] NFS/RDMA client patches for 3.17
References: <20140709163326.3496.37893.stgit@manet.1015granger.net>
In-Reply-To: <20140709163326.3496.37893.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Chuck,

I tested this series and it tested ok for me.  I tested NFS v3 and v4 
over cxgb4 and mlx4:  cthon, iozone, fio, and xfs.  No regressions seen.

---

Tested-by: Steve Wise <swise@opengridcomputing.com>

