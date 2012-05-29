Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45785 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751037Ab2E2LVo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 May 2012 07:21:44 -0400
Date: Tue, 29 May 2012 07:21:41 -0400
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Dave Jones <davej@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: 3.4. sunrpc oops during shutdown
Message-ID: <20120529112140.GA1946@fieldses.org>
References: <20120521171411.GA15562@redhat.com>
 <1337623475.9583.13.camel@lade.trondhjem.org>
 <4FBF3EF2.4090804@parallels.com>
 <1337951250.2535.5.camel@lade.trondhjem.org>
 <4FBF89C0.2030805@parallels.com>
 <1338248617.3057.5.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1338248617.3057.5.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 28, 2012 at 11:43:40PM +0000, Myklebust, Trond wrote:
> On Fri, 2012-05-25 at 17:31 +0400, Stanislav Kinsbursky wrote:
> > Yes. But unfortunately, this won't be enough.
> > "NFS: callback threads containerization" patch set is required as well.
> > 
> > A a bugfix, I can suggest "SUNRPC: separate per-net data creation from service" 
> > patch set + pass hard-coded "init_net" for NFS callback shutdown routines 
> > (instead of current->nsproxy->net_ns). This should work.
> 
> Hi Stanislav,
> 
> My question is why should svc_destroy() care about net namespaces at
> all? Once an application is calling svc_destroy(), it is trying to close
> down the entire service. It really should not matter to which net
> namespace a particular socket belongs: they _all_ need to be destroyed.

Services started in different network namespaces should be
independent--for example, starting nfsd in container A and then again in
container B, then shutting it down in container A, shouldn't also shut
down container B's service.

*But* there is currently only a single global server object, because
we're sharing threads:

	http://marc.info/?l=linux-nfs&m=133405747330055&w=2

	"Having Lockd thread (or NFSd threads) per container looks easy
	to implement on first sight. But kernel threads currently
	supported only in initial pid namespace. I.e. it means that
	per-container kernel thread won't be visible in container, if it
	has it's own pid namespace. And there is no way to put a kernel
	thread into container.  In OpenVZ we have per-container kernel
	threads. But integrating this feature to mainline looks hopeless
	(or very difficult) to me. At least for now.  So this problem
	with signals remains unsolved.

	"So, as it looks to me, this "one service per all" is the only
	one suitable for now."

so Stanislav is simulating multiple servers by shutting down sockets on
a per-net basis.

But I think it should be possible to share threads between servers while
still behaving in every other way as if the servers are completely
independent.

--b.
