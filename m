From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/3] client-side lockd doesn't start UDP listener
Date: Tue, 14 Oct 2008 20:54:37 +1100
Message-ID: <18676.27741.921124.742371@notabene.brown>
References: <20081003211305.9870.6835.stgit@ingres.1015granger.net>
	<20081004213625.GA3709@fieldses.org>
	<18674.34066.316972.695627@notabene.brown>
	<CCAC2CA2-FEAE-4383-9F7D-F63BBF0E701E@oracle.com>
	<20081013174613.GH28864@fieldses.org>
	<668D398B-7814-4831-ABC2-8F8CF1FBE4D0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:57377 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755078AbYJNJy3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Oct 2008 05:54:29 -0400
In-Reply-To: message from Chuck Lever on Monday October 13
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday October 13, chuck.lever@oracle.com wrote:
> 
> NFSD start-up code makes two separate and unconditional calls to  
> lockd_up(): one for UDP and one for TCP.  So whether or not NFSD  
> actually honors the "-T" and "-U" flags, lockd certainly does not  
> honor them in current (unpatched) code.

Not exactly correct.  The calls are not unconditional.
I assume we are looking at nfsd_init_socks in nfssvc.c
Note the condition at the top:
	if (!list_empty(&nfsd_serv->sv_permsocks))
		return 0;

If a UDP port has previously been created by a write to "portlist",
then when the first thread is stared, no new sockets will be created,
and nfsd (and lockd) will just listen on UDP.

So your patches do make a real functional change which is more than
just "always listen on UDP".

I agree that the man page should reflect reality.

NeilBrown
