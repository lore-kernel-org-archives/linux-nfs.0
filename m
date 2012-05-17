Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:51402 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758047Ab2EQNJc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 09:09:32 -0400
Date: Thu, 17 May 2012 09:09:25 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Mike Frysinger <vapier@gentoo.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] osd_login: fix DESTDIR install
Message-ID: <20120517130925.GA10380@umich.edu>
References: <1337232243-18088-1-git-send-email-vapier@gentoo.org>
 <4FB4ECDA.2080506@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FB4ECDA.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:

  On second thought, You know, I'm not sure about this fix.
  
  A lot of times we install to a side folder, so we can later
  tar and package the sub-folder without actually affecting
  our live system. What will happen with the packagers that
  are not RPM don't they rely on this?
  
  I would like to let the user to install nfs-utils on the
  side and to not conflict with the running system. Someone
  how knows what he is doing can override the Kernel path
  to what he wants. Just as he will need to override the
  nfs init scripts.
  
  So I would prefer if we can just create the $(DESTDIR)/sbin/

I think the makefiles already create $(DESTDIR)$(sbindir).  The problem was
that you weren't using $(DESTDIR)$(sbindir), you were using
$(DESTDIR)/sbin.  The patch sets $(sbindir) to /sbin, so everything should
just work.

But I could be wrong, automake is a black box to me.
