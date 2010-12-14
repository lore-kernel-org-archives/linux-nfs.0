Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50657
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757540Ab0LNTxN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Dec 2010 14:53:13 -0500
Date: Tue, 14 Dec 2010 11:53:41 -0800 (PST)
Message-Id: <20101214.115341.71112815.davem@davemloft.net>
To: tj@kernel.org
Cc: linux-kernel@vger.kernel.org, jgarzik@pobox.com, benh@kernel.crashing.org,
        mchehab@infradead.org, netdev@vger.kernel.org, cbou@mail.ru,
        dwmw2@infradead.org, zbr@ioremap.net, gregkh@suse.de,
        bfields@fieldses.org, neilb@suse.de, aelder@sgi.com,
        xfs-masters@oss.sgi.com, cl@linux-foundation.org,
        penberg@cs.helsinki.fi, akpm@linux-foundation.org,
        netfilter-devel@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] workqueue: convert
 cancel_rearming_delayed_work[queue]() users to cancel_delayed_work_sync()
From: David Miller <davem@davemloft.net>
In-Reply-To: <4D078B6D.5060202@kernel.org>
References: <4D078B6D.5060202@kernel.org>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Tejun Heo <tj@kernel.org>
Date: Tue, 14 Dec 2010 16:21:17 +0100

> cancel_rearming_delayed_work[queue]() has been superceded by
> cancel_delayed_work_sync() quite some time ago.  Convert all the
> in-kernel users.  The conversions are completely equivalent and
> trivial.
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>

Acked-by: David S. Miller <davem@davemloft.net>
