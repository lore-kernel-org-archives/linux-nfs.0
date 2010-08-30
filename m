Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56741 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754430Ab0H3RsM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Aug 2010 13:48:12 -0400
Date: Mon, 30 Aug 2010 13:48:01 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org, chuck.lever@oracle.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100830134801.1696dffa@tlielax.poochiereds.net>
In-Reply-To: <4C7BE1FC.2020400@RedHat.com>
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
	<4C7BD394.3030705@RedHat.com>
	<20100830121600.529669bd@tlielax.poochiereds.net>
	<4C7BE1FC.2020400@RedHat.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 30 Aug 2010 12:53:16 -0400
Steve Dickson <SteveD@redhat.com> wrote:
> > 
> > Hmmm...if I had known that it was ok to stop supporting old kernels,
> > the IPv6 support for rpc.nfsd would have been a heck of a lot easier to
> > implement.
> I thought you said the legacy interface would not work with IPV6 or
> did I misunderstand you? 
> 

Sorry, forgot to answer this part. IPv6 indeed will not work when using
the legacy interface. In order to get the IPv6 code in though, I ended
up rewriting a large swath of rpc.nfsd. That task would have been
easier had I not needed to deal with the legacy nfsctl() interface.

-- 
Jeff Layton <jlayton@redhat.com>
