Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:51383 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932256AbcFTTB6 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jun 2016 15:01:58 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Chuck Lever'" <chuck.lever@oracle.com>, <linux-rdma@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net>
In-Reply-To: <20160620155751.10809.22262.stgit@manet.1015granger.net>
Subject: RE: [PATCH v3 00/25] NFS/RDMA client patches proposed for v4.8
Date: Mon, 20 Jun 2016 13:53:57 -0500
Message-ID: <030501d1cb25$19b759d0$4d260d70$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> Available in the "nfs-rdma-for-4.8" topic branch of this git repo:
> 
> git://git.linux-nfs.org/projects/cel/cel-2.6.git
> 
> Or for browsing:
> 
> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.8

Hey Chuck, I ran a quick regression of this code over iw_cxgb4.  Everything looks ok.

Tested-by: Steve Wise <swise@opengridcomputing.com>



