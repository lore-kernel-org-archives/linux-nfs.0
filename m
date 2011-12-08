Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:56000 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753751Ab1LHAIJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2011 19:08:09 -0500
Received: by ggnr5 with SMTP id r5so1259021ggn.19
        for <linux-nfs@vger.kernel.org>; Wed, 07 Dec 2011 16:08:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFKKZJoGh9tBfApwadpfn1zuUW1w3ZEd3OXvS3C5SczFQ@mail.gmail.com>
References: <CAN-5tyErML04W7N3YVYyK0qq8OR_Ae+d4MzNXYyAVTMad39bFw@mail.gmail.com>
	<4EDF72B1.2060509@tonian.com>
	<CAN-5tyFKKZJoGh9tBfApwadpfn1zuUW1w3ZEd3OXvS3C5SczFQ@mail.gmail.com>
Date: Wed, 7 Dec 2011 19:08:08 -0500
Message-ID: <CAN-5tyGZkKsX=-eBQt73oLwoss=+oVxK4_wOGH1x7w2p3vY8sw@mail.gmail.com>
Subject: Re: pnfs nfsd compile problems
From: Olga Kornievskaia <aglo@citi.umich.edu>
To: Benny Halevy <bhalevy@tonian.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 7, 2011 at 6:46 PM, Olga Kornievskaia <aglo@citi.umich.edu> wrote:
> On Wed, Dec 7, 2011 at 9:05 AM, Benny Halevy <bhalevy@tonian.com> wrote:
>> On 2011-12-06 22:57, Olga Kornievskaia wrote:
>>> Latest pnfs-all-latest (commit
>>> 58deb32bd36e92f5f44ac6d5e5ab3c36732c4ebd) doesn't compile if
>>> CONFIG_PNFSD_BLOCK is not enabled.
>>>
>>> 1st compile error is in (and probably gcc version dependent):
>>>   CC [M]  fs/nfsd/nfsctl.o
>>> In file included from fs/nfsd/nfsctl.c:18:0:
>>> include/linux/nfsd/nfsd4_block.h: In function ‘pnfs_block_enabled’:
>>> include/linux/nfsd/nfsd4_block.h:104:46: error: parameter name omitted
>>> include/linux/nfsd/nfsd4_block.h:104:46: error: parameter name omitted
>>
>> Sorry. The patch in reply to this message should fix that.
>>
>> Benny
>>
>> diff --git a/fs/nfsd/nfsd4_block.h b/fs/nfsd/nfsd4_block.h
>> index 9c2941f..4ce5755 100644
>> --- a/fs/nfsd/nfsd4_block.h
>> +++ b/fs/nfsd/nfsd4_block.h
>> @@ -100,7 +100,7 @@ int bl_layoutreturn(struct inode *,
>>
>>  #else
>>
>> -static inline bool pnfs_block_enabled(struct inode *, int) { return false; }
>> +static inline bool pnfs_block_enabled(struct inode *i, int ex_flags) { return false; }
>>  static inline void nfsd_bl_init(void) {}
>>
>>  #endif /* CONFIG_PNFSD_BLOCK */
>>
>
> Sure that fixes problem #1. 2 more to go.

Sorry, bad git pull. I see that you moved things around. I can confirm
that all compiles correctly.
