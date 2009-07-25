Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:46138 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751842AbZGYQvw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 25 Jul 2009 12:51:52 -0400
Subject: Re: Slower performance with lookupcache (2.6.30.2)
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Simon Kirby <sim@hostway.ca>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20090724231300.GA572@hostway.ca>
References: <20090724231300.GA572@hostway.ca>
Content-Type: text/plain
Date: Sat, 25 Jul 2009 12:51:43 -0400
Message-Id: <1248540703.6139.106.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2009-07-24 at 16:13 -0700, Simon Kirby wrote:
> The lookupcache here seems to be increasing initial performance but then
> seems to slow down cached performance by causing more getattrs than with
> no lookupcache, perhaps for revalidation tests.

Yes. This is expected behaviour.

When you look up a dentry, you are also retrieving its attributes, so
the stat() call, can be entirely handled by the single LOOKUP rpc call.

If you are caching the dentries, then your stat() call doesn't need to
do a lookup, but it still needs to return valid attributes. Since
acregmin=3 seconds, then your test is likely to have to revalidate a
couple of times. However as long as there are no changes to the file,
then the attribute caching algorithm should get progressively more
aggressive. I'd therefore expect that if you change that to 'repeat 10'
or so, then the lookupcache=all/positive cases should show an
improvement.

   Trond

