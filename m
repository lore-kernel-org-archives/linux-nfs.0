Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:56908 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755985Ab3GOL5V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Jul 2013 07:57:21 -0400
Date: Mon, 15 Jul 2013 07:57:11 -0400
From: Jim Rees <rees@umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: "J.Bruce Fields" <bfields@citi.umich.edu>,
        Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130715115711.GA9053@umich.edu>
References: <20130710092255.0240a36d@notabene.brown>
 <20130710022735.GI8281@fieldses.org>
 <20130715012620.GC7429@umich.edu>
 <20130715150229.06ff8464@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130715150229.06ff8464@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NeilBrown wrote:

  On Sun, 14 Jul 2013 21:26:20 -0400 Jim Rees <rees@umich.edu> wrote:
  
  > J.Bruce Fields wrote:
  > 
  >   On Wed, Jul 10, 2013 at 09:22:55AM +1000, NeilBrown wrote:
  >   > 
  >   > Hi,
  >   >  I just noticed this commit:
  >   > 
  >   > commit 9660439861aa8dbd5e2b8087f33e20760c2c9afc
  >   > Author: Olga Kornievskaia <aglo@citi.umich.edu>
  >   > Date:   Tue Oct 21 14:13:47 2008 -0400
  >   > 
  >   >     svcrpc: take advantage of tcp autotuning
  >   > 
  >   > 
  >   > which I must confess surprised me.  I wonder if the full implications of
  >   > removing that functionality were understood.
  >   > 
  >   > Previously nfsd would set the transmit buffer space for a connection to
  >   > ensure there is plenty to hold all replies.  Now it doesn't.
  >   > 
  >   > nfsd refuses to accept a request if there isn't enough space in the transmit
  >   > buffer to send a reply.  This is important to ensure that each reply gets
  >   > sent atomically without blocking and there is no risk of replies getting
  >   > interleaved.
  >   > 
  >   > The server starts out with a large estimate of the reply space (1M) and for
  >   > NFSv3 and v2 it quickly adjusts this down to something realistic.  For NFSv4
  >   > it is much harder to estimate the space needed so it just assumes every
  >   > reply will require 1M of space.
  >   > 
  >   > This means that with NFSv4, as soon as you have enough concurrent requests
  >   > such that 1M each reserves all of whatever window size was auto-tuned, new
  >   > requests on that connection will be ignored.
  >   >
  >   > This could significantly limit the amount of parallelism that can be achieved
  >   > for a single TCP connection (and given that the Linux client strongly prefers
  >   > a single connection now, this could become more of an issue).
  >   
  >   Worse, I believe it can deadlock completely if the transmit buffer
  >   shrinks too far, and people really have run into this:
  > 
  > It's been a few years since I looked at this, but are you sure autotuning
  > reduces the buffer space available on the sending socket? That doesn't sound
  > like correct behavior to me. I know we thought about this at the time.
  
  Autotuning is enabled when SOCK_SNDBUF_LOCK is not set in sk_userlocks.
  
  One of the main effects of this flag is to disable:
  
  static inline void sk_stream_moderate_sndbuf(struct sock *sk)
  {
  	if (!(sk->sk_userlocks & SOCK_SNDBUF_LOCK)) {
  		sk->sk_sndbuf = min(sk->sk_sndbuf, sk->sk_wmem_queued >> 1);
  		sk->sk_sndbuf = max(sk->sk_sndbuf, SOCK_MIN_SNDBUF);
  	}
  }
  
  
  which will reduce sk_sndbuf to half the queued writes. As sk_wmem_queued
  cannot grow above sk_sndbuf, the definitely reduces sk_sndbuf (though never
  below SOCK_MIN_SNDBUF which is 2K.
  
  This seems to happen under memory pressure (sk_stream_alloc_skb).
  
  So yes: memory pressure can reduce the sndbuf size when autotuning is enabled, and it
  can get as low as 2K.
  (An API to set this minimum to e.g. 2M for nfsd connections would be an alternate
  fix for the deadlock, as Bruce has already mentioned).
  
  > 
  > It does seem like a bug that we don't multiply the needed send buffer space
  > by the number of threads. I think that's because we don't know how many
  > threads there are going to be in svc_setup_socket()?
  
  We used to, but it turned out to be too small in practice!  As it auto-grows,
  the "4 * serv->sv_max_mesg" setting is big enough ... if only it wouldn't
  shrink below that.

This sounds familiar. In fact I think we asked on the network mailing list
about providing an api to set a minimum on the socket buffer. I'll go
through my old email and see if I can find it.
