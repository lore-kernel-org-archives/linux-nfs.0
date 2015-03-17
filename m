Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:44771 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932183AbbCQKby (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Mar 2015 06:31:54 -0400
Date: Tue, 17 Mar 2015 03:31:45 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/5] NFS: Add READ_PLUS support
Message-ID: <20150317103145.GA27478@infradead.org>
References: <1426540666-31896-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1426540666-31896-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 16, 2015 at 05:17:41PM -0400, Anna Schumaker wrote:
>    Test     |   v4.1    | no READ_PLUS |  READ_PLUS
> ---------------------------------------------------
> generic/013 | 135s      |    143s      |    123s
> generic/075 |   4s      |     11s      |      4s
> generic/091 |   9s      |     16s      |     15s
> generic/112 |   4s      |      7s      |      6s
> generic/127 |  62s      |    117s      |    114s
> generic/213 | [not run] |      1s      |      1s
> generic/214 | [not run] |      0s      |      0s
> generic/228 | [not run] |      1s      |      2s
> generic/236 |   1s      |      1s      |      1s
> generic/263 |   4s      |      6s      |      8s
> generic/285 |   0s      |      1s      |      3s
> generic/315 | [not run] |      2s      |      1s
> ---------------------------------------------------
> Total       |  3:47.47  |    5:11.85   |  4:43.77

So why is 4.2 generally slower than 4.1?  I guess we really should look
into that first.
