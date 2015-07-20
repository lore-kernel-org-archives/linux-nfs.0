Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([72.48.136.20]:43964 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752901AbbGTR1u (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jul 2015 13:27:50 -0400
From: "Steve Wise" <swise@opengridcomputing.com>
To: "'Sagi Grimberg'" <sagig@mellanox.com>, <linux-nfs@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>
Cc: "'Chuck Lever'" <chuck.lever@oracle.com>
References: <1437411614-29722-1-git-send-email-sagig@mellanox.com>
In-Reply-To: <1437411614-29722-1-git-send-email-sagig@mellanox.com>
Subject: RE: [PATCH RFC] svcrdma: Fix possible over population fast_reg_page_list
Date: Mon, 20 Jul 2015 12:27:51 -0500
Message-ID: <011701d0c311$67d66ab0$37834010$@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Sagi Grimberg
> Sent: Monday, July 20, 2015 12:00 PM
> To: linux-nfs@vger.kernel.org; linux-rdma@vger.kernel.org
> Cc: Chuck Lever; Steve Wise
> Subject: [PATCH RFC] svcrdma: Fix possible over population fast_reg_page_list
> 
> When accounting the needed_pages, we need to look into
> the page_list->max_page_list_len and not the global
> context xprt->sc_frmr_pg_list_len.
> 
> Signed-off-by: Sagi Grimberg <sagig@mellanox.com>

Reviewed-by: Steve Wise <swise@opengridcomputing.com>



