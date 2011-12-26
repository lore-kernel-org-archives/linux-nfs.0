Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:26493 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754703Ab1LZLvQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Dec 2011 06:51:16 -0500
Message-ID: <4EF85F8B.6070004@parallels.com>
Date: Mon, 26 Dec 2011 15:50:35 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v2 0/6] SUNPRC: cleanup PipeFS for network-namespace-aware
 users
References: <20111226114042.13743.73804.stgit@localhost6.localdomain6>
In-Reply-To: <20111226114042.13743.73804.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Trond.
This patch set depend on
"SUNRPC: initial part of making pipefs work in net ns"
and
"SUNRPC: remove non-exclusive pipe creation from RPC pipefs"

I'm not sure about did you applied them already or not, so I've rebased and 
resent them too.

-- 
Best regards,
Stanislav Kinsbursky
