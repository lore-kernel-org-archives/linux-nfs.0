From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/3] nfsd: don't try to shut down nfs4 state handling
 unless it's up
Date: Sat, 26 Jun 2010 21:08:37 -0400
Message-ID: <20100626210837.1da68d6b@corrin.poochiereds.net>
References: <1275924800-5214-1-git-send-email-jlayton@redhat.com>
	<1275924800-5214-2-git-send-email-jlayton@redhat.com>
	<20100626155351.GA16951@pig.fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43362 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753334Ab0F0BGe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Jun 2010 21:06:34 -0400
In-Reply-To: <20100626155351.GA16951-+qGSg9AQ1cLTsXDwO4sDpg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 26 Jun 2010 11:53:51 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jun 07, 2010 at 11:33:18AM -0400, Jeff Layton wrote:
> > If someone tries to shut down the laundry_wq while it isn't up it'll
> > cause an oops.
> 
> Sorry for getting behind....
> 

No huge hurry. This series is pretty much 2.6.36 material unless you
see a reason to push them sooner.

> I'm not seeing how this can happen: nfs4_state_shutdown() is called from
> nfsd_last_thread(), which can't be called until after nfsd_create_serv()
> is called.  But nfsd_create_serv() is called after nfs4_state_start().
> 
> Oh, I see, I'm overlooking __write_ports_add{fd,xprt}(), which can call
> nfsd_create_serv() without first calling nfs4_state_start().  Argh.
> 

Yep...and rpc.nfsd does write fd's to the kernel before bringing up
threads, so this situation is actually the norm. The later patches in
this series also mandate this to prevent oopses when there are errors
bringing up the service.

-- 
Jeff Layton <jlayton@redhat.com>
