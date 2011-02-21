Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tac.ki.iif.hu ([193.6.222.43]:59221 "EHLO tac.ki.iif.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751296Ab1BUTya (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Feb 2011 14:54:30 -0500
Received: from wferi by tac.ki.iif.hu with local (Exim 4.72)
	(envelope-from <wferi@niif.hu>)
	id 1Prbpw-0005zi-Rv
	for linux-nfs@vger.kernel.org; Mon, 21 Feb 2011 20:54:24 +0100
From: Ferenc Wagner <wferi@niif.hu>
To: linux-nfs@vger.kernel.org
Subject: Re: server does not abort grace period
References: <87wrl6ix2i.fsf@tac.ki.iif.hu>
Date: Mon, 21 Feb 2011 20:54:24 +0100
In-Reply-To: <87wrl6ix2i.fsf@tac.ki.iif.hu> (Ferenc Wagner's message of "Fri,
	11 Feb 2011 13:18:29 +0100")
Message-ID: <87mxlpw4cv.fsf@tac.ki.iif.hu>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Ferenc Wagner <wferi@niif.hu> writes:

> We're running 2.6.32 (Debian squeeze) NFS4 server and clients.  The
> server boots and runs purely from SAN, so we can start it on different
> computers.  In case of such "hardware failovers" I'd expect the clients
> to quickly reclaim their locks (if any) and thus the server to abort
> it's 90-second grace period early.  However, this does not happen,
> ruining our HA like, totally.
>
> So, the questions: is the functionality of aborting the grace period
> early missing from version 2.6.32 of the Linux kernel?  If yes, is it
> present in any kernel version?  If it should work, could someone offer
> some advice on debugging it?  If it isn't supported, what's the
> best practice of providing highly available NFSv4 today?

Hi,

Could somebody please share any related wisdom?  Pretty please?
In short, how to fight grace period in a HA NFS4 setup?
Decreasing it (of course after cutting the lock lease time) seems a
rather big hammer, I'd like to avoid using it if reasonably possible.
-- 
Thanks,
Feri.
