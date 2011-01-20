Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shutemov.name ([188.40.19.243]:43024 "EHLO shutemov.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755056Ab1ATLfx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Jan 2011 06:35:53 -0500
Date: Thu, 20 Jan 2011 13:35:52 +0200
From: "Kirill A. Shutemov" <kas@openvz.org>
To: Rob Landley <rlandley@parallels.com>
Cc: "Kirill A. Shutemov" <kas@openvz.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        containers@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 00/16] make rpc_pipefs be mountable multiple time
Message-ID: <20110120113552.GB24349@shutemov.name>
References: <1295012954-7769-1-git-send-email-kas@openvz.org>
 <4D343658.1020205@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D343658.1020205@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jan 17, 2011 at 06:30:16AM -0600, Rob Landley wrote:
> On 01/14/2011 07:48 AM, Kirill A. Shutemov wrote:
> > Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
> > Only for client for now.
> 
> Ok, Google is being really unhelpful here.

It's better if you read the code. :)
> 
> What is rpc_pipefs for?  What uses it, and to do what exactly?  Is it
> used by nfs server code, or by the client code, or both?  Is it a way
> for userspace to talk to the kernel, or for the kernel to talk to
> itself?  Is it used at mount time, or during filesystem operation?

Ok, It try to answer. Please correct me, if I'm wrong.

rpc_pipefs is a userland/kernel interface (I don't see kernel-kernel
usecases, but it's possible, I guess).
There is client dir (nfs/clntX) in rpc_pipefs for every sunrpc client.
Both client and server (see fs/nfsd/nfs4callback.c) can create sunrpc
client. So we rpc_pipefs on both side.
rpc_pipefs uses not only on mount time. See old idmapper, for example.

> I'm interested in giving this patch series a much more thorough review,
> but I can't figure out what the subsystem it's modifying actually _is_.
> 
> (Maybe this is something to do with filesystems/nfs/rpc-cache.txt?)
> 
> Rob

-- 
 Kirill A. Shutemov
