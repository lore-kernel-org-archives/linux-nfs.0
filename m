From: David Howells <dhowells@redhat.com>
Subject: Re: RCU-isms in fs/nfs/delegation.c
Date: Tue, 20 Apr 2010 09:48:34 +0100
Message-ID: <32174.1271753314@redhat.com>
References: <1271698361.13653.79.camel@localhost.localdomain> <14317.1271691185@redhat.com>
Cc: dhowells@redhat.com, paulmck@linux.vnet.ibm.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34536 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754047Ab0DTIsj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Apr 2010 04:48:39 -0400
In-Reply-To: <1271698361.13653.79.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> +		nfs_inode_set_delegation(inode, cred, res);
> +	}
> +out:
> +	rcu_read_unlock();
>  }

I think this is wrong.  nfs_inode_set_delegation() may sleep as it calls
kmalloc() with GFP_KERNEL - but you still have the RCU read lock held.  I
think you need to drop the RCU read lock before calling it.

David
