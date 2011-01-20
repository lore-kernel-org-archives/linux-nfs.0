Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55515 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753070Ab1ATPwr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Jan 2011 10:52:47 -0500
Date: Thu, 20 Jan 2011 10:52:39 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Rob Landley <rlandley@parallels.com>
Cc: "Kirill A. Shutemov" <kas@openvz.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Neil Brown <neilb@suse.de>, Pavel Emelyanov <xemul@parallels.com>,
        linux-nfs@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        containers@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 00/16] make rpc_pipefs be mountable multiple time
Message-ID: <20110120155238.GD11588@fieldses.org>
References: <1295012954-7769-1-git-send-email-kas@openvz.org>
 <4D343658.1020205@parallels.com>
 <20110120113552.GB24349@shutemov.name>
 <4D383F60.4080907@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D383F60.4080907@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Jan 20, 2011 at 07:57:52AM -0600, Rob Landley wrote:
> I've also mounted NFS shares in test environments I never mounted
> rpc_pipefs in.  (It's possible that the nfs.mount command was doing so
> for me, and apparently unmounting it again afterwards.)  My test
> environment is exporting with the userspace NFS daemon so it's not using
> the kernel cacheing infrastructure.

If you grep for rpc_mkpipe() you'll see it's only used in the idmapping
and rpcsec_gss code; which means you wouldn't need it unless using NFSv4
(which uses idmapping) or rpcsec_gss.

> > There is client dir (nfs/clntX) in rpc_pipefs for every sunrpc client.
> > Both client and server (see fs/nfsd/nfs4callback.c) can create sunrpc
> > client. So we rpc_pipefs on both side.
> 
> Ok, both client and server can create instances.  And use them to do what?
> 
> I understand that the kernel needs to handle RPC calls to service NFS
> requests, what I'm not figuring out is how userspace is involved after
> the initial mount except on the other side of filesystem-agnostic system
> calls.

If you want to see the code on the userland side of the interfaces, see
utils/gssd and utils/idmapd in the nfs-utils code.

--b.
