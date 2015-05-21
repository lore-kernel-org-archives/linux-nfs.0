Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:34024 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755069AbbEUNXu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 May 2015 09:23:50 -0400
Received: by wghq2 with SMTP id q2so85593787wgh.1
        for <linux-nfs@vger.kernel.org>; Thu, 21 May 2015 06:23:49 -0700 (PDT)
Message-ID: <555DDC63.6030707@plexistor.com>
Date: Thu, 21 May 2015 16:23:47 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>, NeilBrown <neilb@suse.de>
CC: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Does NFSv4 need to call inode_permission on every write???
References: <20150521144029.57f1b33f@notabene.brown> <20150521130735.GA27065@fieldses.org>
In-Reply-To: <20150521130735.GA27065@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/21/2015 04:07 PM, J. Bruce Fields wrote:
> On Thu, May 21, 2015 at 02:40:29PM +1000, NeilBrown wrote:
>>
>>
>> Apologies if this has been answered before, however...
>>
>> In nfsd_write() we have:
>>
>> 	if (file) {
>> 		err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
>> 				NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE);
>> 		if (err)
>> 			goto out;
>> 		err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt,
>> 				stablep);
>> 	} else {
>>
>> So if a 'file' is already available - because the request came via NFSv4 and
>> there was a valid state id, and a 'struct file' was associated with that
>> state - we still call nfsd_permission().
>>
>> Is that really needed?  The permission check will have been performed at open
>> - it shouldn't be needed again now.
>>
>> With NFSv3 we have to check permission at each IO, and this is slightly
>> different from POSIX semantics.  We shouldn't have to with NFSv4... should we?
>>
>> The particular issue that brought this to my attention is that "chattr +i" -
>> to make a file immutable - is not supposed to affect current opens, only
>> future opens.  But a current open over NFSv4 is affected.
>>
>> Is there some reason that we cannot just remove that nfsd_permission() check?
> 
> The only proof that this write is part of the open is a stateid provided
> as part of the write arguments.  Anyone could sniff or guess that
> stateid.
> 

Perhaps like in OSD take a few bits in the state ID for a crypto
sig on the stateid+internal-server-counter this way it will be
impossible to fake. (The crypto key is only known to the server
and is volatile) (Yes you'll need to fake something with the DSs
unless you want to communicate public keys for verification)

(No it is not implemented in open-osd, is just provisioned for
 in the STD)

Just a thought
Boaz

> We could try to make that work by checking the stateid against the
> principal from the rpc header.  Unfortunately that turns out to be more
> complicated than "is this the same principal as did the open"; among
> other things I think it's possible the stateid resulted from opens done
> by different principals, so we'd need to keep a list.  If we added that
> kind of check, could we drop the per-operation check?  It's not obvious
> to me.
> 
> --b.


