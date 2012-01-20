Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47769 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752964Ab2ATO3R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Jan 2012 09:29:17 -0500
Date: Fri, 20 Jan 2012 09:29:13 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH v2 0/5] SUNRPC: make caches network namespace aware
Message-ID: <20120120142913.GA9877@fieldses.org>
References: <20120119173823.23767.91876.stgit@localhost6.localdomain6>
 <4F194B7F.4030002@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F194B7F.4030002@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 20, 2012 at 03:09:51PM +0400, Stanislav Kinsbursky wrote:
> I've tested NFSd under load - works like a charm (showmount reported right info).
> I've tested NFS mounts on host node - looks like all works fine.
> Also I've tested NFS mounts on host node and in container in the
> same time. There are some problems here. Most likely caused by
> user-space daemons, conflicting between themselves because of wrong
> initialization environment (like rpcbind registering problems, which
> I've raised in the list already).
> So looks like the patches suitable for devel branch.

OK, thanks:

	Acked-by: J. Bruce Fields <bfields@redhat.com>

We should start testing the containerized nfsd side too, though--run
nfsd on a machine with multiple network namespaces, separate mountd's
and rpc.svcgssd's in each, figure out how to feed of them different
configurations, and check that requests to the different interfaces are
treated differently.

--b.
