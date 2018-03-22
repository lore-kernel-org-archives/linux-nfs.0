Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([85.220.165.71]:55423 "EHLO
        metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752764AbeCVJZ1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 22 Mar 2018 05:25:27 -0400
Message-ID: <1521710718.21240.1.camel@pengutronix.de>
Subject: Re: [PATCH] nfsd: zero out umask if the client didn't provide one
From: Lucas Stach <l.stach@pengutronix.de>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        kernel@pengutronix.de, patchwork-lst@pengutronix.de,
        agruenba@redhat.com
Date: Thu, 22 Mar 2018 10:25:18 +0100
In-Reply-To: <20180321213505.GI4288@fieldses.org>
References: <20180321195242.4250-1-l.stach@pengutronix.de>
         <20180321213505.GI4288@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Am Mittwoch, den 21.03.2018, 17:35 -0400 schrieb J . Bruce Fields:
> On Wed, Mar 21, 2018 at 08:52:42PM +0100, Lucas Stach wrote:
> > When the server is serving a mixed set of clients where some support the
> > NFS 4.2 umask attribute and some don't, we need to make sure to reset the
> > nfd thread umask to 0 when serving a client that isn't providing the umask,
> > otherwise a stale umask from a previous request will be applied.
> > 
> > This was only done in the nfsd4_decode_open() callsite, but not in
> > nfsd4_decode_create() leading to newly created directories ending up with
> > wrong permissions in some cases. To avoid any such inconsistency in the
> > future, reset the umask in nfsd4_decode_fattr() where we know if the
> > client did provide a umask.
> 
> Thanks for catching this!  (Is it because you were seeing directories
> created with incorrect permissions in production?)

Yes, we have hit this in our internal infrastructure.

> If the next rpc handled by this thread doesn't include a file attribute,
> or isn't an NFSv4 request (maybe it's NFSv3), then it won't hit this
> code and will still use the non-zero umask.

The thread umask seem to be only relevant for the open/create RPC
calls, but you are right about the NFS3 case. I didn't think of that.

> I was thinking of initializing it in nfsd_setuser, or maybe on each pass
> through the loop that processes each op of a compound in
> nfsd4_proc_compound....  But I think that would clear umask too
> often--it'd clear the umask before it was actually used.
> 
> Actually I don't think there's any correct time to clear the umask, the
> problem is where we're setting it.
> 
> We decode the whole compound in one pass, then process each op of an
> NFSv4 compound.  That means the last op containing a set of the umask
> will determine the umask used for the whole compound.  That seems wrong.
> 
> I mean, in practice no real client sends compounds with multiple create
> operations, so maybe this is all academic, but still I think the correct
> thing to do is stop setting current->fs->umask in the xdr decoder and
> instead pass the umask value in the compound op arguments and set it
> later in the proc code.

Yes, this seems like a better way to deal with this. I'll respin this
patch.

Thanks,
Lucas
