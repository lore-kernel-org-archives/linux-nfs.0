From: Tao Guo <glorioustao@gmail.com>
Subject: Re: Am I still the one to fix the NFS_FILE_SYNC problem
Date: Tue, 25 May 2010 00:10:46 +0800
Message-ID: <AANLkTinAvR4n1Zts0zdz7FHG8pmcC9TtFmVUaar0Enq-@mail.gmail.com>
References: <4BF975A3.7090509@panasas.com>
	 <AANLkTilR7cJu1uCv60GrpFimqDWb0ogyvKVh1q0iW_6a@mail.gmail.com>
	 <4BFA9D9D.2030908@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "William A. (Andy) Adamson" <androsadamson@gmail.com>,
	Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:35404 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332Ab0EXQKr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 12:10:47 -0400
Received: by vws9 with SMTP id 9so2491151vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 09:10:46 -0700 (PDT)
In-Reply-To: <4BFA9D9D.2030908@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 24, 2010 at 11:39 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 05/24/2010 04:14 PM, William A. (Andy) Adamson wrote:
>> Hi Boaz
>>
>> The last patch I sent in [PATCH 1/1] SQUASHME pnfs-submit: replace
>> layoutcommit_ctx with rpc_cred fixes the NFS_FILE_SYNC problem for
>> files. It replaces taking a reference on the open context with taking
>> a reference on the rpc_cred.
>>
>
> Hi Andy.
>
> I hope you are online could you chat with me a bit about this,
> on boazharrosh-Re5JQEeQqe9fmgfxC/sS/w@public.gmane.org
>
> I have seen your patch and i like it a lot. I have not yet test with
> it, so I own you.
>
> I'm talking about the other problem I had where the write-out returns
> NFS_FILE_SYNC and commit is not called and pnfs_client_ops->nfs_commit_complete()
> is not eventually called, then inode never gets written/updated and we get all
> these straining .nfs000000000000XXX files and IO never finishes. You said
> you had them too and I had a work around for objects. (This problem is new
> in 2.6.34)
>
> Do you have this problem or it's only me?
>
I have already send a patch to fix it:
http://marc.info/?l=linux-nfs&m=127433056302242&w=2
> Boaz
>
>> -->Andy
>>

-- 
tao.
