From: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Subject: Re: Massive NFS problems on large cluster with large number of	mounts
Date: Wed, 16 Jul 2008 11:49:51 +0200
Message-ID: <487DC43F.8040408@aei.mpg.de>
References: <4869E8AB.4060905@aei.mpg.de>	 <20080701182250.GB21807@fieldses.org> <486B89F5.9000109@aei.mpg.de>	 <20080702203130.GA24850@fieldses.org> <1215032676.7087.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from welcomes-you.com ([85.214.50.128]:50198 "EHLO
	smtp.welcomes-you.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755907AbYGPJtz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Jul 2008 05:49:55 -0400
In-Reply-To: <1215032676.7087.30.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond et al.

I'm following up on this discussion because we hit another problem:

Trond Myklebust wrote:

> 
> Alternatively, just change the values of /proc/sys/sunrpc/min_resvport
> and /proc/sys/sunrpc/max_resvport to whatever range of ports you
> actually want to use.

This works like a charm, however, if you set these values before
restarting the nfs-kernel-server then you are in deep trouble, since
when nfsd wants to start it needs to register with the portmapper, right?

But what happens if this requests comes from a high^Wunpriviliged port?
Right:
Jul 16 11:46:43 d23 portmap[8216]: connect from 127.0.0.1 to set(nfs):
request from unprivileged port
Jul 16 11:46:43 d23 nfsd[8214]: nfssvc: writting fds to kernel failed:
errno 13 (Permission denied)
Jul 16 11:46:44 d23 kernel: [ 8437.726223] NFSD: Using
/var/lib/nfs/v4recovery as the NFSv4 state recovery directory
Jul 16 11:46:44 d23 kernel: [ 8437.800607] NFSD: starting 90-second
grace period
Jul 16 11:46:44 d23 kernel: [ 8437.842891] nfsd: last server has exited
Jul 16 11:46:44 d23 kernel: [ 8437.879940] nfsd: unexporting all filesystems
Jul 16 11:46:44 d23 nfsd[8214]: nfssvc: Address already in use


Changing /proc/sys/sunrpc/max_resvport to 1023 again resolves this
issue, however defeats the purpose for the initial problem. I still need
to look into the code for hte portmapper, but is it easily possible that
the portmapper would accept nfsd requests from "insecure" ports also?
Since e are (mostly) in a controlled environment that should not pose a
problem.

Anyone with an idea?

Thanks a lot

Carsten
