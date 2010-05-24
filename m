From: Boaz Harrosh <bharrosh@panasas.com>
Subject: Re: Am I still the one to fix the NFS_FILE_SYNC problem
Date: Mon, 24 May 2010 18:39:09 +0300
Message-ID: <4BFA9D9D.2030908@panasas.com>
References: <4BF975A3.7090509@panasas.com> <AANLkTilR7cJu1uCv60GrpFimqDWb0ogyvKVh1q0iW_6a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:22544 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752332Ab0EXPjP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 11:39:15 -0400
In-Reply-To: <AANLkTilR7cJu1uCv60GrpFimqDWb0ogyvKVh1q0iW_6a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/24/2010 04:14 PM, William A. (Andy) Adamson wrote:
> Hi Boaz
> 
> The last patch I sent in [PATCH 1/1] SQUASHME pnfs-submit: replace
> layoutcommit_ctx with rpc_cred fixes the NFS_FILE_SYNC problem for
> files. It replaces taking a reference on the open context with taking
> a reference on the rpc_cred.
> 

Hi Andy.

I hope you are online could you chat with me a bit about this, 
on boazharrosh-Re5JQEeQqe9fmgfxC/sS/w@public.gmane.org

I have seen your patch and i like it a lot. I have not yet test with
it, so I own you.

I'm talking about the other problem I had where the write-out returns
NFS_FILE_SYNC and commit is not called and pnfs_client_ops->nfs_commit_complete()
is not eventually called, then inode never gets written/updated and we get all
these straining .nfs000000000000XXX files and IO never finishes. You said
you had them too and I had a work around for objects. (This problem is new
in 2.6.34)

Do you have this problem or it's only me?

Boaz

> -->Andy
> 				
> 
> On Sun, May 23, 2010 at 2:36 PM, Boaz Harrosh <bharrosh@panasas.com> wrote:
>>
>> Andy, Benny are you waiting on me to fix the NFS_FILE_SYNC problem?
>>
>> I've been on a long holiday, but I can attempt a fix tomorrow if still
>> needed?
>>
>> I was hoping someone else need that more urgently then me, since I already
>> have a work around, for my testing ;-)
>>
>> Boaz
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>

