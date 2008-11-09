From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: text-based gss upcall
Date: Sun,  9 Nov 2008 16:04:34 -0500
Message-ID: <1226264683-28650-1-git-send-email-bfields@citi.umich.edu>
References: <20081109204621.GD27376@fieldses.org>
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34912 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756057AbYKIVEr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Nov 2008 16:04:47 -0500
In-Reply-To: <20081109204621.GD27376@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


So, this time there aren't any changes to the underlying
gss_auth/rpc_pipe locking, and the gss code doesn't attempt to cancel
rpc calls on its own.  Instead we:

	- keep a single global variable which determines which version (new
	  or old) of the upcall we use;
	- keep a counter which tells us
	  	count of gss pipes open + count of gss upcalls outstanding;
	- permit switching versions only when that counter goes to zero;
	- use pipe_open and pipe_release callbacks to maintain that
	  counter; and
	- allow the gss code to wait on gssd to open a pipe before
	  deciding which version of upcall to make.

And the new locking change is one spinlock to protect the global pipe
version.

I've tested with an unmodified gssd, and checked that things still work
correctly when gssd is killed and restarted.  I haven't tested with a
gssd that uses the new upcall yet.

Most of these patches are just trivial preparatory cleanup, and the
first two (maybe three) patches might be worth applying independently.

--b.
