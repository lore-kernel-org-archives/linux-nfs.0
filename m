Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41468 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752148AbcLGTqU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 7 Dec 2016 14:46:20 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trondmy@primarydata.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: Re: Concurrent `ls` takes out the thrash
Date: Wed, 07 Dec 2016 14:46:17 -0500
Message-ID: <7DA8E9BE-7353-44D5-B982-B477CF7B0A57@redhat.com>
In-Reply-To: <CEE29C1D-BB8F-4504-940D-43DE1FE63385@primarydata.com>
References: <C2A81CDB-ED8F-4D41-919F-3F92CBFF751B@redhat.com>
 <CEE29C1D-BB8F-4504-940D-43DE1FE63385@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 7 Dec 2016, at 10:46, Trond Myklebust wrote:

>> On Dec 7, 2016, at 08:28, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>>
>> I was asked to figure out why the listing of very large directories 
>> was
>> slow.  More specifically, why concurrently listing the same large 
>> directory
>> is /very/ slow.  It seems that sometimes a user's reaction to waiting 
>> for
>> 'ls' to complete is to start a few more.. and then their machine 
>> takes a
>> very long time to complete that work.
>>
>> I can reproduce that finding.  As an example:
>>
>> time ls -fl /dir/with/200000/entries/ >/dev/null
>>
>> real    0m10.766s
>> user    0m0.716s
>> sys     0m0.827s
>>
>> But..
>>
>> for i in {1..10}; do time ls -fl /dir/with/200000/entries/ >/dev/null 
>> & done
>>
>> Each of these ^^ 'ls' commands will take 4 to 5 minutes to complete.
>>
>> The problem is that concurrent 'ls' commands stack up in 
>> nfs_readdir() both
>> waiting on the next page and taking turns filling the next page with 
>> xdr,
>> but only one of them will have desc->plus set because setting it 
>> clears the
>> flag on the directory.  So if a page is filled by a process that 
>> doesn't have
>> desc->plus then the next pass through lookup(), it dumps the entire 
>> page
>> cache with nfs_force_use_readdirplus().  Then the next readdir starts 
>> all
>> over filling the pagecache.  Forward progress happens, but only after 
>> many
>> steps back re-filling the pagecache.
>
> Yes, the readdir code was written well before Al’s patches to 
> parallelise
> the VFS operations, and a lot of it did rely on the inode->i_mutex 
> being
> set on the directory by the VFS layer.
>
> How about the following suggestion: instead of setting a flag on the
> inode, we iterate through the entries in &nfsi->open_files, and set a 
> flag
> on the struct nfs_open_dir_context that the readdir processes can copy
> into desc->plus. Does that help with your workload?

That should work.. I guess I'll hack it up and present it for 
dissection.

Thanks!
Ben
