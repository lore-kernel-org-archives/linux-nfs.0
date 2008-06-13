From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: CONFIG_DEBUG_SLAB_LEAK omits size-4096 and larger?
Date: Fri, 13 Jun 2008 18:04:22 -0400
Message-ID: <20080613220422.GC14338@fieldses.org>
References: <0122F800A3B64C449565A9E8C297701002D75DA3@hoexmb9.conoco.net> <20080611184613.GM15380@fieldses.org> <20080611195222.GP15380@fieldses.org> <20080611160947.5f08fb16@tleilax.poochiereds.net> <20080611205749.GA25194@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DAA@hoexmb9.conoco.net> <20080611225431.GD25194@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DAE@hoexmb9.conoco.net> <20080613201552.GH8501@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DB6@hoexmb9.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@poochiereds.net>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Neil Brown <neilb@suse.de>
To: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41476 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754647AbYFMWE0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 18:04:26 -0400
In-Reply-To: <0122F800A3B64C449565A9E8C297701002D75DB6-zIGg2qceuZx7uNL6xugVa6xOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 13, 2008 at 04:53:31PM -0500, Weathers, Norman R. wrote:
>  
> 
> > > The big one seems to be the __alloc_skb. (This is with 16 
> > threads, and
> > > it says that we are using up somewhere between 12 and 14 GB 
> > of memory,
> > > about 2 to 3 gig of that is disk cache).  If I were to put anymore
> > > threads out there, the server would become almost 
> > unresponsive (it was
> > > bad enough as it was).   
> > > 
> > > At the same time, I also noticed this:
> > > 
> > > skbuff_fclone_cache: 1842524 __alloc_skb+0x50/0x170
> > > 
> > > Don't know for sure if that is meaningful or not....
> > 
> > OK, so, starting at net/core/skbuff.c, this means that this memory was
> > allocated by __alloc_skb() calls with something nonzero in the third
> > ("fclone") argument.  The only such caller is alloc_skb_fclone().
> > Callers of alloc_skb_fclone() include:
> > 
> > 	sk_stream_alloc_skb:
> > 		do_tcp_sendpages
> > 		tcp_sendmsg
> > 		tcp_fragment
> > 		tso_fragment
> 
> Interesting you should mention the tso...  We recently went through and
> turned on TSO on all of our systems, trying it out to see if it helped
> with performance...  This could be something to do with that.  I can try
> disabling the tso on all of the servers and see if that helps with the
> memory.  Actually, I think I will, and I will monitor the situation.  I
> think it might help some, but I still think there may be something else
> going on in a deep corner...

I'll plead total ignorance about TSO, and it sounds like a long
shot--but sure, it'd be worth trying, thanks.

> 
> > 		tcp_mtu_probe
> > 	tcp_send_fin
> > 	tcp_connect
> > 	buf_acquire:
> > 		lots of callers in tipc code (whatever that is).
> > 
> > So unless you're using tipc, or you have something in userspace going
> > haywire (perhaps netstat would help rule that out?), then I suppose
> > there's something wrong with knfsd's tcp code.  Which makes sense, I
> > guess.
> > 
> 
> Not for sure what tipc is either....
> 
> > I'd think this sort of allocation would be limited by the number of
> > sockets times the size of the send and receive buffers.
> > svc_xprt.c:svc_check_conn_limits() claims to be limiting the number of
> > sockets to (nrthreads+3)*20.  (You aren't hitting the "too many open
> > connections" printk there, are you?)  The total buffer size should be
> > bounded by something like 4 megs.
> > 
> > --b.
> > 
> 
> Yes, we are getting a continuous stream of the too many open connections
> scrolling across our logs.  

That's interesting!  So we should probably look more closely at the
svc_check_conn_limits() behavior.  I wonder whether some pathological
behavior is triggered in the case where you're constantly over the limit
it's trying to enforce.

(Remind me how many active clients you have?)

> No problems.  I feel good if I exercised some deep corner of the code
> and found something that needed flushed out, that's what the experience
> is all about, isn't it?

Yep!

--b.
