From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API and remove	signaling
 for shutdown
Date: Mon, 19 May 2008 19:34:27 -0700
Message-ID: <483238B3.4010702@melbourne.sgi.com>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>	<18481.6416.571430.593722@notabene.brown>	<4831F860.6050801@melbourne.sgi.com>	<18482.4782.858347.981553@notabene.brown> <20080519222457.6f24daa5@tupile.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:39402 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756515AbYETCgx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 May 2008 22:36:53 -0400
In-Reply-To: <20080519222457.6f24daa5-PC62bkCOHzGdMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:
>
> This is the problem we have now with the BKL. So much of
> rpc/nlm/nfs/nfsd runs under it that it's nearly impossible to tell what
> it's intended to actually protect. 
Practically none of nfsd runs under BKL, except the startup and shutdown
sequences and some of the write handlers for /proc/fs/nfsd/.
> If we're going to start a push
> toward BKL removal, my humble request is that we try to be as explicit
> as possible about what locks protect what data structures.
>   
See comments in net/sunrpc/svcsock.c and net/sunrpc/svc.c.  Here the BKL
is protecting the global nfsd_serv pointer.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

