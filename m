Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:16220 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751614Ab1ITOgH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 10:36:07 -0400
Message-ID: <4E78A4AF.1020303@parallels.com>
Date: Tue, 20 Sep 2011 18:35:27 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Subject: Re: [PATCH v4 1/8] SUNRPC: introduce helpers for reference counted
 rpcbind clients
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6> <20110920101341.9861.51453.stgit@localhost6.localdomain6> <4E788F8C.20103@netapp.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD10@SACMVEXC2-PRD.hq.netapp.com> <4E789679.1060601@parallels.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD22@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430B47FD22@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

20.09.2011 18:14, Myklebust, Trond пишет:

>>>
>>> Doesn't it  need to be protected by rpcb_clnt_lock too?
>>>
>>
>> Nope from my pow. It's protected by rpcb_create_local_mutex. I.e. no one
>> will change rpcb_users since it's zero. If it's non zero - we willn't get to
>> rpcb_set_local().
>
> OK, so you are saying that the rpcb_users++ below could be replaced by rpcb_users=1?
>

Yes, you right.

> In that case, don't you need a smp_wmb() between the setting of rpcb_local_clnt/4 and the setting of rpcb_users? Otherwise, how do you guarantee that rpcb_users != 0 implies rpbc_local_clnt/4 != NULL?
>

We check rpcb_users under spinlock. Gain spinlock forces memory barrier, doesn't it?

-- 
Best regards,
Stanislav Kinsbursky
