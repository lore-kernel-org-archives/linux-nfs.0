Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:50575 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934964AbaH0Ryc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Aug 2014 13:54:32 -0400
Message-ID: <53FE1B41.50307@Netapp.com>
Date: Wed, 27 Aug 2014 13:54:09 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: Add v4.2 SEEK support
References: <1409152730-8070-1-git-send-email-Anna.Schumaker@Netapp.com> <20140827174325.GB13128@infradead.org>
In-Reply-To: <20140827174325.GB13128@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/27/2014 01:43 PM, Christoph Hellwig wrote:
> On Wed, Aug 27, 2014 at 11:18:49AM -0400, Anna Schumaker wrote:
>> This patch adds support for the NFS v4.2 operation SEEK.
>>
>> I think nfs4proc.c and nfs4xdr.c have grown out of control, and I would like
>> to avoid adding new functions to these files unless absolutely necessary.
>> Therefore, I created nfs4.2proc.c and nfs4.2xdr.h in an attempt to separate
>> out the new code.
>>
>> Questions?  Comments?  Thoughts?
> I hate the dot in the name :)  why not nfs42proc.c and co?
Sure, I can change that.  I put the dot because I kept reading it "fourty-two" and now "four two".
>
> Also without splitting out the much larger 4.1 ops this seems a bit
> pointless, although I generally like the idea.
Oh, but I want to split those out too :D.  I figured it would be easiest to come up with a solution now, when we're adding a new minor version, and then split out v4.1 once we know what we're doing.

Anna

>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

