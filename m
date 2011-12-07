Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:5235 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752003Ab1LGIqX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Dec 2011 03:46:23 -0500
Message-ID: <4EDF279C.1060501@parallels.com>
Date: Wed, 07 Dec 2011 12:45:16 +0400
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
Subject: Re: [PATCH] SUNRPC: create svc_xprt in proper network namespace
References: <20111206101910.1878.21798.stgit@localhost6.localdomain6> <20111206204851.GB12640@fieldses.org>
In-Reply-To: <20111206204851.GB12640@fieldses.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

07.12.2011 00:48, J. Bruce Fields пишет:
> On Tue, Dec 06, 2011 at 02:19:10PM +0300, Stanislav Kinsbursky wrote:
>> This patch makes svc_xprt inherit network namespace link from it's socket.
>
> And poor rdma gets left out.

Sorry, but this is not a part of my interest.

> OK.  Applying for 3.3 (with changelog typo
> fixed).
>

Good, thanks.

-- 
Best regards,
Stanislav Kinsbursky
