Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35170 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704AbcDZTnh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Apr 2016 15:43:37 -0400
Subject: Re: [PATCH v2 03/18] xprtrdma: Limit number of RDMA segments in
 RPC-over-RDMA headers
To: Chuck Lever <chuck.lever@oracle.com>, linux-rdma@vger.kernel.org,
        linux-nfs@vger.kernel.org
References: <20160425185956.3566.64142.stgit@manet.1015granger.net>
 <20160425192112.3566.30703.stgit@manet.1015granger.net>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <571FC4E5.1090001@grimberg.me>
Date: Tue, 26 Apr 2016 22:43:33 +0300
MIME-Version: 1.0
In-Reply-To: <20160425192112.3566.30703.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

8 seems like a fair upper bound if that makes things
simpler and guarantee forward-progress...

Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
