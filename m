Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:59902 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755623Ab1ATN6T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Jan 2011 08:58:19 -0500
Message-ID: <4D383F60.4080907@parallels.com>
Date: Thu, 20 Jan 2011 07:57:52 -0600
From: Rob Landley <rlandley@parallels.com>
To: "Kirill A. Shutemov" <kas@openvz.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Pavel Emelyanov <xemul@parallels.com>, <linux-nfs@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Al Viro <viro@ZenIV.linux.org.uk>,
        <containers@lists.linux-foundation.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v3 00/16] make rpc_pipefs be mountable multiple time
References: <1295012954-7769-1-git-send-email-kas@openvz.org> <4D343658.1020205@parallels.com> <20110120113552.GB24349@shutemov.name>
In-Reply-To: <20110120113552.GB24349@shutemov.name>
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/20/2011 05:35 AM, Kirill A. Shutemov wrote:
> On Mon, Jan 17, 2011 at 06:30:16AM -0600, Rob Landley wrote:
>> On 01/14/2011 07:48 AM, Kirill A. Shutemov wrote:
>>> Prepare nfs/sunrpc stack to use multiple instances of rpc_pipefs.
>>> Only for client for now.
>>
>> Ok, Google is being really unhelpful here.
> 
> It's better if you read the code. :)

I did.  That doesn't necessarily help if I don't know what it's _trying_
to do and this implementation is just one small piece of a much larger
mechanism.

>> What is rpc_pipefs for?  What uses it, and to do what exactly?  Is it
>> used by nfs server code, or by the client code, or both?  Is it a way
>> for userspace to talk to the kernel, or for the kernel to talk to
>> itself?  Is it used at mount time, or during filesystem operation?
> 
> Ok, It try to answer. Please correct me, if I'm wrong.
> 
> rpc_pipefs is a userland/kernel interface (I don't see kernel-kernel
> usecases, but it's possible, I guess).

Then why is the host context treated specially with an init_rcp_pipefs
instance that isn't necessarily mounted anywhere?  (How does userspace
access it if it isn't mounted anywhere?  Why doesn't the host context
just use the same does-not-exist code as container context?  Presumably
there's a reason for this?)

I've also mounted NFS shares in test environments I never mounted
rpc_pipefs in.  (It's possible that the nfs.mount command was doing so
for me, and apparently unmounting it again afterwards.)  My test
environment is exporting with the userspace NFS daemon so it's not using
the kernel cacheing infrastructure.

> There is client dir (nfs/clntX) in rpc_pipefs for every sunrpc client.
> Both client and server (see fs/nfsd/nfs4callback.c) can create sunrpc
> client. So we rpc_pipefs on both side.

Ok, both client and server can create instances.  And use them to do what?

I understand that the kernel needs to handle RPC calls to service NFS
requests, what I'm not figuring out is how userspace is involved after
the initial mount except on the other side of filesystem-agnostic system
calls.

> rpc_pipefs uses not only on mount time. See old idmapper, for example.

Um, does this sentence say that the old idmapper uses rpc_pipefs?
(Presumably not the kernel infrastructure controlled by
CONFIG_NFS_USE_NEW_IDMAPPER because you said it's not a kernel-kernel
communication mechanism...  So you're saying that whatever userspace
infrastructure interacts with that will also depend on rpc_pipefs.  But
the new infrastructure doesn't, which is why I need to look at the old?)

(And again, CONFIG_NFS_USE_NEW_IDMAPPER needs /sbin/request-key from the
keyutils package implying this is primarily for authentication, which
would explain why I haven't seen it in my simple test environment...)

Rob
