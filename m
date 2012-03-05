Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:24470 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756839Ab2CEMvb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 07:51:31 -0500
Message-ID: <4F54B6B7.1010703@parallels.com>
Date: Mon, 05 Mar 2012 16:51:03 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v8 5/6] nfsd: add the infrastructure to handle the cld
 upcall
References: <1330720950-5872-1-git-send-email-jlayton@redhat.com>	<1330720950-5872-6-git-send-email-jlayton@redhat.com>	<4F547DF1.8090003@parallels.com> <20120305074256.6dc36fed@tlielax.poochiereds.net>
In-Reply-To: <20120305074256.6dc36fed@tlielax.poochiereds.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

05.03.2012 16:42, Jeff Layton пишет:
>>
>>
>> Would be great to replace hard-coded cld_pipe here with a passed one.
>> For example, put this cld_pipe on cld_msg structure.
>> And initialize this pointer (hard-coded value for now) below in
>> nfsd4_cld_create() and all other places where alloc_cld_upcall() is called.
>>
>> BTW, maybe allocate this struct cld_upcall per NFS client somehow? And thus get
>> rid of alloc-free calls?
>>
>>
>
> Ok, I think I must have misunderstood what you meant when you said no
> per-net ops required. I'll respin and see if I can get closer to what
> you intended.
>
> Since most of the upcalls are infrequent and come from nfsd threads,
> the number of calls in flight will always be less than the order of the
> number of nfsd threads. That value may be much less than the number of
> nfs4_clients, so we're probably best off allocating these dynamically.
>


Sure, it's up to you. Only wanna note, that this dynamic allocation in several 
places looks a little bit confusing to me.


> Now that I've had some time to look, I think what you're probably going
> to want to do eventually is to add a new per-namespace object for nfsd,
> similar to struct nfs_net for the nfs client. This container will hold
> the pointer to the upcall pipe as well as other objects.
>

Exactly.

> The nfs4_client objects for nfsd will then need to be per-namespace,
> and will have a pointer back to "struct nfsd_net" or whatever you end up
> calling it. From that they'll be able to get the rpc_pipe pointer.
>

You most probably right (I'm not working on NFSd yet - so hard to be sure).

> For now, I'll just hardcode init_net in the appropriate places under the
> assumption that eventually you'll be able to get a rpc_pipe pointer
> given a pointer to an nfs4_client struct.
>

Yes, thank you, Jeff.

-- 
Best regards,
Stanislav Kinsbursky
