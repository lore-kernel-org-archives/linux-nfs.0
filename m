Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:35819 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757824Ab0LBOnV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Dec 2010 09:43:21 -0500
Message-ID: <4CF7B086.6000403@panasas.com>
Date: Thu, 02 Dec 2010 16:43:18 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: Jim Rees <rees@umich.edu>
CC: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH 4/5] various minor cleanups
References: <cover.1291142529.git.rees@umich.edu> <55dae19c431eeee6d4fabf18550fdf976646a9a5.1291142529.git.rees@umich.edu> <4CF7A64D.8040802@panasas.com> <4CF7A8F9.8010902@panasas.com> <20101202144126.GA14604@merit.edu>
In-Reply-To: <20101202144126.GA14604@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-12-02 16:41, Jim Rees wrote:
> Benny Halevy wrote:
> 
>   >> -static char *pretty_sig(char *sig, int siglen)
>   >> +static char *pretty_sig(char *sig, uint32_t siglen)
>   >>  {
>   >>  	static char rs[100];
>   >> -	unsigned int i;
>   >> +	unsigned long i;
>   >>  
>   >> -	if (siglen <= 4) {
>   >> +	if (siglen <= sizeof i) {
>   >>  		memcpy(&i, sig, sizeof i);
>   >> -		sprintf(rs, "0x%0x", i);
>   >> +		sprintf(rs, "0x%0lx", i);
>   > 
>   > What about machine endianess?
>   > The MDS and clients may be of different gender, no?
>   > Also, on 64 bit machines, you may copy 8 bytes while the signature
>   > is 4-bytes long so you may copy junk into i.
>   > 
>   > Benny
>   > 
>   >>  	} else {
>   >> +		if (siglen > sizeof rs - 1)
>   >> +			siglen = sizeof rs - 1;
>   
>   Hmm, for courtesy purposes, how about ending the truncated
>   signature with "..."?
> 
> I am glad you are paying attention!  I am aware of the shortcomings of
> pretty_sig().  In addition to the problems you noted, it also assumes that a
> signature over 8 bytes long is representable as a text string, which is not
> guaranteed.  The code it replaced was worse.
> 
> I put this in because for debugging I need to be able to follow a signature
> all the way from my EMC server to the devmapper.  pretty_sig() simply prints
> the signature in a way that I can match it up with the signature on the
> server.
> 
> I don't want to spend a lot of time on this, but I also am uneasy leaving
> EMC-specific code in nfs-utils, especially since it can blow up if you use
> it against a non-EMC server.  My inclination is to remove this debugging
> code when I no longer need it.  I guess at the very least I should put in a
> comment.  I am open to suggestions.

Why can't it always dump the signature in hex, even if it happens to be ASCII?

Benny
