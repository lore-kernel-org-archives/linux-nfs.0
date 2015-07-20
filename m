Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38115 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754048AbbGTVXG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Jul 2015 17:23:06 -0400
Date: Mon, 20 Jul 2015 17:23:05 -0400
To: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Parallel file locking quite slow with vers=4.0 compared to vers=3
Message-ID: <20150720212305.GB11050@fieldses.org>
References: <55ACFF59.7040707@bio.ifi.lmu.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55ACFF59.7040707@bio.ifi.lmu.de>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 20, 2015 at 04:02:01PM +0200, Frank Steiner wrote:
> we ran into this when opening about a dozen "xterm ...&"  in an ~/.xinitrc on
> a diskless client with /var mounted with NFS. The xterms popup one after
> another and sometimes it takes up to 7 or 8 seconds until they are all
> available.
> 
> This works without any noticeable delay as long as /var was exported/mounted
> with NFSv3. After switching to NFSv4 the delay showed up. It's caused
> by the utempter processes called by xterm that are trying to write
> (and thus lock) to /var/log/wtmp in parallel.
> 
> Making some little test with a c program doing nothing but 
> "fcntl (fd, F_SETLKW, &lck);" with "lck.l_type = F_WRLCK" it turned out
> that executing ten instances of this program on a NFSv3 share work
> within one second, while on a NFSv4 share about 5 or 6 return immediately,
> the remaining finish after up to 3 seconds. The more instances we
> exec the more are delayed and the delays are getting bigger.
> 
> With NFSv4 shares this always happens.
> If the server exports with NFSv3, it matters which value for vers= 
> the client uses. We mounted the same nfs3-export once with "vers=3" 
> and once with "vers=4.0" on the same client. The test on the vers=3 
> mount shows no delays even with 20 parallel runs, the vers=4.0 mount 
> has the delays.
> 
> I guess this is some kind of flodding protection for parallel operations,
> but can it be tweaked on the server or the client side somehow? Apart
> from the xinitrc setting we have some other (weird :-)) scenarions where
> this delay are ugly and we would be happy to get rid of them (while still
> using NFSv4).

NFSv4 clients poll for conflicting locks; NFSv3 clients instead wait for
server callbacks.  That might explain the difference.

One way to confirm that might be to run client kernels modified to make
the polling behavior (controlled by
fs/nfs/nfs4proc.c:nfs4_set_lock_task_retry()) more aggressive, and see
if that removes the delays in your case.

If that works, then it might also be worth considering implementing
CB_NOTIFY_LOCK:

	https://tools.ietf.org/html/rfc5661#page-593

--b.
