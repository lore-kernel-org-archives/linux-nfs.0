Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37590 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751139AbcLHOTZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Dec 2016 09:19:25 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: Concurrent `ls` takes out the thrash
Date: Thu, 08 Dec 2016 09:18:36 -0500
Message-ID: <790E1295-EBBE-4059-9EEC-D2C9CD36EA20@redhat.com>
In-Reply-To: <C3824A8A-17EF-465F-8267-55F0AD2C4239@redhat.com>
References: <C2A81CDB-ED8F-4D41-919F-3F92CBFF751B@redhat.com>
 <CEE29C1D-BB8F-4504-940D-43DE1FE63385@primarydata.com>
 <7DA8E9BE-7353-44D5-B982-B477CF7B0A57@redhat.com>
 <934FC075-4393-42AD-92A3-3BC3BE580699@redhat.com>
 <6C5DA8AC-9A42-45FA-892C-E9597A7F7AC9@primarydata.com>
 <EC88DF6D-5A78-499C-A6A8-A5D74083876F@redhat.com>
 <3C863AB4-D07A-494A-AD7B-87BF31496777@primarydata.com>
 <C3824A8A-17EF-465F-8267-55F0AD2C4239@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 7 Dec 2016, at 18:10, Benjamin Coddington wrote:

> On 7 Dec 2016, at 17:59, Trond Myklebust wrote:
>
>>> On Dec 7, 2016, at 17:55, Benjamin Coddington <bcodding@redhat.com> 
>>> wrote:
>>>
>>> On 7 Dec 2016, at 17:41, Trond Myklebust wrote:
>>>
>>>>> On Dec 7, 2016, at 17:34, Benjamin Coddington 
>>>>> <bcodding@redhat.com> wrote:
>>>>> static
>>>>> @@ -921,7 +930,7 @@ static int nfs_readdir(struct file *file, 
>>>>> struct dir_context *ctx)
>>>>> 	desc->ctx = ctx;
>>>>> 	desc->dir_cookie = &dir_ctx->dir_cookie;
>>>>> 	desc->decode = NFS_PROTO(inode)->decode_dirent;
>>>>> -	desc->plus = nfs_use_readdirplus(inode, ctx) ? 1 : 0;
>>>>> +	desc->plus = nfs_use_readdirplus(inode, ctx, dir_ctx) ? 1 : 0;
>>>>
>>>> This fixes desc->plus at the beginning of the readdir() call. 
>>>> Perhaps we
>>>> should instead check the value of ctx->use_readdir_plus in the call 
>>>> to
>>>> nfs_readdir_xdr_filler(), and just resetting cts->use_readdir_plus 
>>>> at the
>>>> very end of nfs_readdir()?
>>>
>>> I don't understand the functional difference.  Is this just a 
>>> preference?
>>
>> No. The functional difference is that we take into account the fact 
>> that a
>> process may be in the readdir() code while a GETATTR or LOOKUP from a
>> second process is triggering “use readdirplus” feedback.
>
> This should only matter if the concurrent processes have different 
> buffer
> sizes or start at a different offsets -- which shouldn't happen with 
> plain
> old 'ls -l'.
>
> .. or maybe I'm wrong if, hmm..  if acdirmin ran out (maybe?).. or if 
> we mix
> 'ls -l' and 'ls'.. or if we have pages getting reclaimed.. OK.  I'll 
> try it.

This doesn't help.

The issue is that anything more than a couple of processes cause 
contention
on the directory's i_lock.  The i_lock is taken x entries x processes. 
The
inode flags and serialization worked far better.

If we add another inode flag, then we can add a DOING_RDPLUS.  A process
entering nfs_readdir() that sees ADVISE and not DOING clears it and sets
DOING and remembers to clear DOING on exit of nfs_readdir().  Any 
process
that sees DOING uses plus.

Ben
