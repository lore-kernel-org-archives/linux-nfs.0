Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33764 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752683Ab3IQNbX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Sep 2013 09:31:23 -0400
Date: Tue, 17 Sep 2013 09:31:22 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Joschi Brauchle <joschi.brauchle@tum.de>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsd4: utime sometimes takes 40+ seconds to return (but on
 SLES11SP3 with kernel 3.0.82)
Message-ID: <20130917133122.GA32333@fieldses.org>
References: <522F69A1.5090005@tum.de>
 <20130910203530.GA20296@fieldses.org>
 <038EA8B0-BD46-47F2-8F20-DEC8B6DA9087@tum.de>
 <20130910215534.GA21829@fieldses.org>
 <D10808DE-57A1-4C80-8000-2F9E27A423A3@tum.de>
 <20130910221146.GB21829@fieldses.org>
 <5232F7DF.5080204@tum.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5232F7DF.5080204@tum.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 13, 2013 at 01:32:47PM +0200, Joschi Brauchle wrote:
> After three days of testing the NFS server *with* rpc.gssd running
> with multiple NFS clients, we made the following observation:
> 
> The hangs on "utime()" calls have **not** disappeared by simply starting
> rpc.gssd on the server. The problem persists!
> 
> I seems like
> a) on machines that are already connected to the NFS server when
> rpc.gssd is started, the hangs dissappear *mostly*. That is, running
> the utime-test-program causes about 1 spurious hang every 10
> minutes.
> b) on machines that connect to the NFS server at a later time
> (rpc.gssd already running on the server), the hangs seem appear
> every "utime()" call.
> 
> The server emits spurious "RPC: AUTH_GSS upcall timed out. Please
> check user daemon is running." messages, although rpc.gssd is
> running. This may or may not be related, as this message may also be
> caused by clients where the root user access NFS shared with a
> "host/<hostname>" credential.
> 
> The output of "rpcdebug -m nfsd -s proc" to pastebin.com. Get it with
> pbget http://pastebin.com/N34r5kWE
> 
> The IP of the newly connected host is: 192.168.109.154 and its
> SETCLIENTID call was logged. Unfortunately, this log was created
> while *many* other NFS clients were connected, hence it may not be
> too useful.
> 
> I'd be very grateful for any help or instructions on
> debugging/fixing this problem.

NFSv4.0 callbacks have just broken for a while, I think; I'll look into
it.

Meanwhile you should be able to work around this by disabling leases on
the server (so, "echo 0 >/proc/sys/fs/leases-enable" before starting
nfsd).

(Or if you're more daring and running a very recent upstream kernel,
switching to NFSv4.1 should work too.)

--b.
