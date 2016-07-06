Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([63.128.21.194]:60105 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751629AbcGFUMI convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jul 2016 16:12:08 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Fields Bruce <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 09/10] SUNRPC: Change TCP socket space reservation
Date: Wed, 6 Jul 2016 20:11:53 +0000
Message-ID: <3774A9EF-883F-45E2-B93E-26B178FF499D@primarydata.com>
References: <1466780152-7154-1-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-2-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-3-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-4-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-5-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-6-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-7-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-8-git-send-email-trond.myklebust@primarydata.com>
 <1466780152-7154-9-git-send-email-trond.myklebust@primarydata.com>
 <20160706195308.GF18856@fieldses.org>
In-Reply-To: <20160706195308.GF18856@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jul 6, 2016, at 15:53, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Fri, Jun 24, 2016 at 10:55:51AM -0400, Trond Myklebust wrote:
>> Instead of trying (and failing) to predict how much writeable socket space
>> will be available to the RPC call, just fall back to the simple model of
>> deferring processing until the socket is uncongested.
>> 
>> If a limit is neeeded, then set the hard per-connection limit.
> 
> I was hoping this would be an opportunity to get rid of even more code,
> but there's still the udp case.  Do we actually need that?
> 

I wasn’t really too concerned about UDP; I consider it to be legacy code.

That said, I’d argue the existing system make a little more sense in the case of UDP as you don’t have any equivalent of the TCP window size. That means the socket buffer sizes are predictable, and so are more easily modelled as a pipeline.

Cheers
  Trond

