Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41028 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756609Ab3EOOPJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 10:15:09 -0400
Date: Wed, 15 May 2013 10:15:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: James Vanns <james.vanns@framestore.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Where in the server code is fsinfo rtpref calculated?
Message-ID: <20130515141508.GH16811@fieldses.org>
References: <20130514220122.GE16811@fieldses.org>
 <1045951723.19965005.1368625362930.JavaMail.root@framestore.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1045951723.19965005.1368625362930.JavaMail.root@framestore.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 15, 2013 at 02:42:42PM +0100, James Vanns wrote:
> > fs/nfsd/nfssvc.c:nfsd_get_default_maxblksize() is probably a good
> > starting point.  Its caller, nfsd_create_serv(), calls
> > svc_create_pooled() with the result that's calculated.
> 
> Hmm. If I've read this section of code correctly, it seems to me
> that on most modern NFS servers (using TCP as the transport) the default
> and preferred blocksize negotiated with clients will almost always be
> 1MB - the maximum RPC payload. The nfsd_get_default_maxblksize() function
> seems obsolete for modern 64-bit servers with at least 4G of RAM as it'll
> always prefer this upper bound instead of any value calculated according to
> available RAM.

Well, "obsolete" is an odd way to put it--the code is still expected to
work on smaller machines.

Arguments welcome about the defaults, though I wonder whether it would
be better to be doing this sort of calculation in user space.

> For what it's worth (not sure if I specified this) I'm running kernel 2.6.32.
> 
> Anyway, this file/function appears to set the default *max* blocksize. I haven't 
> read all the related code yet, but does the preferred block size derive 
> from this maximum too?

See:

> > For fsinfo see fs/nfsd/nfs3proc.c:nfsd3_proc_fsinfo, which uses
> > svc_max_payload().

I'm not sure what the history is behind that logic, though.

--b.
