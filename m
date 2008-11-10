From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 5/9] rpc: call release_pipe only on last close
Date: Mon, 10 Nov 2008 15:37:08 -0500
Message-ID: <20081110203708.GH19053@fieldses.org>
References: <1226264683-28650-5-git-send-email-bfields@citi.umich.edu> <1226264683-28650-6-git-send-email-bfields@citi.umich.edu> <1226344297.7599.41.camel@heimdal.trondhjem.org> <20081110194900.GD19053@fieldses.org> <1226347279.7599.47.camel@heimdal.trondhjem.org> <20081110200727.GE19053@fieldses.org> <1226347898.7599.49.camel@heimdal.trondhjem.org> <20081110201708.GF19053@fieldses.org> <1226348515.7599.52.camel@heimdal.trondhjem.org> <20081110202640.GG19053@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38160 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754169AbYKJUhK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2008 15:37:10 -0500
In-Reply-To: <20081110202640.GG19053@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 10, 2008 at 03:26:40PM -0500, bfields wrote:
> Yep.  And when we're in that situation, last_close is true, so
> 
> 	if (last_close && ops->release_pipe)
> 		ops->release_pipe(inode)
> 
> does ensure that calls to the ->open_pipe() and ->release_pipe() methods
> balance, as originally claimed.

(Trivial to verify, by the way: search the code for every assignment to
nreaders or nwriters, and verify that:

	nreaders+nwriters is always initialized to zero.
	each time nreaders+nwriters transitions from 0 to positive, we
		call ->pipe_open().
	each time nreaders+nwriters transitions from positive to 0, we
		call ->pipe_release().
	nreaders+nwriters always transitions back to 0 before the
		containing inode is freed.

And all of this happens under the i_mutex.)

--b.
