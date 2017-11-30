Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:41122 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751032AbdK3MEM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Nov 2017 07:04:12 -0500
From: Thiago Rafael Becker <thiago.becker@gmail.com>
Date: Thu, 30 Nov 2017 10:03:42 -0200 (-02)
To: "J. Bruce Fields" <bfields@fieldses.org>
cc: Thiago Rafael Becker <thiago.becker@gmail.com>,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] sunrpc: sort groups on unix_gid_parse
In-Reply-To: <20171127201003.GA25662@fieldses.org>
Message-ID: <alpine.LFD.2.21.1711300958380.10495@tbecker-rhat>
References: <20171127192508.12751-1-thiago.becker@gmail.com> <20171127201003.GA25662@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Mon, 27 Nov 2017, J. Bruce Fields wrote:

> Thanks for the patch:
>
> On Mon, Nov 27, 2017 at 05:25:08PM -0200, Thiago Rafael Becker wrote:
>> In cases were mountd is managing the group membership for nfsd,
>> if a user has several groups, multiple nfsd threads may call
>> sort_groups for the same freshly created unix_gid_cache entry
>> simultaneously, causing entries to be overwritten and the cache
>> entry to get corrupted.
>
> The groups_sort call is in set_groups, called from
> fs/nfsd/auth.c:nfsd_setuser():
>
> 	set_groups(new, gi);
>
> where "gi" is usually (in the absence of id squashing) a pointer to
> rqstp->rq_cred.cr_group_info, which can be in use by other threads.
>
> To me it's pretty unintuitive that set_groups() would modify the group
> info passed in the second argument.  While we're here, I wonder if we
> should make that the caller's responsibility?  There are basically only
> three callers outside this one.
>
> But I'm OK with this patch.  I probably need an OK from a vfs person to
> take it through the nfsd tree?
>
> --b.

I tend to agree. I have an updated version of the patches that I'll be 
sending to a broader audience to see if they have any inputs.
