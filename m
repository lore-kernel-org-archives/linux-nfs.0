Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:24973 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546Ab2ATLLF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jan 2012 06:11:05 -0500
Message-ID: <4F194B7F.4030002@parallels.com>
Date: Fri, 20 Jan 2012 15:09:51 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v2 0/5] SUNRPC: make caches network namespace aware
References: <20120119173823.23767.91876.stgit@localhost6.localdomain6>
In-Reply-To: <20120119173823.23767.91876.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've tested NFSd under load - works like a charm (showmount reported right info).
I've tested NFS mounts on host node - looks like all works fine.
Also I've tested NFS mounts on host node and in container in the same time. 
There are some problems here. Most likely caused by user-space daemons, 
conflicting between themselves because of wrong initialization environment (like 
rpcbind registering problems, which I've raised in the list already).
So looks like the patches suitable for devel branch.

BTW, thanks to careful review, Bruce.

-- 
Best regards,
Stanislav Kinsbursky
