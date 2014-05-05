Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:40541 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755458AbaEEJmj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 May 2014 05:42:39 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so1914519pad.37
        for <linux-nfs@vger.kernel.org>; Mon, 05 May 2014 02:42:38 -0700 (PDT)
Date: Mon, 5 May 2014 02:42:35 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
To: Marc Dietrich <marvin24@gmx.de>
cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mel Gorman <mgorman@suse.de>
Subject: Re: nfs oom on 3.15
In-Reply-To: <2562595.ix17LO7uqe@fb07-iapwap2>
Message-ID: <alpine.DEB.2.02.1405050241180.11071@chino.kir.corp.google.com>
References: <2562595.ix17LO7uqe@fb07-iapwap2>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 5 May 2014, Marc Dietrich wrote:

> Hi,
> 
> this is spaming my log quite a bit.
> 
> Any idea?
> 

I think rpc_malloc() really wants to be __GFP_NOWARN so that the warnings 
are suppressed, doing order-1 allocations with GFP_NOWAIT is never 
guaranteed to succeed and will have difficulty if memory is fragmented.  
