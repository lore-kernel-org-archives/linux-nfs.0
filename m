Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:33779 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752023AbaCJAUS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Mar 2014 20:20:18 -0400
Date: Mon, 10 Mar 2014 00:20:15 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: David Heidelberger <david.heidelberger@ixit.cz>, linux-nfs@vger.kernel.org
Subject: Re: DNOTIFY to INOTIFY migration
Message-ID: <20140310002015.GH18016@ZenIV.linux.org.uk>
References: <b59b1e4ede0b1d0a476c85465d480c8a@ixit.cz>
 <20140310102102.3c886726@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140310102102.3c886726@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 10, 2014 at 10:21:02AM +1100, NeilBrown wrote:
> On Fri, 07 Mar 2014 21:30:34 +0100 David Heidelberger
> <david.heidelberger@ixit.cz> wrote:
> 
> > Hello,
> > 
> > in linux kernel is DNOTIFY actually marked as deprecated, with superior 
> > replacement INOTIFY.
> 
> Where is it marked as deprecated?  I would be very surprised if dnotify
> wasn't supported indefinitely.

Unfortunately, it will be - once it's in, it's in.

> (I have no opinion on whether rpc.idmapd should be changed to use inotify,
> except based on the "if it ain't broke, don't fix it" principle).

I still don't understand WTF does rpc.imapd *want* either of those, TBH.

Said that, the original posting does read a bit like "herpes is so last century,
shouldn't we upgrade to clap by now?"...*0O(and I don't want to think what
that makes fanotify, thank you very much)
