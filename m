Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57779 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754336Ab2BHSby (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Feb 2012 13:31:54 -0500
Date: Wed, 8 Feb 2012 13:31:51 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jim Rees <rees@umich.edu>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH 1/2] NFSv4.1: Convert slotid from u8 to u32
Message-ID: <20120208183151.GA14316@fieldses.org>
References: <1328576237-7362-1-git-send-email-Trond.Myklebust@netapp.com>
 <20120208162322.GA13315@fieldses.org>
 <1328722042.3234.13.camel@lade.trondhjem.org>
 <20120208174901.GA28564@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120208174901.GA28564@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 08, 2012 at 12:49:01PM -0500, Jim Rees wrote:
> Myklebust, Trond wrote:
> 
>   10GigE + high latencies is exactly where we're seeing the value. Andy
>   has been working with the high energy physics community doing NFS
>   traffic between the US and CERN...
> 
> CITI to CERN is just over 120ms.  I don't know what it would be from Andy's
> house.  Does he have 10G at home yet?

That still seems short of what you'd need to get a 255MB bandwidth-delay
product.

I'm just curious what the experiment is here and whether there's a
possibility the real problem is elsewhere.

--b.
