From: "NeilBrown" <neilb@suse.de>
Subject: Re: RPC: multiple fragments per record not supported
Date: Tue, 9 Jun 2009 12:03:42 +1000 (EST)
Message-ID: <676fa8ce48993d133dc0c5deb308ea14.squirrel@neil.brown.name>
References: <20090609002033.GL21174@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: "Simon Kirby" <sim@hostway.ca>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:45531 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280AbZFICDu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 22:03:50 -0400
In-Reply-To: <20090609002033.GL21174@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, June 9, 2009 10:20 am, Simon Kirby wrote:
> Hello!
>
> With 2.6.28.10 and 2.6.29.4 knfsd after a few hours of heavy concurrent
> NFSv3 write loads (migration of Maildirs with rsync), we are seeing this
> error:
>
> 	kernel: RPC: multiple fragments per record not supported
>
> ...followed by knfsd immediately ignoring all further requests.
> Restarting knfsd (/etc/init.d/nfs-kernel-server restart) seems to make
> it start responding and work as normal again.
>
> "ps -eo pid,stat,args,wchan" during the event shows all nfsd processes
> sleeping in "svc_recv":
>
> 22714 S<   [nfsd]                      svc_recv
>
> This client with the high write load is an old 2.6.17 kernel, mounting
> the server with
> rw,nolock,hard,intr,timeo=9,retrans=3,rsize=8192,wsize=8192
> (jumbo frames are enabled).
>
> Is this any sort of known issue?  I'm trying to reproduce it in a testing
> environment.

Yes.  Known issue.  The data stream from the client gets corrupted.
Fix is

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=e0ab53deaa91293a7958d63d5a2cf4c5645ad6f0

which is in 2.6.18

NeilBrown


