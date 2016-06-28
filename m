Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:50707 "EHLO
	us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752316AbcF1MzY convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Jun 2016 08:55:24 -0400
From: Trond Myklebust <trondmy@primarydata.com>
To: Andrew W Elble <aweits@rit.edu>
CC: Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trondmy@primarydata.com>,
        Schumaker Anna <Anna.Schumaker@netapp.com>,
        "Thomas Haynes" <loghyr@primarydata.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        hch <hch@lst.de>
Subject: Re: [PATCH v4 12/13] pnfs: rework LAYOUTGET retry handling
Date: Tue, 28 Jun 2016 12:55:17 +0000
Message-ID: <1CE12C82-9D6C-4B22-95B4-1F3EE1D195B2@primarydata.com>
References: <1463502528-11519-1-git-send-email-jeff.layton@primarydata.com>
 <1463502528-11519-13-git-send-email-jeff.layton@primarydata.com>
 <m260stv7hp.fsf@discipline.rit.edu>
 <1467116540.32374.5.camel@poochiereds.net>
 <m2d1n1tqxk.fsf@discipline.rit.edu>
In-Reply-To: <m2d1n1tqxk.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 28, 2016, at 08:53, Andrew W Elble <aweits@rit.edu> wrote:
> 
>>>> +		default:
>>>> +			if (!nfs_error_is_fatal(PTR_ERR(lseg))) {
>>>> +				pnfs_layout_clear_fail_bit(lo, pnfs_iomode_to_fail_bit(iomode));
>>>> +				lseg = NULL;
>>>> +			}
>>> Seems like in the past, a non-fatal-error used to trigger the opposite
>>> behavior, where this would set the fail_bit? Shouldn't that be the
>>> behavior for -NFS4ERR_LAYOUTUNAVAILABLE (which is mapped to -ENODATA)
>>> etc...?
>>> 
>> 
>> Yes, and I think that was a bug. See commit
>> d03ab29dbbe905c6c7c5abd78e02547fa954ec07 for where that actually
>> changed.
> 
> I think you mean:
> 0bcbf039f6b2bcefe4f5dada76079080edf9ecd0
> 
> ?
> 
> ...and I was looking at this one:
> d600ad1f2bdbf97c4818dcc85b174f72c90c21bd
> 
>> You do have a good point about LAYOUTUNAVAILABLE though. That probably
>> should stop further attempts to get a layout. That said, the error
>> mapping here is fiendishly complex. I always have to wonder whether
>> there other errors that get turned into ENODATA? It may be safest to
>> change the error mapping there to something more specific.
> 
> If setting the fail_bit is the right way to go, that could be done
> with less confusion in nfs4_layoutget_handle_exception()…?

It’s not.

Cheers
  Trond


