From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 12/16] nfs-utils: make makesock() static
Date: Fri, 5 Sep 2008 11:14:29 +1000
Message-ID: <18624.34805.396033.544222@notabene.brown>
References: <20080904165122.1471.24485.stgit@manray.1015granger.net>
	<20080904165658.1471.56972.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:59223 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750955AbYIEBOt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Sep 2008 21:14:49 -0400
In-Reply-To: message from Chuck Lever on Thursday September 4
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday September 4, chuck.lever@oracle.com wrote:
> 
>  o  Return RPC_ANYSOCK on error (this is -1) instead of open-coding -1.

I don't agree with this change.
Everything else (including the last) looks fine, though I personally
wouldn't bother closing file descriptors and freeing memory just
before exit.

RPC_ANYSOCK is an input value to various rpc library functions which
means "I haven't opened a socket, you do it for me".  It is not really
a valid return value.

Every time makesock is called, the return status is tested with 
     if (makesock(...) < 0)

To me, that says that the returned value should be e.g. -1, not
RPC_ANYSOCK.

Thanks,
NeilBrown

