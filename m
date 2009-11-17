From: Sander Smeenk <ssmeenk@freshdot.net>
Subject: Re: rpc.mountd --manage-gids breaks on UID differences
Date: Tue, 17 Nov 2009 21:43:33 +0100
Message-ID: <20091117204332.GA15295@dot.freshdot.net>
References: <20091117153928.GA12493@dot.freshdot.net> <20091117200831.GA3969@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dot.freshdot.net ([213.154.229.18]:34473 "EHLO dot.freshdot.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758AbZKQUn2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Nov 2009 15:43:28 -0500
In-Reply-To: <20091117200831.GA3969@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting J. Bruce Fields (bfields@fieldses.org):

> > Disabling '--manage-gids' and remouting, restarting or rebooting
> > completely fixes the problem. Reintroducing '--manage-gids' breaks it
> > again.
> Just from those symptoms it sounds to me like rpc.mountd isn't
> responding to upcalls when asked about a uid for which there's no
> account on the server.  It should be returning a negative response
> immediately.

Something like that sounds right. Aparently the client is waiting for
the server to respond, that's what i can tell from the debug logs[1]
timestamped 14243124.709876 through 14243184.647892. Which eventually
leads to the kernel logging the 'not responding' message at
14243306.507319.

[1] http://www.freshdot.net/tmp/client-broken-syslog

> (I assume your server isn't using ldap or nis or something that could
> cause lookups of a uid to take a long time?)

Correct. My client and server are using UNIX auth from shadow files.

The timeframe described above matches the lines from the beginning up to
3732517.859721 in the server debug log[2]. I'd have to dig in the kernel
code to find out what lines 3732513.221898 through 3732513.221913
exactly tell me. Is anyone on this list an RPC-code ninja?

And what exactly is the 'NFSD laundromat service' :)

[2] http://www.freshdot.net/tmp/server-broken-syslog

Thanks,
Sander.
-- 
| A box without hinges, key, or lid, yet golden treasure inside is hid.
| 4096R/20CC6CD2 - 6D40 1A20 B9AA 87D4 84C7  FBD6 F3A9 9442 20CC 6CD2
