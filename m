From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: Am I still the one to fix the NFS_FILE_SYNC problem
Date: Mon, 24 May 2010 12:47:09 -0400
Message-ID: <AANLkTikBVuA7uHYwIfkJBRwI_PujsDd_HDkg__N8iM3p@mail.gmail.com>
References: <4BF975A3.7090509@panasas.com>
	 <AANLkTilR7cJu1uCv60GrpFimqDWb0ogyvKVh1q0iW_6a@mail.gmail.com>
	 <4BFA9D9D.2030908@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:53796 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757687Ab0EXQrL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 12:47:11 -0400
Received: by gwaa20 with SMTP id a20so1578847gwa.19
        for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 09:47:10 -0700 (PDT)
In-Reply-To: <4BFA9D9D.2030908@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 24, 2010 at 11:39 AM, Boaz Harrosh <bharrosh@panasas.com> w=
rote:
> On 05/24/2010 04:14 PM, William A. (Andy) Adamson wrote:
>> Hi Boaz
>>
>> The last patch I sent in [PATCH 1/1] SQUASHME pnfs-submit: replace
>> layoutcommit_ctx with rpc_cred fixes the NFS_FILE_SYNC problem for
>> files. It replaces taking a reference on the open context with takin=
g
>> a reference on the rpc_cred.
>>
>
> Hi Andy.
>
> I hope you are online could you chat with me a bit about this,
> on boazharrosh-Re5JQEeQqe9fmgfxC/sS/w@public.gmane.org
> I have seen your patch and i like it a lot. I have not yet test with
> it, so I own you.
>
> I'm talking about the other problem I had where the write-out returns
> NFS_FILE_SYNC and commit is not called and pnfs_client_ops->nfs_commi=
t_complete()
> is not eventually called, then inode never gets written/updated and w=
e get all
> these straining .nfs000000000000XXX files and IO never finishes. You =
said
> you had them too and I had a work around for objects. (This problem i=
s new
> in 2.6.34)
>
> Do you have this problem or it's only me?

Yes, I had that problem - but for the file layout it was the
pnfs_need_layoutcommit at the end of pfns4_write_done that was
preventing _nfs4_close from being called due to the get on the
nfs_open_context. Replacing the nfs_open_context with the rpc_cred
solved our problem. Also, remember that the file layout does not need
a layout commit - it's just a hint.

-->Andy

>
> Boaz
>
>> -->Andy
>>
>>
>> On Sun, May 23, 2010 at 2:36 PM, Boaz Harrosh <bharrosh@panasas.com>=
 wrote:
>>>
>>> Andy, Benny are you waiting on me to fix the NFS_FILE_SYNC problem?
>>>
>>> I've been on a long holiday, but I can attempt a fix tomorrow if st=
ill
>>> needed?
>>>
>>> I was hoping someone else need that more urgently then me, since I =
already
>>> have a work around, for my testing ;-)
>>>
>>> Boaz
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
>
>
