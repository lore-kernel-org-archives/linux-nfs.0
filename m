Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:59328 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754068Ab1BGPa0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Feb 2011 10:30:26 -0500
Received: by bwz15 with SMTP id 15so5006638bwz.19
        for <linux-nfs@vger.kernel.org>; Mon, 07 Feb 2011 07:29:46 -0800 (PST)
In-Reply-To: <AANLkTinTKbWROXXAaf4PAVkBp4n9BAs461pXQu-zu6Lv@mail.gmail.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
	<1296855242-2592-2-git-send-email-andros@netapp.com>
	<1296855242-2592-3-git-send-email-andros@netapp.com>
	<1296855242-2592-4-git-send-email-andros@netapp.com>
	<1296855242-2592-5-git-send-email-andros@netapp.com>
	<1296855242-2592-6-git-send-email-andros@netapp.com>
	<1296855242-2592-7-git-send-email-andros@netapp.com>
	<1296855242-2592-8-git-send-email-andros@netapp.com>
	<1296855242-2592-9-git-send-email-andros@netapp.com>
	<1296855242-2592-10-git-send-email-andros@netapp.com>
	<1296855242-2592-11-git-send-email-andros@netapp.com>
	<1296855242-2592-12-git-send-email-andros@netapp.com>
	<1296855242-2592-13-git-send-email-andros@netapp.com>
	<1296855242-2592-14-git-send-email-andros@netapp.com>
	<1296855242-2592-15-git-send-email-andros@netapp.com>
	<1296855242-2592-16-git-send-email-andros@netapp.com>
	<1296855242-2592-17-git-send-email-andros@netapp.com>
	<1296855242-2592-18-git-send-email-andros@netapp.com>
	<1296855242-2592-19-git-send-email-andros@netapp.com>
	<1296855242-2592-20-git-send-email-andros@netapp.com>
	<1296855242-2592-21-git-send-email-andros@netapp.com>
	<1296855242-2592-22-git-send-email-andros@netapp.com>
	<1296855242-2592-23-git-send-email-andros@netapp.com>
	<1296855242-2592-24-git-send-email-andros@netapp.com>
	<AANLkTi=GcLNguekTEnapQ-tzJ6ojWddhwM=VyMoE=enr@mail.gmail.com>
	<AANLkTikGXQrhLXi9-irp92io0DzHB+H3adD+1CdUX7W_@mail.gmail.com>
	<AANLkTimACJomfqNY01+9W6_i-0S4y-hgg93mUMM-NcrZ@mail.gmail.com>
	<AANLkTinTKbWROXXAaf4PAVkBp4n9BAs461pXQu-zu6Lv@mail.gmail.com>
Date: Mon, 7 Feb 2011 10:29:46 -0500
Message-ID: <AANLkTikCnB9GGgcDtPFKt44GVe4Ubcg3iDTCkU=4aW+G@mail.gmail.com>
Subject: Re: [PATCH 23/40] SQUASHME pnfs-submit wave3 new function for ds
 expired lease
From: Fred Isaman <iisaman@netapp.com>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Cc: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Feb 7, 2011 at 10:05 AM, William A. (Andy) Adamson
<androsadamson@gmail.com> wrote:
> On Sun, Feb 6, 2011 at 2:41 PM, Fred Isaman <iisaman@netapp.com> wrote:
>> On Sat, Feb 5, 2011 at 11:46 AM, William A. (Andy) Adamson
>> <androsadamson@gmail.com> wrote:
>>> On Fri, Feb 4, 2011 at 4:51 PM, Fred Isaman <iisaman@netapp.com> wrote:
>>>> On Fri, Feb 4, 2011 at 4:33 PM,  <andros@netapp.com> wrote:
>>>>> From: Andy Adamson <andros@netapp.com>
>>>>>
>>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>>> ---
>>>>> áfs/nfs/nfs4proc.c | á 11 ++++++++---
>>>>> á1 files changed, 8 insertions(+), 3 deletions(-)
>>>>>
>>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>>> index 9c50be7..fb22cbf 100644
>>>>> --- a/fs/nfs/nfs4proc.c
>>>>> +++ b/fs/nfs/nfs4proc.c
>>>>> @@ -1574,7 +1574,7 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
>>>>> á á á áreturn 0;
>>>>> á}
>>>>>
>>>>> -int nfs4_recover_expired_lease(struct nfs_client *clp)
>>>>> +static int nfs4_client_recover_expired_lease(struct nfs_client *clp)
>>>>> á{
>>>>> á á á áunsigned int loop;
>>>>> á á á áint ret;
>>>>> @@ -1593,6 +1593,11 @@ int nfs4_recover_expired_lease(struct nfs_client *clp)
>>>>> á}
>>>>> áEXPORT_SYMBOL(nfs4_recover_expired_lease);
>>>>>
>>>>> +static int nfs4_recover_expired_lease(struct nfs_server *server)
>>>>> +{
>>>>> + á á á return nfs4_client_recover_expired_lease(server->nfs_client);
>>>>> +}
>>>>> +
>>>>
>>>> Why are we doing this extra indirection?
>>>
>>> As Trond pointed out, it is a lot less intrusive to the existing code.
>>>
>>> -->Andy
>>>
>>
>> I must be missing something.  What I see is that you are changing the
>> arguments to a function that is called exactly twice, and creating a
>> totally unnecessary subfunction  nfs4_client_recover_expired_lease.
>> How is this less intrusive than just directly inlining
>> nfs4_client_recover_expired_lease?
>
> This patch reverts the change made in pnfs_submit: filelayout i/o
> helpers which changed the argument from nfs_server to nfs_client.
> which changed the two calls. That is more intrusive to what this patch
> does which is to leave the two calls alone.  Adding
> nfs4_client_recover_expired_lease lets us call it with struct
> nfs_client from the data server code without changing the existing
> calls and is therefore less intrusive.
>
> -->Andy
>>

Ah, that is what I missed.  I did not understand that this was
reverting a previous change.

Fred
