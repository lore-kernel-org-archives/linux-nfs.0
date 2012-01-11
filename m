Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:42406 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933507Ab2AKSDj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jan 2012 13:03:39 -0500
Message-ID: <4F0DCEE5.5090100@parallels.com>
Date: Wed, 11 Jan 2012 22:03:17 +0400
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
Subject: Re: [PATCH 0/5] NFS: create blocklayout pipe per network namesapce
 context
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>			 <1325285705.10984.4.camel@lade.trondhjem.org>		 <1325797111.11084.22.camel@lade.trondhjem.org>		 <4F0C35F3.7060508@parallels.com>	 <1326299003.17212.7.camel@lade.trondhjem.org>	 <4F0DC582.6030805@parallels.com> <1326303963.19024.1.camel@lade.trondhjem.org>
In-Reply-To: <1326303963.19024.1.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

11.01.2012 21:46, Trond Myklebust пишет:
> On Wed, 2012-01-11 at 21:23 +0400, Stanislav Kinsbursky wrote:
>> I've sent rebased "v2" of the patch set, contains updated patch "SUNRPC: handle
>> RPC client pipefs dentries by network namespace aware routine", which, I
>> believe, fixes oops, spotted by Bryan (it was caused by excessive call of
>> rpc_put_mount() on PipeFS dentries unlink).
>> So, if I'm not mistaken here, there's no need in implementing of dummy versions
>> of rpc_pipefs_notifier_(un)register() or any other dummy stuff.
>
> OK. Fair enough. We'll give it some testing to make sure that we don't
> hit it again...
>
>> BTW, it looks like that in last 2 days I've sent all updates to the issues you
>> pointed out. If not, please, ping me once more.
>
> I'm in the process of reviewing it right now.
>

Cool, thanks, Trond.

> Cheers
>    Trond
>


-- 
Best regards,
Stanislav Kinsbursky
