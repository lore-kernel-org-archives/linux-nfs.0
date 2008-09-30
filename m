From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: lockd using up 60% CPU and won't let go
Date: Tue, 30 Sep 2008 14:26:42 -0400
Message-ID: <20080930182642.GB12268@fieldses.org>
References: <48E17042.101@corky.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Just Marc <marc-ZTWYIuj8JqNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:34142 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751838AbYI3S0o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Sep 2008 14:26:44 -0400
In-Reply-To: <48E17042.101-ZTWYIuj8JqNeoWH0uzbU5w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 29, 2008 at 08:18:10PM -0400, Just Marc wrote:
> Hi,
>
> > It's basically just a userspace NFS server, right?
>
> Correct.
>
> > Could you work around the problem by mounting with -onolock?
>
> That doesn't seem to help.
>
> >You might try running wireshark on the "lo" interface and seeing  
> whether there's any NLM traffic from lockd.
>
> You guessed right.   There's a 12 megabytes per second of NLM traffic on lo.
>
> unlock call requests and unlock replies saying permission denied, looks  
> like it just repeats forever in a tight loop.

Permission denied on an unlock sounds pretty weird--probably a bug on
the server (CFS) side.  The client might be able to handle it
gracefully, but that's probably not a high priority.

So -onlock is the way to go; see Trond's suggestions.  Locking will
still work, CFS just won't be told about it.  That would only be a
problem if you had multiple NFS clients doing locking on the same CFS
filesystem, but you're only loopback-mounting, so only one client is
involved.

--b.
