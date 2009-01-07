From: Matt Helsley <matthltc@us.ibm.com>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 16:43:19 -0800
Message-ID: <1231288999.14345.231.camel@localhost>
References: <20090106011314.534653345@us.ibm.com>
	 <20090106011314.961946803@us.ibm.com> <20090106200229.GA17031@us.ibm.com>
	 <1231274682.20316.65.camel@heimdal.trondhjem.org>
	 <20090106215831.GE18147@us.ibm.com>
	 <1231281732.4173.6.camel@heimdal.trondhjem.org>
	 <1231286930.14345.196.camel@localhost>
	 <1231287619.11487.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Serge E. Hallyn" <serue@us.ibm.com>,
	Linux Containers <containers@lists.linux-foundation.org>,
	linux-nfs@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
	Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:55435 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755294AbZAGAnX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2009 19:43:23 -0500
In-Reply-To: <1231287619.11487.2.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-06 at 19:20 -0500, Trond Myklebust wrote:
> On Tue, 2009-01-06 at 16:08 -0800, Matt Helsley wrote:
> > IMHO This seems more incorrect than trying to use a more proximal
> > namespace.
> 
> You have yet to explain why.

It's "more proximal" -- it's closer to the container that we expect to
cause (directly or otherwise) the bulk of the RPC calls for that mount.
If the container does not wind up sharing that mount with other
containers then the reported node name matches. If the container winds
up sharing the mount with other containers then at least we can learn
which container originated the mount.

I imagine an NFS administrator trying to determine the source of a bunch
of RPC calls. If we just report the initial namespace then that
administrator has to do lots more digging to determine which container
sent the calls (assuming they aren't in different network namespaces).
By not always reporting the initial namespace we may give the
administrator one way to narrow down the search. Even if the reported
node name does not perfectly match the source of all RPC traffic related
to the mount at least the administrator gets something more specific.

Cheers,
	-Matt Helsley

