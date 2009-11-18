Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48865 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753197AbZKRVa3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Nov 2009 16:30:29 -0500
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1NAs7D-0000nf-Sp
	for linux-nfs@vger.kernel.org; Wed, 18 Nov 2009 16:31:03 -0500
Date: Wed, 18 Nov 2009 16:31:03 -0500
To: linux-nfs@vger.kernel.org
Subject: Re: rpc.mountd --manage-gids breaks on UID differences
Message-ID: <20091118213103.GB2650@fieldses.org>
References: <20091117153928.GA12493@dot.freshdot.net> <20091117200831.GA3969@fieldses.org> <20091117204332.GA15295@dot.freshdot.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20091117204332.GA15295@dot.freshdot.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Nov 17, 2009 at 09:43:33PM +0100, Sander Smeenk wrote:
> Quoting J. Bruce Fields (bfields@fieldses.org):
> 
> > > Disabling '--manage-gids' and remouting, restarting or rebooting
> > > completely fixes the problem. Reintroducing '--manage-gids' breaks it
> > > again.
> > Just from those symptoms it sounds to me like rpc.mountd isn't
> > responding to upcalls when asked about a uid for which there's no
> > account on the server.  It should be returning a negative response
> > immediately.
> 
> Something like that sounds right. Aparently the client is waiting for
> the server to respond, that's what i can tell from the debug logs[1]
> timestamped 14243124.709876 through 14243184.647892. Which eventually
> leads to the kernel logging the 'not responding' message at
> 14243306.507319.
> 
> [1] http://www.freshdot.net/tmp/client-broken-syslog
> 
> > (I assume your server isn't using ldap or nis or something that could
> > cause lookups of a uid to take a long time?)
> 
> Correct. My client and server are using UNIX auth from shadow files.
> 
> The timeframe described above matches the lines from the beginning up to
> 3732517.859721 in the server debug log[2]. I'd have to dig in the kernel
> code to find out what lines 3732513.221898 through 3732513.221913
> exactly tell me. Is anyone on this list an RPC-code ninja?

I don't think there's anything interesting in there.

If you do:

	date +%s >/proc/net/rpc/auth.unix.gid/flush
	strace -e trace=read,write -s4096 -p`pidof rpc.mountd` 

then do whatever you do the client to reproduce the problem, the
resulting strace output might be interesting.

I can't reproduce the problem with nfs-utils from karmic
(1:1.1.4-1ubuntu1) and a recent kernel.

--b.

> 
> And what exactly is the 'NFSD laundromat service' :)
> 
> [2] http://www.freshdot.net/tmp/server-broken-syslog
> 
> Thanks,
> Sander.
> -- 
> | A box without hinges, key, or lid, yet golden treasure inside is hid.
> | 4096R/20CC6CD2 - 6D40 1A20 B9AA 87D4 84C7  FBD6 F3A9 9442 20CC 6CD2
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
