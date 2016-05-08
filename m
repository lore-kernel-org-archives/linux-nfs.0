Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:47880 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbcEHXZh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 May 2016 19:25:37 -0400
Date: Mon, 9 May 2016 00:25:33 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <nfbrown@novell.com>
Cc: Richard Weinberger <richard@nod.at>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>,
        Artem Bityutskiy <dedekind1@gmail.com>,
        Christoph Hellwig <hch@infradead.org>,
        NFS List <linux-nfs@vger.kernel.org>
Subject: Re: Reconsidering exportable UBIFS
Message-ID: <20160508232533.GH2694@ZenIV.linux.org.uk>
References: <5702E7F5.1050807@nod.at>
 <871t5curbl.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <871t5curbl.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 09, 2016 at 08:18:22AM +1000, NeilBrown wrote:

> Not puppies, just kittens.
> 
> If you don't provide these functions, then exporting with
> "subtree_check" won't work.  That is no great loss except that people
> might find the failure confusing.

	OK, a client sends you a RENAME.  With fhandles of both parents +
old and new names in those.  Your task, should you choose to accept it, is
to figure out whether we should fail with nfserr_inval due to an attempt
to make a directory its own descendent.  Without being able to locate all
ancestors of a directory.

	You are fond of complaining about the checks that could've been left
to server not getting skipped on the client.  Now you want to skip them on
the server side as well?  Can't have it both ways...

	Seriously, it really doesn't work.  You can't do directory
modifications without having found the chain of ancestors.  No ->get_parent()
is OK _only_ for something like tmpfs, where we have the full chains of
ancestors towards root all the time.  For UBIFS it's obviously not true.
Not unless you suck the entire directory tree in memory at the mount time.
