Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:8587 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757753Ab2AMKEB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jan 2012 05:04:01 -0500
Message-ID: <4F10017B.3070808@parallels.com>
Date: Fri, 13 Jan 2012 14:03:39 +0400
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
Subject: Re: [PATCH v5 0/6] SUNRPC: rcbind clients virtualization
References: <20120113084545.31750.83655.stgit@localhost6.localdomain6>
In-Reply-To: <20120113084545.31750.83655.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

13.01.2012 12:52, Stanislav Kinsbursky пишет:
> This patch-set was created in context of clone of git branch:
> git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
> head: devel
>
> v5:
> 1) Rebased on up-to-date state ("devel" head).
> 2) Added two more patches from latter series ("SUNRPC: register services with
> per-net rpcbind"), because logically this series is the more suitable place for
> them.

Three patches from "SUNRPC: register services with per-net rpcbind" series:
a) [1/7] "SUNRPC: create rpcbind client in passed network namespace context"
b) [2/7] "SUNRPC: register rpcbind programs in passed network namespase context"
c) [4/7] "SUNRPC: parametrize local rpcbind clients creation with net ns"

-- 
Best regards,
Stanislav Kinsbursky
