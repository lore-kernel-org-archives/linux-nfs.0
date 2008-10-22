From: Jim Rees <rees@umich.edu>
Subject: Re: [RFC] [PATCH 1/1] tcp-autotuning-on-recv-window-fix
Date: Wed, 22 Oct 2008 19:12:26 -0400
Message-ID: <20081022231226.GA17362@citi.umich.edu>
References: <48FE200A.6070805@citi.umich.edu> <20081022194605.GA4409@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.14.81]:56462 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508AbYJVXMa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Oct 2008 19:12:30 -0400
In-Reply-To: <20081022194605.GA4409@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:

  Could we get a really brief summary of the performance improvement for a
  high-speed network, to include in the commit message?

I don't have before and after numbers for this patch.  But an earlier
version boosted write performance from 432 to 15859 KBps on a transatlantic
link with 120ms rtt.  That's with 16 slot table entries.

  The one remaining worry I recall is that we assume the tcp autotuning
  never decreases the size of the buffer below the size we initially
  requested.  Apparently that assumption is true.  There's some worry
  about whether that's true by design or merely true of the current
  implementation.

That's true now but it's mostly an accident of the implementation.

  That doesn't look like a big worry--I'm inclined to apply this patch as
  is--but moving the sk_{rcv,snd}buf assignments to a simple function in
  the networking code and documenting the requirements there might be a
  nice thing to do (as a separate patch).

That's the right thing to do.  NFS shouldn't be reaching in to the sock
struct data fields.  I started to write such a patch but got bogged down.
Should it be a socket function, implemented by all the transports, or a tcp
only function?
