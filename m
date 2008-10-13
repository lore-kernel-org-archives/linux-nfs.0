From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] client-side lockd doesn't start UDP listener
Date: Mon, 13 Oct 2008 16:57:12 -0400
Message-ID: <20081013205712.GF31876@fieldses.org>
References: <20081003211305.9870.6835.stgit@ingres.1015granger.net> <20081004213625.GA3709@fieldses.org> <18674.34066.316972.695627@notabene.brown> <CCAC2CA2-FEAE-4383-9F7D-F63BBF0E701E@oracle.com> <20081013174613.GH28864@fieldses.org> <668D398B-7814-4831-ABC2-8F8CF1FBE4D0@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:43669 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755031AbYJMU5T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Oct 2008 16:57:19 -0400
In-Reply-To: <668D398B-7814-4831-ABC2-8F8CF1FBE4D0@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 13, 2008 at 04:45:47PM -0400, Chuck Lever wrote:
> NFSD start-up code makes two separate and unconditional calls to  
> lockd_up(): one for UDP and one for TCP.  So whether or not NFSD  
> actually honors the "-T" and "-U" flags, lockd certainly does not honor 
> them in current (unpatched) code.
>
> In other words, the patches you've already reviewed shouldn't change the 
> server's behavior around -T/-U.  Only the client side should be  
> affected.
>
> It looks like, prior to commit 24e36663, the client side started both  
> lockd listeners no matter what type of mount was requested.
>
> Additional review is welcome, but let's just move forward with what  
> you've already got.

OK, sounds fine to me.

The rpc.nfsd man page could still use revision, though.

--b.
