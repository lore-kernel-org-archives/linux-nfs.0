Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og112.obsmtp.com ([64.18.0.24]:57476 "HELO
	exprod5og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750916Ab0JYLlJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Oct 2010 07:41:09 -0400
Message-ID: <4CC56CCE.2050503@panasas.com>
Date: Mon, 25 Oct 2010 13:41:02 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>, Boaz Harrosh <bharrosh@panasas.com>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] move include lines out of include file
References: <20101022005120.GA15788@merit.edu> <4CC4203C.2050600@panasas.com> <20101024153503.GC10769@merit.edu>
In-Reply-To: <20101024153503.GC10769@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-24 17:35, Jim Rees wrote:
> Boaz Harrosh wrote:
> 
>   This patch does *not* break the header's independence. .i.e the header can
>   still be compiled independently without any other includes. Which means
>   some of the includes here are un-needed.
> 
> Thanks!  I tried removing all the includes but was too lazy to figure out
> which one was really needed by simple_rpc_pipefs.c.

Yup.
The self-sustainability approach is the best one, i.e. header files
should include the minimum number of other header files to satisfy their
dependencies.

I'll merge both patches squashed together then.

Benny
