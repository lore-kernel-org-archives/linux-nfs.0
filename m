Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:42426 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932567Ab3GWVWY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jul 2013 17:22:24 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH 2/2] NFSv4: encode_attrs should not backfill the bitmap and attribute length
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1374614357.12943.7.camel@leira.trondhjem.org>
Date: Tue, 23 Jul 2013 17:22:16 -0400
Cc: Andre Heider <a.heider@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Rick Macklem <rmacklem@uoguelph.ca>
Message-Id: <361BD481-DE19-45D9-8014-A5018DC33DA6@oracle.com>
References: <1374098347-30196-1-git-send-email-Trond.Myklebust@netapp.com> <1374098347-30196-2-git-send-email-Trond.Myklebust@netapp.com> <CAHsu+b-b=-pQ4f8AfHHDaPpAK3YvHomS3X-QuEJkzbAsuJBYfg@mail.gmail.com> <1374598847.12943.0.camel@leira.trondhjem.org> <A4648039-314B-4B30-BCDC-7D612DE1EC1F@oracle.com> <1374614357.12943.7.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jul 23, 2013, at 5:19 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Tue, 2013-07-23 at 16:14 -0400, Chuck Lever wrote:
>> On Jul 23, 2013, at 1:00 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>> 
>>> On Tue, 2013-07-23 at 17:59 +0200, Andre Heider wrote:
>>>> Trond,
>>>> 
>>>> On Wed, Jul 17, 2013 at 11:59 PM, Trond Myklebust
>>>> <Trond.Myklebust@netapp.com> wrote:
>>>>> The attribute length is already calculated in advance. There is no
>>>>> reason why we cannot calculate the bitmap in advance too so that
>>>>> we don't have to play pointer games.
>>>> 
>>>> I'm sorry to report that this patch seems to be more than just a cleanup.
>>>> 
>>>> I just tested 3.11-rc2 against my FreeBSD server, and with just patch
>>>> 1/2 (as in -rc2) I still get the failure upon `touch`. It fails with
>>>> or without Rick's server patch.
>>>> 
>>>> Applying this one on top of -rc2 fixes it.
>>> 
>>> How about the attached instead of the cleanup?
>> 
>> Even with this patch applied, cthon basic tests fail immediately for me.  The mkdir to create the test directory fails with EIO.
>> 
>> The wire trace shows that the CREATE operation is malformed: the client sends a length of 8 for the 4-octet mode attribute value at the end of the operation.
>> 
>> This causes the server to skip over the following GETFH operation -- it thinks the client has sent 3 operations, when the client told it to expect 4 in this compound.
>> 
>> Here:
>> 
>> 1064         *p++ = cpu_to_be32(bmval_len);
>> 1065         q = p;
>> 1066         /* Skip bitmap entries + attrlen */
>> 1067         p += bmval_len + 1;
>> 
>> You've skipped over the 4-octet attrlen field, but here:
>> 
>> 1125         *q++ = htonl(bmval0);
>> 1126         *q++ = htonl(bmval1);
>> 1127         if (bmval_len == 3)
>> 1128                 *q++ = htonl(bmval2);
>> 1129         len = (char *)p - (char *)q;
> 
> In the patch I sent out, the above should read (q+1)...

D'OH!

> 
>> 1130         *q = htonl(len);
>> 
>> have you failed to take the attrlen field into account when computing the length of the attribute values?
>> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




