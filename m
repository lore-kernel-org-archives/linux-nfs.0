Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:53451 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965074Ab2EQNmc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 May 2012 09:42:32 -0400
Message-ID: <4FB50030.1010501@panasas.com>
Date: Thu, 17 May 2012 16:42:08 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Jim Rees <rees@umich.edu>
CC: Mike Frysinger <vapier@gentoo.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] osd_login: fix DESTDIR install
References: <1337232243-18088-1-git-send-email-vapier@gentoo.org> <4FB4ECDA.2080506@panasas.com> <20120517130925.GA10380@umich.edu>
In-Reply-To: <20120517130925.GA10380@umich.edu>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 05/17/2012 04:09 PM, Jim Rees wrote:

> Boaz Harrosh wrote:
> 
>   On second thought, You know, I'm not sure about this fix.
>   
>   A lot of times we install to a side folder, so we can later
>   tar and package the sub-folder without actually affecting
>   our live system. What will happen with the packagers that
>   are not RPM don't they rely on this?
>   
>   I would like to let the user to install nfs-utils on the
>   side and to not conflict with the running system. Someone
>   how knows what he is doing can override the Kernel path
>   to what he wants. Just as he will need to override the
>   nfs init scripts.
>   
>   So I would prefer if we can just create the $(DESTDIR)/sbin/
> 
> I think the makefiles already create $(DESTDIR)$(sbindir).  The problem was
> that you weren't using $(DESTDIR)$(sbindir), you were using
> $(DESTDIR)/sbin.  The patch sets $(sbindir) to /sbin, so everything should
> just work.
> 
> But I could be wrong, automake is a black box to me.


Make sense thanks. Just wanted to make sure.
Boaz
