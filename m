Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f49.google.com ([74.125.82.49]:58628 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257Ab3JCM3O (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 08:29:14 -0400
Received: by mail-wg0-f49.google.com with SMTP id l18so2329689wgh.28
        for <linux-nfs@vger.kernel.org>; Thu, 03 Oct 2013 05:29:12 -0700 (PDT)
Message-ID: <524D6312.7020709@primarydata.com>
Date: Thu, 03 Oct 2013 15:29:06 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
References: <20130929114327.GB25750@infradead.org> <52481939.7060405@primarydata.com> <20130929121345.GA21083@infradead.org> <52481B11.2080407@primarydata.com> <20130929122130.GI21083@infradead.org> <20130929123553.GA7510@infradead.org> <20131001203047.GH16245@pad.fieldses.org> <524C0556.9070705@primarydata.com> <20131002160759.GB27988@infradead.org> <524D0873.40602@primarydata.com> <20131003095511.GA30147@infradead.org>
In-Reply-To: <20131003095511.GA30147@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-03 12:55, Christoph Hellwig wrote:
> On Thu, Oct 03, 2013 at 09:02:27AM +0300, Benny Halevy wrote:
>> Just that this is dlm specific logic.
>> For example, using dlm_ino_hash() in nfsd4_pnfs_dlm_layoutget().
>> Or even knowing that
>> 	layout->lg_stripe_type = STRIPE_SPARSE;
>> assumes knowledge of the underlying cluster fs implementation.
> 
> Which in-tree or soon in-tree filesystem do you care about?  And why
> don't we see pnfs support for it submitted instead of the fairly useless
> gfs2 support?

I picked gfs2 as the initial use case for simplicity and ease of review.
If there is a rough consensus that it's useless and not worthy of inclusion
then the one we care about the most is exofs that has a more complete pnfs
implementation.

Benny

> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
