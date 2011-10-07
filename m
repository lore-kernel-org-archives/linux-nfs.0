Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:21740 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759692Ab1JGKTJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Oct 2011 06:19:09 -0400
Message-ID: <4E8ED210.1030506@parallels.com>
Date: Fri, 07 Oct 2011 14:18:56 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>,
        "Kirill A. Shutemov" <kas@openvz.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: network-namespace-aware nfsd
References: <20111005150214.GA18449@fieldses.org> <4E8C9363.9030303@parallels.com> <20111005181959.GB18449@fieldses.org> <4E8D7BED.6020705@parallels.com> <20111006164632.GC21627@fieldses.org>
In-Reply-To: <20111006164632.GC21627@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

06.10.2011 20:46, J. Bruce Fields пишет:
> On Thu, Oct 06, 2011 at 01:59:09PM +0400, Stanislav Kinsbursky wrote:
>> 05.10.2011 22:19, J. Bruce Fields пишет:
>>> To start with I suspect it would be OK to share the one lockd thread.
>>>
>>
>> Yep, I think so too. It just will be harder to implement.
>
> Why do you think it will be harder to implement?
>

Because making lockd kthread per net ns is very easy. :)

> There may be something about how tasks and namespaces interact that I'm
> missing here....
>

The main problem, as I see it now, is creating and especially destroying lockd 
rpcbind clients (and per ns data) on CT stop.
Right now they are destroyed on lockd kthread exit. And we can't make this 
destruction in per-net operations since those clients holds net ns.
Thus, nlmclnt_init(done) logic have to be significantly reworked.

> To me it seems like either way we're going to have to add the network
> namespace as an argument to any data structure lookups that we're doing,
> and it doesn't really matter whether we get the namespace out of the
> svc_rqst or someplace else.
>

Yep, seems the same to me.

> --b.


-- 
Best regards,
Stanislav Kinsbursky
