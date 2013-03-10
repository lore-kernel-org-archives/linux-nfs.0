Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.tpi.com ([70.99.223.143]:1644 "EHLO mail.tpi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752836Ab3CJSUI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 10 Mar 2013 14:20:08 -0400
Message-ID: <513CCED3.7080705@canonical.com>
Date: Sun, 10 Mar 2013 12:20:03 -0600
From: Tim Gardner <tim.gardner@canonical.com>
MIME-Version: 1.0
To: Tom Tucker <tom@opengridcomputing.com>
CC: linux-kernel@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, Tom Tucker <tom@ogc.us>,
        Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Shani Michaeli <shanim@mellanox.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH linux-next] SUNRPC: rpcrdma_register_default_external:
 Dynamically allocate ib_phys_buf
References: <1362929953-63785-1-git-send-email-tim.gardner@canonical.com> <513CBFD6.1000504@opengridcomputing.com>
In-Reply-To: <513CBFD6.1000504@opengridcomputing.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/10/2013 11:16 AM, Tom Tucker wrote:
> 
> This is the result of 2773395b34883fe54418de188733a63bb38e0ad6. Steve
> might want to weigh in on this since it was done for performance reasons.
> 
> Tom
> 

It seems to me that the cost of a kmalloc()/kfree() is negligible
compared to network speeds.

rtg
-- 
Tim Gardner tim.gardner@canonical.com
