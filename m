Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:56159 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751446AbaDOUUa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2014 16:20:30 -0400
Message-ID: <534D9491.5010003@opengridcomputing.com>
Date: Tue, 15 Apr 2014 15:20:33 -0500
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH 0/8] NFS/RDMA patches for review
References: <20140414220041.20646.63991.stgit@manet.1015granger.net> <534D9373.3050406@opengridcomputing.com>
In-Reply-To: <534D9373.3050406@opengridcomputing.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

My testing was with the default memory registration mode by the way.  
Over mlx4 and cxgb4.

Steve.

On 4/15/2014 3:15 PM, Steve Wise wrote:
>
> Tested-by: Steve Wise <swise@opengridcomputing.com>
>
> -- 
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

