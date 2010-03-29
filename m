From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [2.6.34-rc2 NFS4 oops] open error path failure...
Date: Mon, 29 Mar 2010 20:03:07 +0100
Message-ID: <20100329190307.GJ30031@ZenIV.linux.org.uk>
References: <6278d2221003291136p6481fe8emfb039403343c082@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Daniel J Blueman <daniel.blueman@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:51251 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217Ab0C2TDJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Mar 2010 15:03:09 -0400
In-Reply-To: <6278d2221003291136p6481fe8emfb039403343c082-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 29, 2010 at 07:36:45PM +0100, Daniel J Blueman wrote:
> Hi Trond,
> 
> When open fails and should return EPERM [1], instead we see an oops
> [2]. I see this on 2.6.34-rc1 and -rc2 mainline; NFS4 server is
> mainline 2.6.33.1.
> 
> Let me know if you can't reproduce it and I'll provide some analysis
> from this end.

Joy...  ERR_PTR(-EPERM) in nd.intent.file, and whoever had called
lookup_instantiate_filp() hadn't bothered to check the return value.

OK, I think I see what's going on.  Replace
                                lookup_instantiate_filp(nd, (struct dentry *)state, NULL);
                                return 1;
with
                                lookup_instantiate_filp(nd, (struct dentry *)state, NULL);
                                return state;
in fs/nfs/nfs4proc.c:nfs4_open_revalidate() and see if everything works
properly (or just lose the lookup_instantiate_filp() in there and simply
return state).

