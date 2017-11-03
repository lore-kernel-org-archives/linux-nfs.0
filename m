Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:24787 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756087AbdKCSs5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Nov 2017 14:48:57 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH] nfs: Fix ugly referral attributes
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1509733948.21477.15.camel@primarydata.com>
Date: Fri, 3 Nov 2017 14:48:51 -0400
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BC03FA23-5D6A-4DFC-B18B-849642070918@oracle.com>
References: <20171103174658.31159.24496.stgit@manet.1015granger.net> <1509733043.21477.9.camel@primarydata.com> <1509733948.21477.15.camel@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 3, 2017, at 2:32 PM, Trond Myklebust <trondmy@primarydata.com> wrote:
> 
> On Fri, 2017-11-03 at 18:17 +0000, Trond Myklebust wrote:
>> On Fri, 2017-11-03 at 13:46 -0400, Chuck Lever wrote:
>>> Before traversing a referral and performing a mount, the mounted-on
>>> directory looks strange:
>>> 
>>> dr-xr-xr-x. 2 4294967294 4294967294 0 Dec 31  1969 dir.0
>>> 
>>> nfs4_get_referral is wiping out any cached attributes with what was
>>> returned via GETATTR(fs_locations), but the bit mask for that
>>> operation does not request any file attributes.
>>> 
>>> Set the default bits in the GETATTR bitmask to retrieve the usual
>>> set of object attributes so that the memcpy in nfs4_get_referral
>>> can
>>> fill the attributes in properly.
>>> 
>> 
>> Hmm... So I believe the reason why we didn't do this in the original
>> implementation is because of RFC7530, Section 8.3.1, which says:
>> 
>>   Other attributes SHOULD NOT be made available for absent file
>>   systems, even when it is possible to provide them. The server
>> should
>>   not assume that more information is always better and should avoid
>>   gratuitously providing additional information.
>> 
>> Where "other attributes" means anything other than fs_locations, fsid
>> and mounted-on-fileid.
>> 
>> IOW: the protocol spec has normative language stating that we should
>> not expect to be able to retrieve other attributes, and that the
>> server
>> should not return them.
> 
> Sorry. In case it wasn't clear, the above was not intended as a
> rejection of the patch. The same section also says:
> 
>   When a GETATTR operation includes a bitmask for the attribute
>   fs_locations, but where the bitmask includes attributes that are not
>   supported, GETATTR will not return an error but will return the mask
>   of the actual attributes supported with the results
> 
> So the normative language is putting the onus on the server to be
> conservative in what it returns, and does not require the client to be
> conservative in what it asks for...

Following up, the display of the referral object's attributes is
best effort, IMO, which seems to agree with both sections of text.

And, I don't think the client requests more from the target server
than it has on hand. I could be mistaken about that, and it would
be simple to trim out some of the bits in the GETATTR bitmask if
the client is making an unreasonable request.

The concern seems to apply mostly to the MOUNTED_ON_FSID bit. I
noticed the original code always asserted that bit, even though
a later patch added the conditional use of MOUNTED_ON_FSID, but
the FSID bit was not cleared in that case. The new patch will
send either of those bits, but not both at once. If that's
incorrect, I can send an updated patch.


--
Chuck Lever



