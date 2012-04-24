Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51126 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755254Ab2DXPjv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 11:39:51 -0400
Message-ID: <4F96C93F.3060908@redhat.com>
Date: Tue, 24 Apr 2012 17:39:43 +0200
From: Niels de Vos <ndevos@redhat.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Chuck Lever <chuck.lever@oracle.com>, Steve Dickson <steved@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpcbind: Only listen on requested hostnames for NC_TPI_COTS
 connections
References: <1335194692-6714-1-git-send-email-ndevos@redhat.com> <82D8C43F-5C40-444C-9573-B4FF95F615DA@oracle.com> <4F957D30.9010102@redhat.com> <7C71F75F-3F15-401B-8700-38B0EBE2B595@oracle.com> <4F96C0E3.9090007@redhat.com> <20120424152950.GB13191@umich.edu>
In-Reply-To: <20120424152950.GB13191@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 04/24/2012 05:29 PM, Jim Rees wrote:
> Niels de Vos wrote:
>
>    On 04/23/2012 06:22 PM, Chuck Lever wrote:
>    >
>    >  So you did check the mail archive?  I seem to recall other patches like
>    >  this in the past, and that there is a reason why rpcbind works this way.
>    >  I simply don't remember the specifics right at the moment.
>
>    I did, but no messages about this subject come up for me... Maybe I'm looking
>    in the wrong places :-/
>
> I asked about this last November, and at that time Chuck referred me to the
> mail archive too.  I couldn't find any discussion either.  But the behavior
> is intentional, so I don't think you'll get a patch accepted.  I never did
> discover the reason but I do have a workaround.  I just don't run rpcbind.

Many thanks for the pointer, I think this should be an acceptable solution.

Cheers,
Niels

> This was the most informative response I got:
>
> Date: Tue, 8 Nov 2011 19:01:51 +1100
> From: Max Matveev<makc@redhat.com>
> Subject: Re: rpcbind -h
> To: Jim Rees<rees@umich.edu>
> Cc: Chuck Lever<chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
>
> Chuck's quote from the manpage reminded me - -h was used to work
> around the address selection: if server has more then one address the
> reply may use any of them. Some clients don't like it.
>
> This issue should go away after
>
> commit 74ef3df0236c55185225c62fba34953f2582da72
> Author: Olaf Kirch<okir@suse.de>
> Date:   Wed Mar 2 10:09:24 2011 -0500
>
> was added to libtirpc.
>
>   rees>  As I said before, I was hoping for the equivalent of "portmap
>   rees>  -l".  I was ready to code up a patch of some kind but now have
>   rees>  a workaround (mount with nolock and don't run rpcbind at all).
>
> iptables is another option.
>
> max
