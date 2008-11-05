From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 05/12] lockd: encapsulate nlm_hosts table variables in
	one structure
Date: Wed, 5 Nov 2008 18:21:49 -0500
Message-ID: <20081105232149.GQ1455@fieldses.org>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net> <1225915611-2401-1-git-send-email-bfields@citi.umich.edu> <1225915611-2401-2-git-send-email-bfields@citi.umich.edu> <1225915611-2401-3-git-send-email-bfields@citi.umich.edu> <1225915611-2401-4-git-send-email-bfields@citi.umich.edu> <1225915611-2401-5-git-send-email-bfields@citi.umich.edu> <5C259444-2EA3-489E-9FC9-5983DDE74950@oracle.com> <20081105224109.GN1455@fieldses.org> <1225926710.16857.94.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60327 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752627AbYKEXV4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 18:21:56 -0500
In-Reply-To: <1225926710.16857.94.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 05, 2008 at 06:11:50PM -0500, Trond Myklebust wrote:
> On Wed, 2008-11-05 at 17:41 -0500, J. Bruce Fields wrote:
> > I always figured we should get rid of the garbage collection entirely.
> 
> That would lead to NSM_MON/UNMON storms on an insane scale if you have
> an application like a mail server that is constantly locking and
> unlocking files.

Whoops, right, I misspoke: what I'd like to get rid of someday is the
mark-and-sweep used to keep track of which hosts can't be
garbage-collected.  Ordinary reference counting would handle that in a
more straightforward way, I think.

--b.
