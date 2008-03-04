From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] Add more entropy to selection of port and xid for NFS client.
Date: Tue, 4 Mar 2008 12:00:40 -0500
Message-ID: <4AD9A05A-64F6-4F6C-BF8A-C013A361F1A4@oracle.com>
References: <20080304163343.18442.patches@notabene> <1080304053553.18549@suse.de>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:38872 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072AbYCDRCL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2008 12:02:11 -0500
In-Reply-To: <1080304053553.18549@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-

On Mar 4, 2008, at 12:35 AM, NeilBrown wrote:
> Hi Trond/Chunk
>
> I wonder what you think of this patch.
>
> I found we needed it for some customers who had machines with NFS root
> who (for reasons I never fully understood) find they reboot their
> machines fairly often (maybe it was a test setup or something).  The
> often got "inode number mismatch" errors because the reply came out of
> the server's cache and was left over from before the client's reboot.

If the problem is indeed lack of entropy at boot time, then random32 
() should be fixed.  It suggests that random32_init() isn't getting  
invoked soon enough during boot to have any effect on the starting  
XID selection.  This seems to get broken periodically... perhaps  
random32() should warn if it detects that random32_init() hasn't been  
invoked yet.

Another alternative: continue to use net_random(), but the RPC client  
could add entropy via net_srandom() calls during it's  
initialization.  Unfortunately net_srandom() works only on the local  
CPU's entropy pool, so net_random() calls on other CPUs would still  
be a problem.

More below...

> ### Comments for Changeset
>
> Diskless clients that use NFS-root have very little chance
> to gain much entropy in net_random before the NFS client must
> choose a port number and an 'xid' to being talking to the server.
> So add as much entropy as possible.
>
> Without this, clients can and do suffer from collisions in the servers
> reply cache, and get meaningless replies.
>
> Signed-off-by: Neil Brown <neilb@suse.de>
>
> ### Diffstat output
>  ./net/sunrpc/xprt.c     |    5 ++++-
>  ./net/sunrpc/xprtsock.c |    7 +++++--
>  2 files changed, 9 insertions(+), 3 deletions(-)
>
> diff .prev/net/sunrpc/xprt.c ./net/sunrpc/xprt.c
> --- .prev/net/sunrpc/xprt.c	2008-03-04 16:33:26.000000000 +1100
> +++ ./net/sunrpc/xprt.c	2008-03-04 16:33:36.000000000 +1100
> @@ -922,7 +922,10 @@ static inline __be32 xprt_alloc_xid(stru
>
>  static inline void xprt_init_xid(struct rpc_xprt *xprt)
>  {
> -	xprt->xid = net_random();
> +	get_random_bytes(&xprt->xid, sizeof(xprt->xid));

In fact I think we used to use get_random_bytes() for the initial  
XID, and that wasn't initialized at boot time either.  We hit exactly  
the same problem.

> +	/* And just in case random_state isn't initialised yet.. */
> +	xprt->xid ^= net_random();
> +	xprt->xid += (CURRENT_TIME.tv_sec << 10);
>  }

I would use tv_nsec instead -- that will give a lot more randomness.   
I see that the port selection logic does use tv_nsec.

Basically you are using get_random_bytes and net_random, both of  
which are known not to work at boot time.  :-)

>  static void xprt_request_init(struct rpc_task *task, struct  
> rpc_xprt *xprt)
>
> diff .prev/net/sunrpc/xprtsock.c ./net/sunrpc/xprtsock.c
> --- .prev/net/sunrpc/xprtsock.c	2008-03-04 16:33:26.000000000 +1100
> +++ ./net/sunrpc/xprtsock.c	2008-03-04 16:28:06.000000000 +1100
> @@ -1283,8 +1283,11 @@ static void xs_udp_timer(struct rpc_task
>  static unsigned short xs_get_random_port(void)
>  {
>  	unsigned short range = xprt_max_resvport - xprt_min_resvport;
> -	unsigned short rand = (unsigned short) net_random() % range;
> -	return rand + xprt_min_resvport;
> +	unsigned short rand;
> +	get_random_bytes(&rand, sizeof(rand));
> +	rand ^= (unsigned short)net_random();
> +	rand ^= (CURRENT_TIME.tv_nsec >> 10);
> +	return (rand % range) + xprt_min_resvport;
>  }
>
>  /**


Maybe you should create a new shared function (perhaps in xprt.c)  
that does the mashing up of the current time and some random values.

Port selection can take the middle 16 bits of a 32-bit random number.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
