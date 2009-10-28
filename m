From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs: convert proto= option to use netid's rather than a
 protoname
Date: Wed, 28 Oct 2009 18:41:06 -0400
Message-ID: <20091028184106.019ccbc6@tlielax.poochiereds.net>
References: <1256758812-24928-1-git-send-email-jlayton@redhat.com>
	<9EF4B3B4-5F00-4E66-81AA-ADDF348ADED4@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48946 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752062AbZJ1WlH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Oct 2009 18:41:07 -0400
In-Reply-To: <9EF4B3B4-5F00-4E66-81AA-ADDF348ADED4@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 28 Oct 2009 16:15:33 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> >
> > /*
> > @@ -578,7 +609,7 @@ static void nfs_show_mount_options(struct  
> > seq_file *m, struct nfs_server *nfss,
> > 			seq_puts(m, nfs_infop->nostr);
> > 	}
> > 	seq_printf(m, ",proto=%s",
> > -		   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_PROTO));
> > +		   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_NETID));
> 
> Does that do the right thing for rdma mounts, currently?
> 

Unfortunately, I don't have an easy way to test this with RDMA yet, but
it looks like it'll do the right thing. The RPC_DISPLAY_PROTO and
RPC_DISPLAY_NETID strings both get set to "rdma".

As best I can tell IPv6 support for RDMA doesn't exist yet, so that
seems to be the right thing to do for now.

-- 
Jeff Layton <jlayton@redhat.com>
