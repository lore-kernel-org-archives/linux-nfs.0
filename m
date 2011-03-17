Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:27092 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846Ab1CQRFE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 13:05:04 -0400
Message-ID: <4D823F1F.6010500@parallels.com>
Date: Thu, 17 Mar 2011 20:04:31 +0300
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "skinsbursky@openvz.org" <skinsbursky@openvz.org>
Subject: Re: [PATCH] RPC: killing RPC tasks races fixed
References: <20110317121638.15035.39410.stgit@localhost6.localdomain6>	 <1300366904.9654.13.camel@lade.trondhjem.org>	 <4D822C3C.9090100@parallels.com> <1300380254.28305.1.camel@lade.trondhjem.org>
In-Reply-To: <1300380254.28305.1.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

17.03.2011 19:44, Trond Myklebust пишет:
>
> Are you sure? Why would the 2.6.32 rhel kernel differ from the mainline
> 2.6.32 kernel in this respect?
>

Checked again and realized, that was wrong.
This set sequence is the same in 2.6.32 rhel, 2.6.32 and 2.6.38 kernels.

-- 
Best regards,
Stanislav Kinsbursky
