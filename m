Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:39115 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755223Ab1KWRUL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Nov 2011 12:20:11 -0500
Message-ID: <4ECD2AF1.9090101@parallels.com>
Date: Wed, 23 Nov 2011 21:18:41 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 0/6] SUNRPC: make RPC clients use network-namespace-aware
 PipeFS routines
References: <20111123104945.11077.10270.stgit@localhost6.localdomain6> <20111123162711.GA30672@fieldses.org>
In-Reply-To: <20111123162711.GA30672@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

23.11.2011 20:27, J. Bruce Fields пишет:
> On Wed, Nov 23, 2011 at 02:51:10PM +0300, Stanislav Kinsbursky wrote:
>> This patch set was created in context of clone of git
>> branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
>> tag: v3.1
>>
>> This patch set depends on previous patch sets titled:
>> 1) "SUNRPC: initial part of making pipefs work in net ns"
>> 2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"
>
> Do you have a git tree set up with all of these applied?
>

I have, but no external access to it yet.

> (If I want to take a quick look it would personally be easier for me to
> fetch your git tree than to get those patches out of old email.)
>

Will check tomorrow, is it possible to organize it.

> --b.
>


-- 
Best regards,
Stanislav Kinsbursky
