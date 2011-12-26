Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:18080 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755383Ab1LZMZn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Dec 2011 07:25:43 -0500
Message-ID: <4EF867A2.2020003@parallels.com>
Date: Mon, 26 Dec 2011 16:25:06 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] SUNRPC: make SUNPRC clients list per network namespace
 context
References: <20111214081918.2804.59143.stgit@localhost6.localdomain6> <1324817295.5195.0.camel@lade.trondhjem.org>
In-Reply-To: <1324817295.5195.0.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

25.12.2011 16:48, Trond Myklebust пишет:
> On Wed, 2011-12-14 at 12:19 +0300, Stanislav Kinsbursky wrote:
>> This patch moves static SUNRPC clients list and it's lock to sunrpc_net
>> structure.
>> Currently this list is used only for debug purposes. But later it will be used
>> also for selecting clients by networks namespace on PipeFS mount/umount events.
>> Per-network namespace lists will make this faster and simplier.
>>
>> Note: client list is taken from "init_net" network namespace context in
>> rpc_show_tasks(). This will be changed with making SUNRPC sysctl's per network
>> namespace context.
>>
>> Signed-off-by: Stanislav Kinsbursky<skinsbursky@parallels.com>
>
> This doesn't seem to integrate with any of your patch series, and
> conflicts with everything that touches netns.h, for instance...
>

Yep, you are right. Currently this path doesn't apply, if you'll try to apply 
patches in the same order I've sent them.
This is caused by different development branches.
Anyway, most of the patches will not apply to current tree.
And I'll be glad to rebase and resent them on request.

-- 
Best regards,
Stanislav Kinsbursky
