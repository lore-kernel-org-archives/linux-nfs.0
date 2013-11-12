Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:3836 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755695Ab3KLTy1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 14:54:27 -0500
Message-ID: <52828767.3030909@netapp.com>
Date: Tue, 12 Nov 2013 14:54:15 -0500
From: Anna Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v2 0/3] NFSD: Implement SEEK
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com> <20131112194529.GA26341@fieldses.org>
In-Reply-To: <20131112194529.GA26341@fieldses.org>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/12/2013 02:45 PM, J. Bruce Fields wrote:
> On Tue, Nov 12, 2013 at 02:04:05PM -0500, Anna Schumaker wrote:
>> These patches implement just the SEEK NFS v4.2 operation.  WRITE_PLUS is
>> still under discussion with the IETF after my last series of patches, so I
>> am holding off on resubmitting until after spec discussion dies down.
>>
>> Questions?  Comments?  Thoughts?
>> Anna
>>
>> Anna Schumaker (3):
>>   NFSD: Update error codes
> 
> I don't think I got this first patch.

It's in the "patches" directory I used, but I don't see it in my gmail inbox either.  I'll send it out in a minute.

> 
>>   NFSD: Create nfs v4.2 decode ops
>>   NFSD: Implement SEEK
> 
> I'd like to be reassured the protocol is reasonably stable before we
> commit this.  I haven't been following the ietf wg discussion closely.
> 
> And this should initially be disabled by default.  So, probably either:
> 
> 	- Introduce a new NFSD_V4_SEEK option, or
> 	- Combine this and NFSD_V4_SECURITY_LABEL and this into a single
> 	  NFSD_V4_2 option.
> 
> And recommend "N" for now.
> 
> Probably the latter I guess, to be consistent with the client.  And
> because otherwise we could end up with an awful lot of config options.

Sure, I can do that easily enough.

Anna

> 
> --b.
> 
>>
>>  fs/nfsd/nfs4proc.c   | 56 ++++++++++++++++++++++++++++++++++++++++++++++++++
>>  fs/nfsd/nfs4xdr.c    | 58 ++++++++++++++++++++++++++++++++++++++++++++++++++++
>>  fs/nfsd/nfsd.h       |  2 +-
>>  fs/nfsd/xdr4.h       | 16 +++++++++++++++
>>  include/linux/nfs4.h | 23 ++++++++++++++++++---
>>  5 files changed, 151 insertions(+), 4 deletions(-)
>>
>> -- 
>> 1.8.4.2
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

