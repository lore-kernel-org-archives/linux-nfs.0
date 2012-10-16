Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipcop.bitmover.com ([192.132.92.15]:41395 "EHLO
	mail.bitmover.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752251Ab2JPBwL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Oct 2012 21:52:11 -0400
Date: Mon, 15 Oct 2012 18:52:08 -0700
From: Larry McVoy <lm@bitmover.com>
To: George Spelvin <linux@horizon.com>
Cc: lm@bitmover.com, Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: kernel BUG at /build/buildd/linux-3.2.0/fs/lockd/clntxdr.c:226!
Message-ID: <20121016015208.GE11148@bitmover.com>
References: <4FA345DA4F4AE44899BD2B03EEEC2FA90923ED96@SACEXCMBX04-PRD.hq.netapp.com>
 <20121016014824.4952.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121016014824.4952.qmail@science.horizon.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 15, 2012 at 09:48:24PM -0400, George Spelvin wrote:
> It's NFSv2 server support that I, and I believe Larry, are interested
> in preserving, in order to provide services to ancient clients.

Yup.  Exactly right.
-- 
---
Larry McVoy                lm at bitmover.com           http://www.bitkeeper.com
