Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:17790 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933145Ab1LFMrJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Dec 2011 07:47:09 -0500
Message-ID: <4EDE0E29.9030804@parallels.com>
Date: Tue, 06 Dec 2011 16:44:25 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH] SUNRPC: create svc_xprt in proper network namespace
References: <20111206101910.1878.21798.stgit@localhost6.localdomain6> <20111206124427.GA12890@umich.edu>
In-Reply-To: <20111206124427.GA12890@umich.edu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

06.12.2011 16:44, Jim Rees пишет:
> Stanislav Kinsbursky wrote:
>
>    This patch makes svc_xprt inherit network namespace link from it's socket.
>
> Should be "its socket."

Yep, sure. Silly mistake.
Thanks.

-- 
Best regards,
Stanislav Kinsbursky
