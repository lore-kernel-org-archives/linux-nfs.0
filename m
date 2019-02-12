Return-Path: <SRS0=XA/Y=QT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D106C282C4
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 14:42:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1CF362186A
	for <linux-nfs@archiver.kernel.org>; Tue, 12 Feb 2019 14:42:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1549982539;
	bh=5Tw9tPCLPw2NPfnuDYu0RsXK16jklWrmqp69Lplcca0=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=t5dMwiXFaxZD537l4RNBC99xfP8Y3wNA10qkesxeAjsF+GCjkbT1U2yilwo2bTsew
	 d+RUvCwJROW82KZLuDb61VwZaeCNrl9KpzKVdR1gV6AnWR08MpfHJ2NDqUZQ0I2Ja2
	 gVFOpn1xq4UEqp+fI7SWShK4p0044YJ21BtBtBD8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729577AbfBLOmS (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 12 Feb 2019 09:42:18 -0500
Received: from mail.kernel.org ([198.145.29.99]:42464 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727428AbfBLOmS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Feb 2019 09:42:18 -0500
Received: from localhost (5356596B.cm-6-7b.dynamic.ziggo.nl [83.86.89.107])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 5554B2083B;
        Tue, 12 Feb 2019 14:42:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1549982536;
        bh=5Tw9tPCLPw2NPfnuDYu0RsXK16jklWrmqp69Lplcca0=;
        h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
        b=tL+TV4+8XJzhKDhf57C6FSD5nGTkuUNTPxkFgdeBz+7yCVWOqDh4BxONZRBkCP0Gz
         GXqAEMuQa8ryBuBkP6he7WCA1IMmsbTYF1Z7VcDUVdPc8sHiRRufyZNawJvQrVRhXp
         8QxyjcpLjnGAfVU5Wq7d+N8PYZibv7m+pbUV7w4Y=
Date:   Tue, 12 Feb 2019 15:42:14 +0100
From:   Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To:     David Howells <dhowells@redhat.com>
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        mhiramat@kernel.org, bigeasy@linutronix.de
Subject: Re: Oops in rpc_clnt_debugfs_register() from debugfs change
Message-ID: <20190212144214.GA17111@kroah.com>
References: <19914.1549970944@warthog.procyon.org.uk>
 <14223.1549981874@warthog.procyon.org.uk>
 <20190212143720.GA16380@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212143720.GA16380@kroah.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Feb 12, 2019 at 03:37:20PM +0100, Greg Kroah-Hartman wrote:
> On Tue, Feb 12, 2019 at 02:31:14PM +0000, David Howells wrote:
> > I've bisected an oops that occurs in rpc_clnt_debugfs_register() trying to
> > dereference a pointer with -EACCES in it.  This is the causing commit, though
> > I suspect the bug is in sunrpc expecting to see NULL rather than an error.
> > 
> > ff9fb72bc07705c00795ca48631f7fffe24d2c6b is the first bad commit
> > commit ff9fb72bc07705c00795ca48631f7fffe24d2c6b
> > Author: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Date:   Wed Jan 23 11:28:14 2019 +0100
> > 
> >     debugfs: return error values, not NULL
> >     
> >     When an error happens, debugfs should return an error pointer value, not
> >     NULL.  This will prevent the totally theoretical error where a debugfs
> >     call fails due to lack of memory, returning NULL, and that dentry value
> >     is then passed to another debugfs call, which would end up succeeding,
> >     creating a file at the root of the debugfs tree, but would then be
> >     impossible to remove (because you can not remove the directory NULL).
> >     
> >     So, to make everyone happy, always return errors, this makes the users
> >     of debugfs much simpler (they do not have to ever check the return
> >     value), and everyone can rest easy.
> >     ...
> > 
> > The attached oops occurs during boot from the gssproxy process in
> > rpc_clnt_debugfs_register().  The code at this point is:
> > 
> >    0xffffffff8195cbdd <+450>:   mov    0x50(%rax),%rcx   <--- oopsing
> >    0xffffffff8195cbe1 <+454>:   mov    $0xffffffff821cc8ba,%rdx
> >    0xffffffff8195cbe8 <+461>:   mov    $0x18,%esi
> >    0xffffffff8195cbed <+466>:   lea    -0x30(%rbp),%rdi
> >    0xffffffff8195cbf1 <+470>:   callq  0xffffffff819db773 <snprintf>
> > 
> > RAX is -EACCES.
> > 
> > Looking in the source:
> > 
> > 	len = snprintf(name, sizeof(name), "../../rpc_xprt/%s",
> > 			xprt->debugfs->d_name.name);
> > 
> > I think xprt->debugfs is the value in RAX.
> > 
> > 	(gdb) p &((struct dentry *)0)->d_name.name
> > 	$5 = (const unsigned char **) 0x50 <irq_stack_union+80>
> > 
> > which matches the offset on the oopsing MOV instruction.
> > 
> > This is with linus/master (aa0c38cf39de73bf7360a3da8f1707601261e518).
> 
> Ugh, yeah, I see the problem, sorry about that.
> 
> I wonder why the debugfs call is always failing, that's not good...
> 
> let me dig and see if I already have a patch for this...

I have a much larger cleanup patch for this code, but this single line
change should solve the issue for now.  Can you test it to verify?

thanks,

greg k-h

------------------

diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index 45a033329cd4..19bb356230ed 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -146,7 +146,7 @@ rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 	rcu_read_lock();
 	xprt = rcu_dereference(clnt->cl_xprt);
 	/* no "debugfs" dentry? Don't bother with the symlink. */
-	if (!xprt->debugfs) {
+	if (IS_ERR_OR_NULL(xprt->debugfs)) {
 		rcu_read_unlock();
 		return;
 	}
