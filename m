Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59044 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453Ab0HCXPl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 19:15:41 -0400
Date: Tue, 3 Aug 2010 19:14:19 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michael Guntsche <mike@it-loops.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberos auth Problem with nfs3/4
Message-ID: <20100803231419.GC9752@fieldses.org>
References: <20100803154556.GA6262@gibson.comsick.at>
 <20100803194342.GE31579@fieldses.org>
 <20100803211906.GA24236@gibson.comsick.at>
 <20100803213650.GJ31579@fieldses.org>
 <20100803222002.GA1741@marvin.comsick.at>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100803222002.GA1741@marvin.comsick.at>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 04, 2010 at 12:20:02AM +0200, Michael Guntsche wrote:
> gibson being the server and zaphod being the client here. As you said
> the server tries to connect back to the client which fails since
> rpc.svcgssd is not running on the client. Should the server try to
> connect back to the client this way in the first place and if yes
> shouldn't he stop trying after seeing that it is not working?

What I'd expect would be for it to make one try with each new client and
then give up.  (But actually if the client doesn't renew state while
files aren't open--it may also end up retrying if the client's idle for
a minute or so.)  If it's retrying more often than that, that's a
problem.

In any case we should probably reconsider how that message is generated,
to prevent it going to the log by default in this case.

--b.
