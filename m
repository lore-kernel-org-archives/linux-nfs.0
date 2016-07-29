Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:63710 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752196AbcG2TkI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Jul 2016 15:40:08 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v4 0/3] NFSv4.2: Add support for the COPY operation
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
References: <1461962533-26534-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20160501173733.GA556@infradead.org> <20160513203135.GE5658@fieldses.org>
 <8d09611c-31c1-baca-8e8f-6dc599731c8c@Netapp.com>
 <20160729185933.GA7964@fieldses.org>
CC: Christoph Hellwig <hch@infradead.org>, <linux-nfs@vger.kernel.org>,
        <Trond.Myklebust@primarydata.com>
Message-ID: <613202c0-68ed-2ec0-2de9-136003309cb5@Netapp.com>
Date: Fri, 29 Jul 2016 15:40:00 -0400
MIME-Version: 1.0
In-Reply-To: <20160729185933.GA7964@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/29/2016 02:59 PM, J. Bruce Fields wrote:
> On Fri, May 13, 2016 at 04:58:06PM -0400, Anna Schumaker wrote:
>> On 05/13/2016 04:31 PM, J. Bruce Fields wrote:
>>> On Sun, May 01, 2016 at 10:37:33AM -0700, Christoph Hellwig wrote:
>>>> I might sound like a broken record, but I'd feel much happier if this
>>>> had extensive xfstests coverage.  Xfstests has over one hundred tests for
>>>> file clones, and many of them should be easily adapatable.
>>>
>>> Anna, have you looked at this yet?
>>
>> Yep!  I just sent out what I came up with :)
> 
> Sorry for the lack of response.  For some reason I don't seem to have
> the updated version in my mailboxes.  Do you have a more recent version?

I'm not sure, so I'll make sure my code still works and then resubmit!

> 
>>> I don't see any obvious problem with the nfsd code, other than the
>>> obvious issue with large synchronous copies tying up server threads and
>>> leaving clients waiting--but maybe we should just see how people end up
>>> using it and deal with the problems as they come up.
> 
> I'm still worrying about this, though.
> 
> As a simple stopgap, could we just set *some* maximum on the size of the
> copy?  Or better yet on the time?--that'd let filesystems with
> clone-like features copy the whole file without blocking an nfsd thread
> indefinitely in the case of other filesystems.

Would there be a good way of figuring out the time a copy would take?  Capping with an arbitrary size would definitely be simpler, so I'll look into adding that.

Anna

> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

