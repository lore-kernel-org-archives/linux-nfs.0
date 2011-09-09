Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay03.bluemeaney.com ([205.234.16.187]:33862 "EHLO
	relay03.bluemeaney.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758310Ab1IISCR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Sep 2011 14:02:17 -0400
Message-ID: <4E6A5100.3000007@nexenta.com>
Date: Fri, 09 Sep 2011 21:46:40 +0400
From: Vitaliy Gusev <gusev.vitaliy@nexenta.com>
To: Peng Tao <bergwolf@gmail.com>
CC: tao.peng@emc.com, Trond.Myklebust@netapp.com, gusev.vitaliy@gmail.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: fix inifinite loop at nfs4_layoutcommit_release
References: <1314512558-16912-1-git-send-email-gusev.vitaliy@nexenta.com> <1315337382.16274.7.camel@lade.trondhjem.org> <4E669B21.30006@nexenta.com> <F19688880B763E40B28B2B462677FBF805C3299C9C@MX09A.corp.emc.com> <4E68BCD4.9030202@nexenta.com> <CA+a=Yy69oQeuSagh_o-32U-rgmwz0BpeZawhMurFK8h6vD2Org@mail.gmail.com>
In-Reply-To: <CA+a=Yy69oQeuSagh_o-32U-rgmwz0BpeZawhMurFK8h6vD2Org@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

>>> Reported-by: Vitaliy Gusev<gusev.vitaliy@nexenta.com>
>>> Signed-off-by: Peng Tao<peng_tao@emc.com>
>>> ---
>>>   fs/nfs/nfs4proc.c |    2 ++
>>>   1 files changed, 2 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>> index 8c77039..da7c20c 100644
>>> --- a/fs/nfs/nfs4proc.c
>>> +++ b/fs/nfs/nfs4proc.c
>>> @@ -5964,6 +5964,7 @@ static void nfs4_layoutcommit_release(void
>>> *calldata)
>>>         struct pnfs_layout_segment *lseg, *tmp;
>>>
>>>         pnfs_cleanup_layoutcommit(data);
>>> +       spin_lock(&data->args.inode->i_lock);
>>
>> I think lock over list_del_init(&lseg->pls_lc_list) is enough, because
> I put the spinlock outside of the loop because the critical section is
> short enough and it should be faster than grabbing/dropping the inode
> lock for every entry in the list, agree?

Yes, you are right.

Looked again I saw that issue is not so bad as seems.
Really, what is result of this issue? Only that lseg is in 
data->lseg_list, but without set NFS_LSEG_LAYOUTCOMMIT. The put_lseg is 
called correctly at nfs4_layoutcommit_release. So there is no any bug.

