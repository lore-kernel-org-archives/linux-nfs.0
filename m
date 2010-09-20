From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
Date: Mon, 20 Sep 2010 17:43:38 -0400
Message-ID: <20100920214338.GG18808@fieldses.org>
References: <4C90BADB.10700@parallels.com>
 <20100920161326.GL4580@fieldses.org>
 <4C978CE6.5080508@parallels.com>
 <20100920180418.GN4580@fieldses.org>
 <4C97B248.1030801@parallels.com>
 <1285013116.2851.71.camel@heimdal.trondhjem.org>
 <20100920200950.GB18808@fieldses.org>
 <1285018566.2851.159.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelyanov <xemul@parallels.com>, Neil Brown <neilb@suse.de>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46938 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755282Ab0ITVpF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 17:45:05 -0400
In-Reply-To: <1285018566.2851.159.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 20, 2010 at 05:36:06PM -0400, Trond Myklebust wrote:
> On Mon, 2010-09-20 at 16:09 -0400, J. Bruce Fields wrote:
> > For the client, that's initially the net namespace of the mount?  (What
> > about submounts?)
> 
> It is the net namespace of the process that does the mount, yes.
> 
> > >  2) Convert rpc_pipefs to be per-net namespace.
> > >  3) Convert the nfs_client and superblock to be per-net namespace
> > >  4) Convert lockd's struct host to be per-net namespace
> > 
> > What do we expect behavior to actually look like from the point of view
> > of somebody on the client?
> > 
> > I'd like to see someone write some kind of spec for how this should all
> > work.  That worries me a lot more than the code.....
> 
> I think it is fairly obvious what should happen once you are in a net
> namespace jail: you want all future NFS mounts to confine themselves to
> that private net namespace. i.e. they must talk to the portmapper,
> rpc.statd, and rpc.gssd that are defined on that net namespace, and they
> must confine themselves to that net namespace when talking to servers.
> 
> The problem is dealing with clone() and unshare() (i.e. the process of
> changing net namespaces).
> If the resulting container inherits an NFS mountpoint from its parent
> process, then I cannot see how we could sanely migrate that to a new net
> namespace, since the super block etc remains shared between the two
> containers as part of the mount namespaces. To avoid confusion, I
> believe we need to ensure that under-the-cover mounts etc inherit the
> same net namespace as the original mount, and they should talk to the
> portmapper, rpc.statd and rpc.gssd that the original mount uses.

OK, that sounds right to me.

--b.

> If
> those die, then too bad - that's operator error.
