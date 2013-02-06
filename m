Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.opengridcomputing.com ([72.48.136.20]:36495 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757697Ab3BFQUq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2013 11:20:46 -0500
Message-ID: <51127DB1.6070804@opengridcomputing.com>
Date: Wed, 06 Feb 2013 09:58:41 -0600
From: Steve Wise <swise@opengridcomputing.com>
MIME-Version: 1.0
To: Yan Burman <yanb@mellanox.com>
CC: bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Tom Tucker <tom@opengridcomputing.com>
Subject: Re: NFS over RDMA crashing
References: <51127B3F.2090200@mellanox.com>
In-Reply-To: <51127B3F.2090200@mellanox.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2/6/2013 9:48 AM, Yan Burman wrote:
> When I moved to commit 79f77bf9a4e3dd5ead006b8f17e7c4ff07d8374e I was 
> no longer getting the server crashes,
> so the reset of my tests were done using that point (it is somewhere 
> in the middle of 3.7.0-rc2).
>

+tom tucker

I'd try going back a few kernels, like to 3.5.x and see if things are 
more stable.  If you find a point that works, then git bisect might help 
identify the regression.
