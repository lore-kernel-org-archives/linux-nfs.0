Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38932 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932317AbbBDIQ3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Feb 2015 03:16:29 -0500
Date: Wed, 4 Feb 2015 00:16:24 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Olga.Kornievskaia@netapp.com
Subject: Re: [PATCH 1/2] NFSv4.1: Ask for no delegation on OPEN if using
 O_DIRECT
Message-ID: <20150204081624.GA16543@infradead.org>
References: <1423000784-93180-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1423000784-93180-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 03, 2015 at 04:59:43PM -0500, Trond Myklebust wrote:
> If we're using NFSv4.1, then we have the ability to let the server know
> whether or not we believe that returning a delegation as part of our OPEN
> request would be useful.
> The feature needs to be used with care, since the client sending the request
> doesn't necessarily know how other clients are using that file, and how
> they may be affected by the delegation.
> For this reason, our initial use of the feature will be to let the server
> know when the client believes that handing out a delegation would not be
> useful.
> The first application for this function is when opening the file using
> O_DIRECT.

I can't see why O_DIRECT openers would not want to use a delegation, can you
explain your rationale?

