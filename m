From: Benjamin Coddington <Benjamin.Coddington@uvm.edu>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe rpciod	deadlock?
Date: Mon, 14 Jan 2008 14:01:40 -0500
Message-ID: <478BB194.3090103@uvm.edu>
References: <18310.37731.29874.582772@notabene.brown> <1200004896.13775.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from eagle.uvm.edu ([132.198.101.203]:44651 "EHLO eagle.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753127AbYANT4m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 14:56:42 -0500
In-Reply-To: <1200004896.13775.27.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:

> I'm surprised that we can get into this state, though. How is
> sys_umount() able to exit with either readaheads or writebacks still
> pending? Is this perhaps occurring on a lazy umount?

Should we be submitting async tasks in gss_destroying_context?  I get 
this problem on umount with 3 or more cached GSS creds -- and end up 
blocked in rpciod_down - destroy_workqueue..

With short expiry, dcache (or something) holds a ref, and these creds 
stack up, then all queue tasks to clear context on shutdown.

Ben Coddington
