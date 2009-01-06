From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC][PATCH 2/4] sunrpc: Use utsnamespaces
Date: Tue, 06 Jan 2009 18:43:37 -0500
Message-ID: <1231285417.8041.15.camel@heimdal.trondhjem.org>
References: <20090106011314.534653345@us.ibm.com>
	 <20090106011314.961946803@us.ibm.com>  <20090106200229.GA17031@us.ibm.com>
	 <1231274682.20316.65.camel@heimdal.trondhjem.org>
	 <1231283935.14345.142.camel@localhost>
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
To: Matt Helsley <matthltc@us.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:51760 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191AbZAFXnp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 18:43:45 -0500
In-Reply-To: <1231283935.14345.142.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-01-06 at 15:18 -0800, Matt Helsley wrote:
> Yes, I was aware that the inode might be dirtied by another container. I
> was thinking that, at least in the case of NFS, it makes sense to report
> the node name of the container that did the original mount. Of course
> this doesn't address the general RPC client case and, like patch 3, it
> makes the superblock solution rather NFS-specific. That brings me to a
> basic question: Are there any RPC clients in the kernel that do not
> operate on behalf of NFS?

Yes. There is, for instance, the portmapper/rpcbind client. The NFS and
lockd servers also sometime needs to send RPC callbacks. Assuming that
you can convert the RPC client into something NFS-specific is therefore
not an option.

Trond

