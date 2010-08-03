Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:51695 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753993Ab0HCViM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 17:38:12 -0400
Date: Tue, 3 Aug 2010 17:36:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Michael Guntsche <mike@it-loops.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberos auth Problem with nfs3/4
Message-ID: <20100803213650.GJ31579@fieldses.org>
References: <20100803154556.GA6262@gibson.comsick.at>
 <20100803194342.GE31579@fieldses.org>
 <20100803211906.GA24236@gibson.comsick.at>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100803211906.GA24236@gibson.comsick.at>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 03, 2010 at 11:19:06PM +0200, Michael Guntsche wrote:
> Hello Bruce.
> 
> I was a little bit early with my success report. I can now successfully
> mount the exports with sec=krb5 and can also read and write from linux
> clients. But now I get the following messages from the kernel on the
> server itself. This apparently happens when I try to read/write to the
> export.
> 
> Aug  3 23:12:23 gibson kernel: RPC: AUTH_GSS upcall timed out.
> Aug  3 23:12:23 gibson kernel: Please check user daemon is running.
> 
> Of course all the daemons on the server are running and the system seems
> to work fine otherwise.

That's actually a client-side complaint--if you're seeing it on the
server then it's probably the server trying to do a callback to an NFSv4
client.  Are you running rpc.gssd as well as rpc.svcgssd on the server?
Might want to if you want delegations to work (but it's not a critical
problem).

--b.
