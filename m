Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35266 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751920AbdAEQVC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Jan 2017 11:21:02 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Alexander Viro" <viro@zeniv.linux.org.uk>
Cc: "Anna Schumaker" <anna.schumaker@netapp.com>,
        "Trond Myklebust" <trondmy@primarydata.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>,
        "Linux FS-devel Mailing List" <linux-fsdevel@vger.kernel.org>,
        "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFS: switch back to ->iterate()
Date: Thu, 05 Jan 2017 11:21:00 -0500
Message-ID: <66210EA3-EC68-49DA-865F-5068BDA24E8C@redhat.com>
In-Reply-To: <E6C572E9-8458-49F6-AC73-D3B0B8460697@primarydata.com>
References: <0429a1fe130e635337b3103ee5fb1ea4c405fdaf.1481290848.git.bcodding@redhat.com>
 <E6C572E9-8458-49F6-AC73-D3B0B8460697@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 15 Dec 2016, at 17:40, Trond Myklebust wrote:

>> On Dec 9, 2016, at 08:41, Benjamin Coddington <bcodding@redhat.com> 
>> wrote:
>> @@ -519,13 +508,7 @@ void nfs_prime_dcache(struct dentry *parent, 
>> struct nfs_entry *entry)
>> 	filename.hash = full_name_hash(parent, filename.name, filename.len);
>>
>> 	dentry = d_lookup(parent, &filename);
>> -again:
>> -	if (!dentry) {
>> -		dentry = d_alloc_parallel(parent, &filename, &wq);
>> -		if (IS_ERR(dentry))
>> -			return;
>> -	}
>> -	if (!d_in_lookup(dentry)) {
>> +	if (dentry != NULL) {
>
> This all looks like it is reverting to using an obsolete VFS API. 
> I’d
> prefer an ACK from Al as to whether or not this is allowed. Please 
> note
> that the rest of the lookup code is still parallelised.

I should've made sure the revert wasn't going to jump back to older VFS
usage.  I'll go back over this to make sure that's not the case.

Al, are you hoping to get rid of ->iterate completely?  If so, better to
work on this another way.

Ben
