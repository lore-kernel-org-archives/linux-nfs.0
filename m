From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] async vs. sync. corrupted fs
Date: Mon, 19 May 2008 10:54:11 -0400
Message-ID: <20080519145411.GC7622@fieldses.org>
References: <215ff4410805160355x25b8d055x9a0a246aa5875482@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chris Fanning <christopher.fanning@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:35500 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751569AbYESPB7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 May 2008 11:01:59 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1Jy6s8-00058z-Mm
	for linux-nfs@vger.kernel.org; Tue, 20 May 2008 01:01:56 +1000
In-Reply-To: <215ff4410805160355x25b8d055x9a0a246aa5875482-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 16, 2008 at 12:55:59PM +0200, Chris Fanning wrote:
> Hello all,
> 
> Could someone help me out?
> 
> I'm exporting a whole partition to a client.
> Using (rw,no_root_squash,sync, no_subtree_check), when I shutdown the
> server _before_ the client, the filesystem on the partion becomes
> corrupted.

How do you know it becomes corrupted?

> When I user async, it doesn't happen.

"async" the client-side mount option, or "async" the server-side export
option?

> Is this normal?

No.

> The exports manpage suggests that 'sync' is the better option.

Yes.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft 
Defy all challenges. Microsoft(R) Visual Studio 2008. 
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

