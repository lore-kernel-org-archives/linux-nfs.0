Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f173.google.com ([209.85.192.173]:57074 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751894AbaGWFFG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jul 2014 01:05:06 -0400
Received: by mail-pd0-f173.google.com with SMTP id w10so904733pde.4
        for <linux-nfs@vger.kernel.org>; Tue, 22 Jul 2014 22:05:05 -0700 (PDT)
Message-ID: <53CF4263.9070506@gmail.com>
Date: Wed, 23 Jul 2014 13:04:35 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: =?UTF-8?B?VG9yYWxmIEbDtnJzdGVy?= <toralf.foerster@gmx.de>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux crashed in NFS code path
References: <53C10EAA.2000802@gmx.de> <53C12A93.3040803@gmail.com> <20140716185724.GC2397@fieldses.org> <20140717202721.GG30442@fieldses.org> <53C949DC.5060008@gmx.de> <53C9505D.80601@gmx.de> <CAB6yy37-_aC83yS5JaaAbX4-qKWko-pjqSRaipZ3reVnMD=aAg@mail.gmail.com> <20140721155543.GD8438@fieldses.org>
In-Reply-To: <20140721155543.GD8438@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/21/2014 23:55, J. Bruce Fields wrote:
> On Sat, Jul 19, 2014 at 11:23:59AM +0800, Kinglong Mee wrote:
>> On Sat, Jul 19, 2014 at 12:50 AM, Toralf Förster <toralf.foerster@gmx.de> wrote:
>>> On 07/18/2014 06:22 PM, Toralf Förster wrote:
>>>> I can now try with kzalloc, but due to the nature of this issue I think, that the absence of this crash - even after 2-3 hours - doesn't mean by 100%, that kzalloc fixed it, or ?
>>>
>>> Well, next crash (with kzalloc patch) happened after 20 minutes ...
>>
>> Maybe I have found the problem.
>> The stateid and denied are defined as an union as,
>> fs/nfsd/xdr4.h
>> 145 struct nfsd4_lock_denied {
>> 146         clientid_t      ld_clientid;
>> 147         struct xdr_netobj       ld_owner;
>> 148         u64             ld_start;
>> 149         u64             ld_length;
>> 150         u32             ld_type;
>> 151 };
>> 152
>> 153 struct nfsd4_lock {
>> ... ...
>> 174         /* response */
>> 175         union {
>> 176                 struct {
>> 177                         stateid_t               stateid;
>> 178                 } ok;
>> 179                 struct nfsd4_lock_denied        denied;
>> 180         } u;
>>
>>  30 struct xdr_netobj {
>>  31         unsigned int            len;
>>  32         u8 *                    data;
>>  33 };
>>
>> sizeof(stateid_t) = 16, sizeof(clientid_t) = 8,
>> sizeof(struct xdr_netobj) = 16, (on x86_x64 platform),
>> sizeof(struct xdr_netobj) = 8,  (on i686 platform)
>>
>> Lock file success, nfsd will copy stateid to the union, but the value
>> also influence denied.
>> If on x86_64 platform, only influence the len in xdr_netobj,
>> but on i686 platform, will influence the len and the data in xdr_netobj.
>> So, the problem only appears on i686 platform.
> 
> Oh, great catch, thanks.  Sounds like that would explain all of Toralf's
> results.
> 
> I'll include this explanation with your original patch and submit it for
> 3.16.

I saw the patch in your git-tree, there is one fault about the comments.

> (Note that lock->lk_denied.ld_owner.data appears it should be zero here,
> until you notice that it's one arm of a union the other arm of which is
> written to in the succesful case by the
> 
> memcpy(&oc->oc_resp_stateid, &stp->st_stid.sc_stateid, sizeof(stateid_t));
> 
> in nfsd4_open_confirm(). 

It's, 
 memcpy(&lock->lk_resp_stateid, &lock_stp->st_stid.sc_stateid,
                                sizeof(stateid_t));
in nfsd4_lock().

> In the 32-bit case this overwrites ld_owner.data.)

thanks,
Kinglong Mee
