Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:49552 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751326AbdH3MPX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Aug 2017 08:15:23 -0400
Date: Wed, 30 Aug 2017 05:15:22 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Justin Mitchell <jumitche@redhat.com>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] Move nfs.conf to a shared library
Message-ID: <20170830121522.GA16669@infradead.org>
References: <1504093866.10850.1.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1504093866.10850.1.camel@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 30, 2017 at 12:51:06PM +0100, Justin Mitchell wrote:
> Moving the config parsing code out to a shared library fixes both
> of these issues with minimal code changes. I appreciate that the 
> API this library presents is less than ideal, it was left this way
> to reduce code changes at this point, and i welcome suggestions for
> a sympathetic approach to improving it.

The general shard code approach look good, but is there any good
reason not to merge libnfsidmap into nfs-utils and make it a
static (or at least a private shared) library instead of introducing
a new ABI?
