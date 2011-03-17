Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27075 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755402Ab1CQSB3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Mar 2011 14:01:29 -0400
Subject: Re: Bug in xdr_copy_to_scratch???
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110317093838.0f15eb98@notabene.brown>
References: <20110316213642.360be61d@notabene.brown>
	 <1300282974.16266.33.camel@lade.trondhjem.org>
	 <20110317093838.0f15eb98@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Mar 2011 14:01:05 -0400
Message-ID: <1300384865.28305.27.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-03-17 at 09:38 +1100, NeilBrown wrote:
> We should probably submit a fix to 2.6.37-stable though.  For that it
> is possibly simplest to tell xdr_decode_inline to round nbytes up to
> a multiple of 4 - would you agree?

How about the following fix for 2.6.37 stable?

8<-------------------------------------------------------------------------
