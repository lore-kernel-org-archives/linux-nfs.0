Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:54117 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752383AbbCYIzw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 04:55:52 -0400
Date: Wed, 25 Mar 2015 01:55:50 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSv4.1: Don't cache deviceids that have no
 notifications
Message-ID: <20150325085550.GA23258@infradead.org>
References: <1425931503-37261-1-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-2-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-3-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-4-git-send-email-trond.myklebust@primarydata.com>
 <1425931503-37261-5-git-send-email-trond.myklebust@primarydata.com>
 <20150317103736.GA31940@infradead.org>
 <CAHQdGtS4UU=ArTeLBWKaRzEj=j2dWmqhU+z61RLnzU1=Gp5aLw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtS4UU=ArTeLBWKaRzEj=j2dWmqhU+z61RLnzU1=Gp5aLw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 22, 2015 at 03:27:32PM -0400, Trond Myklebust wrote:
> No. The right fix is to make the server support device notifications.

And you instantly thrash performane on any server that doesn't, which
is why I sent out the errata that no one objected out.  I'm happy to
open this again on the WG list, but the notification scheme is such a
big hammer that it absolutely isn't worth implementing.  Given how
GETDEVICELIST is specified in 4.1 the original RFC language also is
inconsistent with itself, so that's not an argument for the old
behavior.
