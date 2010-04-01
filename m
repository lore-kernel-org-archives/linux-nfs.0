Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:58409 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756696Ab0DAOHp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Apr 2010 10:07:45 -0400
Subject: Re: why does each NFS mount have (at least) 2 rpc_clnt's ?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Ondrej Valousek <webserv@s3group.cz>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
In-Reply-To: <4BB49F0D.80009@s3group.cz>
References: <20100401084620.3475d4c0@barsoom.rdu.redhat.com>
	 <1270127869.3533.12.camel@localhost.localdomain>
	 <4BB49F0D.80009@s3group.cz>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 01 Apr 2010 10:07:40 -0400
Message-ID: <1270130860.3533.19.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-04-01 at 15:26 +0200, Ondrej Valousek wrote: 
> Hi Trond,
> 
> Does it have anything to do with the situation when we want an the same 
> filesystem to be mounted twice somewhere else with a different flags? 
> (i.e. RO/RW for example)
> If yes, I remember some discussion about it in the past (the above was 
> not possible).
> Thanks,

Yes. That's exactly what it is supposed to allow (and btw, mounting
filesystems both ro and rw should be possible now).

Cheers
  Trond

> Ondrej
> > Look again at nfs_init_server_rpcclient(). The pseudoflavour is not the
> > only thing that is changed. We also change the soft flag and the timeout
> > properties of the server->client.
> >
> > The point is that users sometimes want to specify per-mountpoint
> > transport properties, and so we try to give them that possibility, while
> > at the same time sharing sockets/rdma connections.
> >
> > Cheers
> >   Trond
> >
> > _______________________________________________
> > NFSv4 mailing list
> > NFSv4@linux-nfs.org
> > http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
> >   
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



