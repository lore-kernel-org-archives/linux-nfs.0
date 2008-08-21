From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/8] SUNRPC: Set V6ONLY socket option for RPC listener
	sockets
Date: Thu, 21 Aug 2008 17:26:32 -0400
Message-ID: <20080821212632.GH29466@fieldses.org>
References: <20080813223953.13068.97829.stgit@manray.1015granger.net> <20080814200554.GI23859@fieldses.org> <74E488BD-DB15-41CD-AD30-A8A5213BC140@oracle.com> <20080814203833.GK23859@fieldses.org> <A8AF0C9D-B606-4EA4-9EE0-5367C515BE84@oracle.com> <20080820193126.GB21226@fieldses.org> <48AD5B85.4020807@bull.net> <20080821144117.GB22587@fieldses.org> <48AD8A72.2040200@bull.net> <76bd70e30808210920y3db1b07cyccbe40e1b4582c12@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aime.le-rouzic@bull.net, trond.myklebust@netapp.com,
	trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org,
	Frank S Filz <ffilz@us.ibm.com>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38601 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754917AbYHUV0x (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Aug 2008 17:26:53 -0400
In-Reply-To: <76bd70e30808210920y3db1b07cyccbe40e1b4582c12-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 21, 2008 at 12:20:53PM -0400, Chuck Lever wrote:
> My complete IPv6 patch set is available here:
> 
>   http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=summary
> 
> The tags that start "cel-ipv6-..." contain the IPv6-related patches.
> I see the latest one is still two weeks old, so I should update it
> with what I sent to Bruce recently.

OK.  Well, I can't currently volunteer to write and test the last bits
of server-side ipv6 functionality, so somebody else needs to or it won't
happen.

--b.
