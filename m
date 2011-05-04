Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12862 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754391Ab1EDPbE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2011 11:31:04 -0400
Subject: Re: [[RFC] 1/1] SUNRPC: dynamic rpc_slot allocator for TCP
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Andy Adamson <andros@netapp.com>, NeilBrown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
In-Reply-To: <20110504111853.7150915a@tlielax.poochiereds.net>
References: <1304386808-2733-1-git-send-email-andros@netapp.com>
	 <1304386808-2733-2-git-send-email-andros@netapp.com>
	 <20110503202023.699435f4@corrin.poochiereds.net>
	 <1304469890.26184.16.camel@lade.trondhjem.org>
	 <20110504111825.6f26f75a@notabene.brown>
	 <1304473563.26184.28.camel@lade.trondhjem.org>
	 <20110504120726.347df3fc@notabene.brown>
	 <20110504075410.5e59c6b4@tlielax.poochiereds.net>
	 <0424D640-C315-449B-847A-59105BBADBCE@netapp.com>
	 <20110504111853.7150915a@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 04 May 2011 11:30:46 -0400
Message-ID: <1304523046.4476.7.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-05-04 at 11:18 -0400, Jeff Layton wrote:
> The other thing you have to determine is whether you want this
> guaranteed number of slots to be per-xprt or global. Today, it's
> per-xprt. Making it global might mean less wasted memory overall, but I
> could forsee situations where a hung mount could starve other mounts of
> slots.

The hung mount scenario is one that we're not going to deal too well
with anyway: both rpc_tasks and rpc buffers are allocated from global
mempools (as are the struct nfs_read_data/nfs_write_data)

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

