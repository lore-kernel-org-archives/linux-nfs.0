Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:45498 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755367Ab2CAH3n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Mar 2012 02:29:43 -0500
Message-ID: <4F4F2551.6080003@parallels.com>
Date: Thu, 01 Mar 2012 11:29:21 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v7 5/5] nfsd: add the infrastructure to handle the cld
 upcall
References: <1330535757-24925-1-git-send-email-jlayton@redhat.com>	<1330535757-24925-6-git-send-email-jlayton@redhat.com>	<4F4E70C5.9030608@parallels.com> <20120229144512.37de84e7@tlielax.poochiereds.net>
In-Reply-To: <20120229144512.37de84e7@tlielax.poochiereds.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

29.02.2012 23:45, Jeff Layton пишет:
> On Wed, 29 Feb 2012 22:39:01 +0400
> Stanislav Kinsbursky<skinsbursky@parallels.com>  wrote:
>
>> Hi, Jeff.
>> I'll try to explain, how all this namespaces-aware SUNRPC PipeFS works.
>> The main idea is, that today we have 2 types of independently created and
>> destroyed but linked objects:
>> 1) pipe data itself. This object is created whenever kernel requires (on mount,
>> module install, whatever)
>> 2) dentry/inode for this pipe. This object is created on PipeFS superblock creation.
>> This means, any kernel user of SUNRPC pipes have to provide two mechanisms:
>> 1) Safe call (in per-net operations, if the object is global your case) for
>> PipeFS dentry/inode pair. This is done this in nfsd4_init_cld_pipe().
>>
>> 2) Notifier callback for PipeFS mount/umount operations. Note: this callback is
>> done from SUNRPC module (i.e. you have to get nfsd module); this callback is
>> safe - i.e you can be sure, that superblock is valid.
>>
>
> This is the part I'm having a hard time with. IIUC, the existing
> examples are fairly clear since you have a 1:1 ratio of objects: a
> per-net object (the pipe data) that is hooked up to a dentry/inode in a
> per-net sb.
>
> Here though, we don't really have that. We have a global pipe object
> and I don't see how you can hook that up to multiple dentries/inodes.
>
> One possibility is to completely "namespacify" this code -- don't use a
> global rpc_pipe object and make it per-net instead. If I do that though,
> then I suppose I'll also need to make all of the
> nfsd4_client_tracking_ops take a struct net arg as well?
>
> Thanks for the help so far...

There is no problem at all.
Would be great (for me - eventially I'll update it to namespace aware code) if 
you'll convert you code into something like this:
1) Safe and unsafe dentry creation routines, parametrized by net. Don't use 
per-net data - hard-code your global pointer.
2) Pipe data creation routine, parametrized by net. Call this one only for 
"init_net" for far - no per-net ops required. Also call safe dentry creation 
routine here.
3) Notifier callback - just ignore any callbacks from not init_net. Otherwise 
call unsafe dentry creation routine.

If you'll do so, then it will be very easy to convert this feature to network 
namespace aware.

-- 
Best regards,
Stanislav Kinsbursky
