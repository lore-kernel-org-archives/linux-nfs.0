From: Alexandros Batsakis <alexandros-4GNroTWusrE@public.gmane.org>
Subject: Re: [PATCH 0/8] pnfs-submit: forgetful client v2
Date: Mon, 7 Jun 2010 08:38:11 -0700
Message-ID: <AANLkTimGBeFC4COLdjxHMkO933216iZ6sRIbFHOhmem1@mail.gmail.com>
References: <1273078858-1923-1-git-send-email-batsakis@netapp.com>
	<4C0CB334.1030405@panasas.com>
	<4C0CB3C6.7070503@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexandros Batsakis <batsakis@netapp.com>,
	linux-nfs@vger.kernel.org, bhalevy@panasas.com
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:41085 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867Ab0FGPiV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jun 2010 11:38:21 -0400
Received: by vws17 with SMTP id 17so150703vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jun 2010 08:38:20 -0700 (PDT)
In-Reply-To: <4C0CB3C6.7070503@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 7, 2010 at 1:54 AM, Boaz Harrosh <bharrosh@panasas.com> wro=
te:
> On 06/07/2010 11:52 AM, Boaz Harrosh wrote:
>> On 05/05/2010 08:00 PM, Alexandros Batsakis wrote:
>>> This set of patches (2.6.35-rc1) includes a first attempt to implem=
ent
>>
>> Alexandros what's up with the date of these mails they are all marke=
d
>> as 5/5/2010. Looks like a bug in git send-email. (Thunderbird gave m=
e
>> a hard time with that)
>>
>> Boaz
>
> The previous set was sent on the 2010_05_17, perhaps it's your machin=
e
> then?
>

Yeah... the "hardware" clock in my virtual machine gets crazy
sometimes and I didn't notice.
Apologies...
I ll rebase to -rc2 and resend anyway.

-alexandros

> Boaz
>>> the forgetful client model for the pNFS client. The model
>>> is explained is patch 7.
>>> It also includes some minor cleanups in the layout management code
>>> that help to improve the maintanability of the current code.
>>>
>>> Passed cthon tests against the pyNFS server, and against a modified
>>> version of =A0pyNFS server that randomly issues layout recalls afte=
r opens.
>>>
>>> Alexandros Batsakis (8):
>>> =A0 pnfs-submit: clean struct nfs_inode
>>> =A0 pnfs-submit: clean locking infrastructure
>>> =A0 pnfs-submit: remove lgetcount, lretcount (outstanding
>>> =A0 =A0 LAYOUTGETs/LAYOUTRETUNs)
>>> =A0 pnfs-submit: change stateid to be a union
>>> =A0 pnfs-submit: request whole file layouts only
>>> =A0 pnfs-submit: change layouts list to be similar to the other sta=
te
>>> =A0 =A0 list management
>>> =A0 pnfs-submit: forgetful client model
>>> =A0 pnfs-submit: support for cb_recall_any (layouts)
>>>
>>> =A0fs/nfs/callback.h =A0 =A0 =A0 =A0 | =A0 =A07 +
>>> =A0fs/nfs/callback_proc.c =A0 =A0| =A0231 +++++++++++++++++++++++++=
++++---------
>>> =A0fs/nfs/callback_xdr.c =A0 =A0 | =A0 =A02 +-
>>> =A0fs/nfs/client.c =A0 =A0 =A0 =A0 =A0 | =A0 =A02 +-
>>> =A0fs/nfs/delegation.c =A0 =A0 =A0 | =A0 19 ++--
>>> =A0fs/nfs/inode.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 16 ++-
>>> =A0fs/nfs/nfs4_fs.h =A0 =A0 =A0 =A0 =A0| =A0 =A01 +
>>> =A0fs/nfs/nfs4proc.c =A0 =A0 =A0 =A0 | =A0 46 +++++---
>>> =A0fs/nfs/nfs4state.c =A0 =A0 =A0 =A0| =A0 =A04 +-
>>> =A0fs/nfs/nfs4xdr.c =A0 =A0 =A0 =A0 =A0| =A0 38 ++++---
>>> =A0fs/nfs/pnfs.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0276 +++++++++++++++++=
++++------------------------
>>> =A0fs/nfs/pnfs.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +-
>>> =A0fs/nfsd/nfs4callback.c =A0 =A0| =A0 =A01 -
>>> =A0include/linux/nfs4.h =A0 =A0 =A0| =A0 16 +++-
>>> =A0include/linux/nfs4_pnfs.h | =A0 =A02 +-
>>> =A0include/linux/nfs_fs.h =A0 =A0| =A0 28 ++---
>>> =A0include/linux/nfs_fs_sb.h | =A0 =A02 +-
>>> =A017 files changed, 417 insertions(+), 277 deletions(-)
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs=
" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.htm=
l
>>>
>>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
