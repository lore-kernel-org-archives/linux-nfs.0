Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e2.ny.us.ibm.com ([32.97.182.142]:50394 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753202Ab2JHPaQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Oct 2012 11:30:16 -0400
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 8 Oct 2012 11:30:10 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q98FQrrb174506
	for <linux-nfs@vger.kernel.org>; Mon, 8 Oct 2012 11:26:53 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q98FQmXC021449
	for <linux-nfs@vger.kernel.org>; Mon, 8 Oct 2012 09:26:48 -0600
Date: Mon, 8 Oct 2012 10:26:47 -0500
From: Malahal Naineni <malahal@us.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NeilBrown <neilb@suse.de>, "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistency when mounting a directory that 'world' cannot
 access.
Message-ID: <20121008152647.GA15534@us.ibm.com>
References: <20121002143334.GA1435@fieldses.org>
 <20121003134629.72557522@notabene.brown>
 <20121003151349.GD14313@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA909001D77@SACEXCMBX04-PRD.hq.netapp.com>
 <20121003162728.GE14313@fieldses.org>
 <20121004084659.38632320@notabene.brown>
 <20121004160739.GA4693@fieldses.org>
 <20121008170304.37dc6ae9@notabene.brown>
 <20121008135452.GA14785@us.ibm.com>
 <20121008141839.GA27230@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121008141839.GA27230@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields [bfields@fieldses.org] wrote:
> On Mon, Oct 08, 2012 at 08:54:52AM -0500, Malahal Naineni wrote:
> > NeilBrown [neilb@suse.de] wrote:
> > > Mount with NFSv4 and it takes about the same.  However:
> > > 
> > > .....
> > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2974
> > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2975
> > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2976
> > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2977
> > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2978
> > > drwxr-xr-x 2 u2979      root 4096 Oct  8 16:19 2979
> > > drwxr-xr-x 2 u2980      root 4096 Oct  8 16:19 2980
> > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2981
> > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2982
> > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2983
> > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2984
> > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2985
> > > drwxr-xr-x 2 4294967294 root 4096 Oct  8 16:19 2986
> > > ....
> > > 
> > > 
> > > tcpdump shows the server is returning the write stuff, but something if going
> > > wrong on the client.  I've tried unmounting/remounting and killing/restarting
> > > rpc.idmapd.
> > 
> > As you know 4294967294 is (-2, nfs nobody), I have seen this issue with NFS
> > server sending numeric ids by default in AUTH_SYS (commit
> > e9541ce8efc22c233a045f091c2b969923709038), but the client can't handle
> > them (lack of commit 5cf36cfdc8caa2724738ad0842c5c3dd02f309dc in client
> > code).
> > 
> > I hand patched server commit, but my client was an older one. That is
> > how I got into my issue. Not sure, if you are running into a similar
> > issue.
> 
> Oh, could be--but then why would some of the id's still be mapped
> correctly?

Wild guess, those objects are created by client and didn't get their
attributes updated yet from server???

FYI, a co-worker here had RHEL6.3 server and RHEL6.2 client that
exhibited this nobody issue with NFSv4.

Regards, Malahal.

