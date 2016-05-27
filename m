Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:34082 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756512AbcE0RkV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 May 2016 13:40:21 -0400
Date: Fri, 27 May 2016 13:40:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: George Spelvin <linux@sciencehorizons.net>
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org, linux@horizon.com
Subject: Re: [PATCH RESEND 03/10] <linux/sunrpc/svcauth.h>: Define hash_str()
 in terms of hash_string()
Message-ID: <20160527174019.GE25272@fieldses.org>
References: <20160527121632.GC25272@fieldses.org>
 <20160527122022.23752.qmail@ns.sciencehorizons.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160527122022.23752.qmail@ns.sciencehorizons.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 27, 2016 at 08:20:22AM -0400, George Spelvin wrote:
> > I also needed the following.
> 
> I just found out five mintues ago that the push last night failed
> because I forgot the -f.  :-( *Now* it'll pull and work.
> 
> > But... the resulting kernel isn't booting succesfully for me.  Not sure
> > what's up there, I'll investigate some more.
> 
> Thank you *so much* for the help, but do get the latest.

I don't see yet what the problem is, but I can tell you that as of
95d5dfa805a6344e69ef41f56bb4955269079ec7 "fs/namei.c: Improve dcache
hash function" my (Fedora 21 x86_64) VM no longer starts up reliably....

--b.
