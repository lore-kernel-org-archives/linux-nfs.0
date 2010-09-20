Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:31628 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754165Ab0ITUN7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 16:13:59 -0400
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Pavel Emelyanov <xemul@parallels.com>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org
In-Reply-To: <20100920195635.GA18808@fieldses.org>
References: <4C90BADB.10700@parallels.com>
	 <20100920161326.GL4580@fieldses.org> <4C978CE6.5080508@parallels.com>
	 <20100920180418.GN4580@fieldses.org> <4C97B248.1030801@parallels.com>
	 <EE0DC983-8CFA-42FA-8D64-F4E2564E6FB0@oracle.com>
	 <20100920195635.GA18808@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Sep 2010 16:13:57 -0400
Message-ID: <1285013637.2851.77.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-09-20 at 15:56 -0400, J. Bruce Fields wrote:
> On Mon, Sep 20, 2010 at 03:28:00PM -0400, Chuck Lever wrote:
> > 
> > On Sep 20, 2010, at 3:13 PM, Pavel Emelyanov wrote:
> > > The nearest plan is
> > > 
> > > 1. Prepare the sunrpc layer to work in net namespaces 2. Make
> > > rpcpipefs and nfsd filesystems be mountable multiple times 3. Make
> > > support for multiple instances of the nfsd caches 4. Make suuport
> > > for multiple instances of the nfsd_serv
> > > 
> > > After this several NFSd-s can be used in containers (hopefully I
> > > didn't miss anything).
> > 
> > Are you assuming NFSv4 only?  Something needs to be done about NLM and
> > NSM to make this work right.
> > 
> > Is there an issue for idmapper and svcgssd?  Probably not, but worth
> > exploring.
> > 
> > And, how about AUTH_SYS certs?  These contain the host's name in them,
> > and that depends on the net namespace.  NLM uses AUTH_SYS, and I
> > believe the NFS server can make NLM calls to the client.
> 
> The client probably can't use the auth_sys cred on nlm callbacks in any
> sensible way, so this may not be a big deal.

If clients are per-net namespace, then the cl_nodename can and should be
converted to reflect the utsname()->nodename. We currently force it to
be the init_utsname()->nodename, precisely because we don't support
namespaces.

Cheers
  Trond
