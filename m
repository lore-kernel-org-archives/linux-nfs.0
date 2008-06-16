From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: CONFIG_DEBUG_SLAB_LEAK omits size-4096 and larger?
Date: Mon, 16 Jun 2008 13:43:40 -0400
Message-ID: <20080616174340.GA27083@fieldses.org>
References: <20080611195222.GP15380@fieldses.org> <20080611160947.5f08fb16@tleilax.poochiereds.net> <20080611205749.GA25194@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DAA@hoexmb9.conoco.net> <20080611225431.GD25194@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DAE@hoexmb9.conoco.net> <20080613201552.GH8501@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DB6@hoexmb9.conoco.net> <20080613220422.GC14338@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75DB7@hoexmb9.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@poochiereds.net>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Neil Brown <neilb@suse.de>
To: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:53115 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953AbYFPRno (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Jun 2008 13:43:44 -0400
In-Reply-To: <0122F800A3B64C449565A9E8C297701002D75DB7-zIGg2qceuZx7uNL6xugVa6xOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 13, 2008 at 05:53:20PM -0500, Weathers, Norman R. wrote:
>  
> 
> > -----Original Message-----
> > From: J. Bruce Fields [mailto:bfields@fieldses.org] 
> > Sent: Friday, June 13, 2008 5:04 PM
> > To: Weathers, Norman R.
> > Cc: Jeff Layton; linux-kernel@vger.kernel.org; 
> > linux-nfs@vger.kernel.org; Neil Brown
> > Subject: Re: CONFIG_DEBUG_SLAB_LEAK omits size-4096 and larger?
> > 
> > On Fri, Jun 13, 2008 at 04:53:31PM -0500, Weathers, Norman R. wrote:
> > >  
> > > 
> > > > > The big one seems to be the __alloc_skb. (This is with 16 
> > > > threads, and
> > > > > it says that we are using up somewhere between 12 and 14 GB 
> > > > of memory,
> > > > > about 2 to 3 gig of that is disk cache).  If I were to 
> > put anymore
> > > > > threads out there, the server would become almost 
> > > > unresponsive (it was
> > > > > bad enough as it was).   
> > > > > 
> > > > > At the same time, I also noticed this:
> > > > > 
> > > > > skbuff_fclone_cache: 1842524 __alloc_skb+0x50/0x170
> > > > > 
> > > > > Don't know for sure if that is meaningful or not....
> > > > 
> > > > OK, so, starting at net/core/skbuff.c, this means that 
> > this memory was
> > > > allocated by __alloc_skb() calls with something nonzero 
> > in the third
> > > > ("fclone") argument.  The only such caller is alloc_skb_fclone().
> > > > Callers of alloc_skb_fclone() include:
> > > > 
> > > > 	sk_stream_alloc_skb:
> > > > 		do_tcp_sendpages
> > > > 		tcp_sendmsg
> > > > 		tcp_fragment
> > > > 		tso_fragment
> > > 
> > > Interesting you should mention the tso...  We recently went 
> > through and
> > > turned on TSO on all of our systems, trying it out to see 
> > if it helped
> > > with performance...  This could be something to do with 
> > that.  I can try
> > > disabling the tso on all of the servers and see if that 
> > helps with the
> > > memory.  Actually, I think I will, and I will monitor the 
> > situation.  I
> > > think it might help some, but I still think there may be 
> > something else
> > > going on in a deep corner...
> > 
> > I'll plead total ignorance about TSO, and it sounds like a long
> > shot--but sure, it'd be worth trying, thanks.
> > 
> 
> Tried it, not for sure if I like the results yet or not...  Didn't seem
> to make a huge difference, but here is something that will really make
> you want to drink, the 2.6.25.4 kernel does not go into the size-4096
> hell.

Remind me what the most recent *bad* kernel was of those you tested?
(2.6.25?)

Nothing jumped out at me in a quick skim through the commits from 2.6.25
to 2.6.25.4.

> The largest users of slab there are the size-1024 and still the
> skbuff_fclone_cache.  On a box with 16 threads, it will cache up about 5
> GB of disk data, and still use about 6 GB of slab to put the information
> out there (without TSO on), but at least it is not causing the disk
> cache to be evicted, and it appears to be a little more responsive.  If
> I up it to 32 or more threads, however, it gets very sluggish, but then
> again, I am hitting it with a lot of nodes.
> 
> > > 
> > > > 		tcp_mtu_probe
> > > > 	tcp_send_fin
> > > > 	tcp_connect
> > > > 	buf_acquire:
> > > > 		lots of callers in tipc code (whatever that is).
> > > > 
> > > > So unless you're using tipc, or you have something in 
> > userspace going
> > > > haywire (perhaps netstat would help rule that out?), then 
> > I suppose
> > > > there's something wrong with knfsd's tcp code.  Which 
> > makes sense, I
> > > > guess.
> > > > 
> > > 
> > > Not for sure what tipc is either....
> > > 
> > > > I'd think this sort of allocation would be limited by the 
> > number of
> > > > sockets times the size of the send and receive buffers.
> > > > svc_xprt.c:svc_check_conn_limits() claims to be limiting 
> > the number of
> > > > sockets to (nrthreads+3)*20.  (You aren't hitting the 
> > "too many open
> > > > connections" printk there, are you?)  The total buffer 
> > size should be
> > > > bounded by something like 4 megs.
> > > > 
> > > > --b.
> > > > 
> > > 
> > > Yes, we are getting a continuous stream of the too many 
> > open connections
> > > scrolling across our logs.  
> > 
> > That's interesting!  So we should probably look more closely at the
> > svc_check_conn_limits() behavior.  I wonder whether some pathological
> > behavior is triggered in the case where you're constantly 
> > over the limit
> > it's trying to enforce.
> > 
> > (Remind me how many active clients you have?)
> > 
> 
> 
> We currently are hitting with somewhere around 600 to 800 nodes, but it
> can go up to over 1000 nodes.  We are artificially starving with a
> limited number of threads (2 to 3) right now on the older 2.6.22.14
> kernel because of that memory issue (which may or may not be tso
> related)...

So with that many clients all making requests to the server at once,
we'd start hitting that (serv->sv_nrthreads+3)*20 limit when the number
of threads was set to less than 30-50.  That doesn't seem to be the
point where you're seeing a change in behavior, though.

> I really want to move forward to the newer kernel, but we had an issue
> where clients all of the sudden wouldn't connect, yet other clients
> could, to the exact same server NFS export.  I had booted the server
> into the 2.6.25.4 kernel at the time, and the other admin set us back to
> the 2.6.22.14 to see if that was it.  The clients started working again,
> and he left it there (he also took out my options in the exports file,
> no_subtree_check and insecure).  I know that we are running over the
> number of privelaged ports, and we probably need the insecure, but I am
> having a hard time wrapping my self around all of the problems at
> once....

The secure ports limitation should be a problem for a client that does a
lot of nfs mounts, not for a server with a lot of clients.

--b.
