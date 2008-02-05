From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 4/5] NFSD: Remove NFSD_TCP kernel build option
Date: Tue, 5 Feb 2008 17:05:56 +1100
Message-ID: <18343.64708.19074.639419@notabene.brown>
References: <20080205000442.18602.29035.stgit@manray.1015granger.net>
	<47A7AB89.7020709@melbourne.sgi.com>
	<1202170754.28484.57.camel@heimdal.trondhjem.org>
	<47A7AE03.10401@melbourne.sgi.com>
	<4BE5A1AE-DB3B-4796-B6BD-5691930258C8@oracle.com>
	<47A7F8F3.3020907@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	bfields@citi.umich.edu, linux-nfs@vger.kernel.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:51198 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751747AbYBEGGA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2008 01:06:00 -0500
In-Reply-To: message from Greg Banks on Tuesday February 5
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday February 5, gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org wrote:
> >
> > What might make sense is to remove NFSD_TCP, but add NFSD_UDP,
> > defaulting to Y.
> >
> > Then in a year or two we can change the default to N.
> >
> Fine by me.

I, on the other hand, think we should leave support for UDP and TCP in
the kernel indefinitely and rely on the 'rpc.nfsd' tool to choose
what to listen to.


NeilBrown
