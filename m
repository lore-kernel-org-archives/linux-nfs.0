Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:49052 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754196Ab1LZKrB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Dec 2011 05:47:01 -0500
Message-ID: <4EF85064.6040907@parallels.com>
Date: Mon, 26 Dec 2011 14:45:56 +0400
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
Subject: Re: [PATCH 6/6] SUNRPC: split SUNPRC PipeFS dentry and private pipe
 data creation
References: <20111122134514.479.9848.stgit@localhost6.localdomain6>	 <20111122144215.479.20931.stgit@localhost6.localdomain6> <1324819019.5195.4.camel@lade.trondhjem.org>
In-Reply-To: <1324819019.5195.4.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

25.12.2011 17:16, Trond Myklebust пишет:
>> @@ -387,7 +397,9 @@ nfs_idmap_delete(struct nfs_client *clp)
>> >
>> >         if (!idmap)
>> >                 return;
>> >  -     rpc_unlink(idmap->idmap_dentry);
>> >  +     if (idmap->idmap_pipe->dentry)
> Shouldn't this be a test for IS_ERR(idmap->idmap_pipe->dentry)?
>

Nope. This dentry is either NULL or valid pointer.
Will resend rebased version soon.

-- 
Best regards,
Stanislav Kinsbursky
