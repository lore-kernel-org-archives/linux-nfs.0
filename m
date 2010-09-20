Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57143 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752624Ab0ITT6I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Sep 2010 15:58:08 -0400
Date: Mon, 20 Sep 2010 15:56:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Pavel Emelyanov <xemul@parallels.com>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] sunrpc: Start making sunrpc work in containers
Message-ID: <20100920195635.GA18808@fieldses.org>
References: <4C90BADB.10700@parallels.com>
 <20100920161326.GL4580@fieldses.org>
 <4C978CE6.5080508@parallels.com>
 <20100920180418.GN4580@fieldses.org>
 <4C97B248.1030801@parallels.com>
 <EE0DC983-8CFA-42FA-8D64-F4E2564E6FB0@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <EE0DC983-8CFA-42FA-8D64-F4E2564E6FB0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 20, 2010 at 03:28:00PM -0400, Chuck Lever wrote:
> 
> On Sep 20, 2010, at 3:13 PM, Pavel Emelyanov wrote:
> > The nearest plan is
> > 
> > 1. Prepare the sunrpc layer to work in net namespaces 2. Make
> > rpcpipefs and nfsd filesystems be mountable multiple times 3. Make
> > support for multiple instances of the nfsd caches 4. Make suuport
> > for multiple instances of the nfsd_serv
> > 
> > After this several NFSd-s can be used in containers (hopefully I
> > didn't miss anything).
> 
> Are you assuming NFSv4 only?  Something needs to be done about NLM and
> NSM to make this work right.
> 
> Is there an issue for idmapper and svcgssd?  Probably not, but worth
> exploring.
> 
> And, how about AUTH_SYS certs?  These contain the host's name in them,
> and that depends on the net namespace.  NLM uses AUTH_SYS, and I
> believe the NFS server can make NLM calls to the client.

The client probably can't use the auth_sys cred on nlm callbacks in any
sensible way, so this may not be a big deal.

But, yes, there are probably a lot more details like this; we'll need a
list.

--b.
