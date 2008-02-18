From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: 2.6.24: RPC: bad TCP reclen 0x00020090 (large)
Date: Mon, 18 Feb 2008 16:05:09 +0300
Message-ID: <47B98285.3060503@msgid.tls.msk.ru>
References: <47B2F88D.7080300@msgid.tls.msk.ru> <20080218045812.f1dc6f71.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:22824 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760814AbYBRNFM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2008 08:05:12 -0500
In-Reply-To: <20080218045812.f1dc6f71.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andrew Morton wrote:
> (suitable cc added)

Thanks.  I was meant to sent it to linux-nfs originally, but
looks like i mistyped the address.

> (regression)

Now, after we did some more experiments with it, I don't think it's
a regression.  I'll post a bit more details in a few hours when the
ongoing testing finishes.  Thanks!

/mjt
