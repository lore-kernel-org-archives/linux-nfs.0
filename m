Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:58273 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753484AbbDOVGQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Apr 2015 17:06:16 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 6CD3820DCB
	for <linux-nfs@vger.kernel.org>; Wed, 15 Apr 2015 17:06:16 -0400 (EDT)
Date: Thu, 16 Apr 2015 00:06:14 +0300
From: Sergei Zviagintsev <sergei@s15v.net>
To: Paul Bolle <pebolle@tiscali.nl>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfs: Fix unused variable build warning when
 CONFIG_SUNRPC_DEBUG is not set
Message-ID: <20150415210614.GE8572@localhost.localdomain>
References: <1428962779-3741-1-git-send-email-sergei@s15v.net>
 <1429039169.27492.25.camel@x220>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1429039169.27492.25.camel@x220>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Paul,

On Tue, Apr 14, 2015 at 09:19:29PM +0200, Paul Bolle wrote:
> On Tue, 2015-04-14 at 01:06 +0300, Sergei Zviagintsev wrote:
> > Commit f52cbe4c9838 ("nfs: generic_write_checks() shouldn't be done on
> > swapout...") caused unused variable build warning in fs/nfs/file.c
> > when CONFIG_SUNRPC_DEBUG is not set as pos variable is used only in
> > dprintk() call. Fix it.
> 
> Would that warning be:
>     fs/nfs/file.c: In function ‘nfs_file_write’:
>     fs/nfs/file.c:677:9: warning: unused variable ‘pos’ [-Wunused-variable]
>       loff_t pos = iocb->ki_pos;
>              ^
> 
> Please add the warning you fix in the commit explanation. Doing that
> might save other people the trouble of doing the work you already did.
> Because then basically all they need to do is a web search or a "git log
> --grep" for (parts of) that messages. 

Thank you for advice, I missed that. However I see that this warning is
fixed already in Al Viro's vfs repo, so this patch is irrelevant.
