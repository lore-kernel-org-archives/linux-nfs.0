Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:32917 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752857Ab1JTM4n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 08:56:43 -0400
Message-ID: <4EA01A62.6020209@parallels.com>
Date: Thu, 20 Oct 2011 16:56:02 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [RFC PATCH 0/5] SUNRPC: "RPC pipefs per network namespace" preparations
References: <20111017120629.4541.67395.stgit@localhost6.localdomain6> <4EA000C6.1040502@parallels.com> <20111020123242.GN5444@fieldses.org>
In-Reply-To: <20111020123242.GN5444@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

20.10.2011 16:32, bfields@fieldses.org пишет:
> On Thu, Oct 20, 2011 at 03:06:46PM +0400, Stanislav Kinsbursky wrote:
>> Guys, please, spend some of your expensive time to review this patch-set briefly.
>
> I'll try to take a look soon, but I'm travelling tomorrow through the
> 31st, and things will be a little hectic.
>

Thanks for your time, Bruce.

> Just one quick comment:
>
>>> The only problem about I'm not sure how to solve properly yet, is auth gss
>>> pipes creations operations. Hoping for some help with it.
>
> I suspect one reason it may be a little complicated is the
> upcall-version switching.  The old version is deprecated, and there's no
> need to support the combination of the old version with the a new
> feature like containers.  And now that it's been there a while the
> version-switching code already achieved its goal of avoiding a flag day.
> So, one approach might be:
>
> 	- move all the code for the old gss upcall and for the version
> 	  switching under a new CONFIG_DEPRECATED_GSS, or similar.
> 	- print a warning if the old stuff is used, and plan to rip it
> 	  out completely in a future kernel version.
> 	- do something that works just in the !CONFIG_DEPRECATED_GSS
> 	  case.
>

Thanks for this comment. I'll check the code for problem you mentioned here.
But I was actually talking about other thing.
Currently we create pipe in gss without any checks since we assume, that pipefs 
client dir is created already.
But with approach, represented in this patch set, pipes and dirs will be created 
only when pipefs was mounted from user-space. I.e. clients with gss auth may 
already present and some callback is required for creating gss pipes.
And also this approch assumes existence of gss auth without pipe.

> Would that help?
>
> --b.


-- 
Best regards,
Stanislav Kinsbursky
