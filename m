From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 00/33] SVC Transport Switch
Date: Wed, 3 Oct 2007 19:57:54 +1000
Message-ID: <20071003095754.GJ21388@sgi.com>
References: <20070927045751.12677.98896.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id0wr-0008E5-PR
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 02:55:24 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Id0w4-0001BZ-EB
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 02:54:33 -0700
In-Reply-To: <20070927045751.12677.98896.stgit@dell3.ogc.int>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

G'day,

Compendium reply to all 33 patches from 26 Sep 2007.  Sorry
about the delay.

On Wed, Sep 26, 2007 at 11:57:51PM -0500, Tom Tucker wrote:
> Subject: [RFC,PATCH 00/33] SVC Transport Switch

> - The overall design of the switch has been modified to be more similar
>   to the client side, e.g.
>         - There is a transport class structure svc_xprt_class, and
>         - A transport independent structure is manipulated by xprt
>           independent code (svc_xprt)
>         - Further consolidation of transport independent logic out of
>           transport providers and into transport independent code.
> - Transport independent code has been broken out into a separate file
> - Transport independent functions prevously adorned with _sock_ have
>   had their names changed, e.g. svc_sock_enqueue

Great!  These patches are coming along nicely.

Is there any documentation being added to describe the new xprt interface?



> Subject: [RFC,PATCH 01/33] svc: Add an svc transport class

> +struct svc_xprt_class {
> [...]
> +       struct svc_xprt_ops     *xcl_ops;
> [...]
> +struct svc_xprt {
> [...]
> +       struct svc_xprt_ops     xpt_ops;

It seems redundant to have two lots of the ops, and especially so to
have the one in svc_xprt be a struct instance rather than a pointer.
The current client code doesn't seem to do anything like this either.

Perhaps you could move the svc_xprt_ops.xpo_create (the only function
pointer in svc_xprt_ops which needs to be called before a svc_xprt
exists) to svc_xprt_class, and setup the svc_xprt.xpt_ops pointer in
those functions?  Then you'd have something like:

/* svc_xprt.h */

struct svc_xprt_class {
    ...
    struct svc_xprt *(*xcl_create)(struct svc_serv *, struct sockaddr *, int);
};

struct svc_xprt {
    ...
    const struct svc_xprt_ops *xpt_ops;
};

/* svc_sock.c */

static struct svc_xprt *
svc_udp_create(struct svc_serv *serv, struct sockaddr *sa, int flags)
{
    return svc_create_socket(serv, IPPROTO_UDP, sa,
    	    	    	     sizeof(struct sockaddr_in), flags,
			     &svc_udp_ops);
}

This is not only neater but more consistent with the client code.


> +int    svc_reg_xprt_class(struct svc_xprt_class *);
> +int    svc_unreg_xprt_class(struct svc_xprt_class *);

There are perfectly good English words "register" and "unregister"
that could be used instead of "reg" and "unreg".  RPC doesn't
need to stand for Reduced Phoneme Count ;-)

> +int svc_reg_xprt_class(struct svc_xprt_class *xcl)
> +{

This allows two svc_xprt_class of the same name to be registered.
Is that deliberate?

> +int svc_unreg_xprt_class(struct svc_xprt_class *xcl)

Why does this scan the list?  It could just do a list_del_init().
There's no point returning -ENOENT or any other error either, nothing
useful can be done to handle it.


> Subject: [RFC,PATCH 02/33] svc: Make svc_sock the tcp/udp transport

> +void svc_init_xprt_sock(void)
> +{
> +       svc_reg_xprt_class(&svc_tcp_class);ug.h
> +       svc_reg_xprt_class(&svc_udp_class);
> +}

You could might check the error code from svc_reg_xprt_class() and
propagate it, to avoid doing things like loading the module twice.
   
> Subject: [RFC,PATCH 03/33] svc: Change the svc_sock in the rqstp structure to a transport

ok

> Subject: [RFC,PATCH 04/33] svc: Add a max payload value to the transport

> @@ -17,11 +17,13 @@ struct svc_xprt_class {
>         struct module           *xcl_owner;
>         struct svc_xprt_ops     *xcl_ops;
>         struct list_head        xcl_list;
> +       u32                     xcl_max_payload;
>  };
>                                                                                                                                           
>  struct svc_xprt {
>         struct svc_xprt_class   *xpt_class;
>         struct svc_xprt_ops     xpt_ops;
> +       u32                     xpt_max_payload;
>  };
                                                                                                                                          

Why have a max_payload variable in two places?  Either would be fine by me.


> Subject: [RFC,PATCH 05/33] svc: Move sk_sendto and sk_recvfrom to svc_xprt_class

ok


> Subject: [RFC,PATCH 06/33] svc: Add transport specific xpo_release function

ok


> Subject: [RFC,PATCH 07/33] svc: Add per-transport delete functions

ok (assuming the later patch "Move the authinfo cache to svc_xprt.")


> Subject: [RFC,PATCH 08/33] svc: Add xpo_prep_reply_hdr

ok


> Subject: [RFC,PATCH 09/33] svc: Add a transport function that checks for write space

> The code that checked for white space was coupled with code that
                            ^^^^^

> +               dprintk("svc: no write space, socket %p  not enqueued\n", svsk);
                                                         ^^

> +       /*
> +        * Set the SOCK_NOSPACE flag before checking the available
> +        * sock space.
> +        */

Well, yes, we can see that.  The comment should contain Neil's explanation
of *why* we do that.

Also: this patch makes the inline svc_sock_wspace() redundant but doesn't remove it.


> Subject: [RFC,PATCH 10/33] svc: Move close processing to a single place

ok


> Subject: [RFC,PATCH 11/33] svc: Add xpo_accept transport function

ok

I presume it's intentional that NFS/RDMA transport be subjected
to the connection limit?  In earlier versions they weren't.


> Subject: [RFC,PATCH 12/33] svc: Add a generic transport svc_create_xprt function


> +               if (strcmp(xprt_name, xcl->xcl_name)==0) {
> +                       spin_unlock(&svc_xprt_class_lock);
> +                       if (try_module_get(xcl->xcl_owner)) {

Is this racy vs module unload?


Otherwise ok


> Subject: [RFC,PATCH 13/33] svc: Change services to use new svc_create_xprt service

ok


> Subject: [RFC,PATCH 14/33] svc: Change sk_inuse to a kref


> transport indepenent svc_xprt structure. Change the reference count
            ^^^^^^^^^^	    

> Subject: [RFC,PATCH 15/33] svc: Move sk_flags to the svc_xprt structure


> +#define        XPT_DETACHED    10                      /* detached from tempsocks list */
> +#define XPT_LISTENER   11                      /* listening endpoint */
          ^

Unnecessary whitespace drama.


> Subject: [RFC,PATCH 16/33] svc: Move sk_server and sk_pool to svc_xprt

ok

> Subject: [RFC,PATCH 17/33] svc: Make close transport independent

> -svc_delete_socket(struct svc_sock *svsk)
> +svc_delete_xprt(struct svc_xprt *xprt)

Would svc_xprt_delete() be a better name?  The object is a "svc_xprt"
after all, and this would be more consistent with your svc_xprt_get()
svc_xprt_put() etc.

> -static void svc_close_socket(struct svc_sock *svsk)
> +static void svc_close_xprt(struct svc_xprt *xprt)

Likewise this could be svc_xprt_close().


> Subject: [RFC,PATCH 18/33] svc: Move sk_reserved to svc_xprt

ok

> Subject: [RFC,PATCH 19/33] svc: Make the enqueue service transport neutral and export it.

ok


> Subject: [RFC,PATCH 20/33] svc: Make svc_send transport neutral

> +       struct mutex            xpt_mutex;      /* to serialize sending data */

Perhaps it would be better to name it something like xpt_send_mutex ?


> Subject: [RFC,PATCH 21/33] svc: Change svc_sock_received to svc_xprt_received and export it

> @@ -1123,8 +1123,6 @@ svc_tcp_accept(struct svc_xprt *xprt)
>         }
>         memcpy(&newsvsk->sk_local, sin, slen);
>                                                                                                                                           
> -       svc_sock_received(newsvsk);
> -
>         if (serv->sv_stats)
>                 serv->sv_stats->nettcpconn++;
>                                                                                                                                           

Minor nit, but moving the call to svc_xprt_received() up into the
caller is a change that ought to be mentioned in the patch comment.


> Subject: [RFC,PATCH 22/33] svc: Move sk_lastrecv to svc_xprt

> This functionally trivial change moves the tranpsort independent sk_lastrecv
                                             ^^^^^^^^^
					     
> @@ -1773,7 +1773,7 @@ static struct svc_sock *svc_setup_socket
>         svsk->sk_ostate = inet->sk_state_change;
>         svsk->sk_odata = inet->sk_data_ready;
>         svsk->sk_owspace = inet->sk_write_space;
> -       svsk->sk_lastrecv = get_seconds();
> +       svsk->sk_xprt.xpt_lastrecv = get_seconds();
>         spin_lock_init(&svsk->sk_lock);
>         INIT_LIST_HEAD(&svsk->sk_deferred);

This initialisation code ought to be in svc_xprt_init().
I see it moves there in a later patch, though.


> Subject: [RFC,PATCH 23/33] svc: Move the authinfo cache to svc_xprt.


> @@ -89,6 +89,9 @@ static inline void svc_xprt_free(struct
>         struct module *owner = xprt->xpt_class->xcl_owner;
>         BUG_ON(atomic_read(&kref->refcount));
>         xprt->xpt_ops.xpo_free(xprt);
> +       if (test_bit(XPT_CACHE_AUTH, &xprt->xpt_flags)
> +           && xprt->xpt_auth_cache != NULL)
> +               svcauth_unix_info_release(xprt->xpt_auth_cache);
>         module_put(owner);
>  }
>                                                                                                                                           

Woops, that's a use-after-free.


> Subject: [RFC,PATCH 24/33] svc: Make deferral processing xprt independent


You're also moving the call to svc_deferred_dequeue() and
svc_deferred_recv() from the transport-dependent svc_foo_recvfrom()
methods up into the xprt core.  This is good, but it means the patch is
not functionally trivial as the patch comment claims.  For example for
UDP it may delay the implementation of buffer changes when XPT_CHNGBUF
is set until after a deferred call is processed.

> @@ -1612,7 +1602,12 @@ svc_recv(struct svc_rqst *rqstp, long ti
>                 dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
>                         rqstp, pool->sp_id, svsk,
>                         atomic_read(&svsk->sk_xprt.xpt_ref.refcount));
> -               len = svsk->sk_xprt.xpt_ops.xpo_recvfrom(rqstp);
> +
> +               if ((rqstp->rq_deferred = svc_deferred_dequeue(&svsk->sk_xprt))) {
> +                       svc_xprt_received(&svsk->sk_xprt);
> +                       len = svc_deferred_recv(rqstp);
> +               } else
> +                       len = svsk->sk_xprt.xpt_ops.xpo_recvfrom(rqstp);
>                 dprintk("svc: got len=%d\n", len);
>         }
                                                                                                                                          

I'm surprised that the svc_deferred_dequeue() call isn't being done
outside this else{}, so that the code looks like (from the SGI tree):


        if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
                dprintk("svc_recv: found SK_CLOSE\n");
                svc_delete_socket(svsk);
        } else if (test_bit(SK_LISTENER, &svsk->sk_flags)) {
                svsk->sk_ops->sko_accept(svsk);
                svc_sock_received(svsk);
        } else if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk))) {                 dprintk("svc: rqstp=%p got deferred request on svsk=%p\n", rqstp, svsk);
                svc_sock_received(svsk);
                len = svc_deferred_recv(rqstp);
        } else {
                dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
                         rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
                len = svsk->sk_ops->sko_recvfrom(rqstp);
                dprintk("svc: got len=%d\n", len);
        }

That seems a little cleaner to me.



> Subject: [RFC,PATCH 25/33] svc: Move the sockaddr information to svc_xprt

> Move the IP address fields to the svc_xprt structure. Note that this
> assumes that _all_ RPC transports must have IP based 4-tuples. This
> seems reasonable given the tight coupling with the portmapper etc...
> Thoughts?

Such an assumption only seems reasonable if you assume the old v2
portmap protocol and IPv4.

The portmap (aka rpcbind) v3 and v4 protocols use the TLI "uaddr"
concept to store addresses.  Uaddrs are a string encoding of the IP
address + port tuple.  For IPv4 this is the standard dotted-quad
plus two more quads representing the two bytes of the port,
e.g. 123.34.45.56.8.1 is port 2049 on host 123.34.45.56.

With IPv6 there's no guarantee that you can extract a IPv4 address
from an IPv6 address, nor that any particular host has a routable or
IPv4 address at all.

But I don't think this patch requires any such assumption.  It does
however screw up rq_daddr in the UDP case; the code you've pulled
out as svc_copy_addr() only works correctly for TCP.  See the
svc_udp_get_dest_address() function for how UDP works.



> Subject: [RFC,PATCH 26/33] svc: Make svc_sock_release svc_xprt_release

> @@ -377,9 +377,9 @@ void svc_reserve(struct svc_rqst *rqstp,
>  }
>                                                                                                                                           
>  static void
> -svc_sock_release(struct svc_rqst *rqstp)
> +svc_xprt_release(struct svc_rqst *rqstp)
>  {
> -       struct svc_sock *svsk = rqstp->rq_sock;
> +       struct svc_xprt *xprt = rqstp->rq_xprt;
>                                                                                                                                           
>         rqstp->rq_xprt->xpt_ops.xpo_release(rqstp);
>                                                                                                                                           
> 


This isn't really a svc_xprt function, it's a svc_rqst function,
so svc_xprt_release() is a confusing name.  Perhaps a name like
svc_rqst_done_sending() might be more appropriate.


> Subject: [RFC,PATCH 27/33] svc: Make svc_recv transport neutral

ok.


> Subject: [RFC,PATCH 28/33] svc: Make svc_age_temp_sockets svc_age_temp_transports

> @@ -1685,49 +1685,51 @@ svc_send(struct svc_rqst *rqstp)
>   * a mark-and-sweep algorithm.
>   */
>  static void
> -svc_age_temp_sockets(unsigned long closure)
> +svc_age_temp_xprts(unsigned long closure)
>  {

Minor nit, but the new name doesn't match the one in the Subject: line.



> Subject: [RFC,PATCH 29/33] svc: Move common create logic to common code

> +                               /* setup timer to age temp sockets */

This comment should be updated to refer to transports.


> @@ -146,6 +146,13 @@ int svc_create_xprt(struct svc_serv *ser
>                                 if (IS_ERR(newxprt)) {
>                                         module_put(xcl->xcl_owner);
>                                         ret = PTR_ERR(newxprt);
> +                               } else {
> +                                       clear_bit(XPT_TEMP,
> +                                                 &newxprt->xpt_flags);
> +                                       spin_lock_bh(&serv->sv_lock);
> +                                       list_add(&newxprt->xpt_list,
> +                                                &serv->sv_permsocks);
> +                                       spin_unlock_bh(&serv->sv_lock);
>                                 }
>                                 goto out;
>                         }

and

> @@ -1833,6 +1827,12 @@ int svc_addsock(struct svc_serv *serv,
>                         svc_xprt_received(&svsk->sk_xprt);
>                         err = 0;
>                 }
> +               if (so->sk->sk_protocol == IPPROTO_TCP)
> +                       set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
> +               clear_bit(XPT_TEMP, &svsk->sk_xprt.xpt_flags);
> +               spin_lock_bh(&serv->sv_lock);
> +               list_add(&svsk->sk_xprt.xpt_list, &serv->sv_permsocks);
> +               spin_unlock_bh(&serv->sv_lock);
>         }
>         if (err) {
>                 sockfd_put(so);

Why is this happening in two places now?


> Subject: [RFC,PATCH 30/33] svc: Removing remaining references to rq_sock in rqstp

ok


> Subject: [RFC,PATCH 31/33] svc: Move the xprt independent code to the svc_xprt.c file

functions not lost:
    ok
    
code in functions not lost:

> -svc_age_temp_xprts(unsigned long closure)
> [...]
> -		if (atomic_read(&svsk->sk_xprt.xpt_ref.refcount) > 1=20
> -		    || test_bit(SK_BUSY, &svsk->sk_flags))
> -			continue;
> [...]
> +svc_age_temp_xprts(unsigned long closure)
> [...]
> +		if (atomic_read(&xprt->xpt_ref.refcount)=20
> +		    || test_bit(XPT_BUSY, &xprt->xpt_flags))
> +			continue;

Looks like you missed some renaming in "Move sk_flags to the svc_xprt structure".
Does the code compile after that patch?

 
newly non-static functions declared in header:
    ok

newly non-static functions exported to modules:
    svc_port_is_privileged is not exported
    svc_close_xprt is not exported
    svc_delete_xprt is not exported


> +int svc_port_is_privileged(struct sockaddr *sin)
> +{
> +	switch (sin->sa_family) {
> +	case AF_INET:
> +		return ntohs(((struct sockaddr_in *)sin)->sin_port)
> +			< PROT_SOCK;
> +	case AF_INET6:
> +		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
> +			< PROT_SOCK;
> +	default:
> +		return 0;
> +	}
> +}
> [...]
> +	rqstp->rq_secure = svc_port_is_privileged(svc_addr(rqstp));

Hmm, here we have svc_port_is_privileged, a very socket-oriented
function, being moved to svc_xprt.c, the supposedly transport-
independent code.  Perhaps svc_xprt_ops.xpo_is_privileged() is needed?
Or have the xpo_recvfrom code set up rq_secure (and save and
restore it in svc_defer/svc_revisit) ?

svc_sock_update_bufs() could be renamed and moved to svc_xprt.c



> Subject: [RFC,PATCH 32/33] svc: Add /proc/sys/sunrpc/transport files


> +char           xprt_buf[128];

> @@ -145,6 +174,14 @@ static ctl_table debug_table[] = {
>                 .mode           = 0644,
>                 .proc_handler   = &proc_dodebug
>         },
> +       {
> +               .ctl_name       = CTL_TRANSPORTS,
> +               .procname       = "transports",
> +               .data           = xprt_buf,
> +               .maxlen         = sizeof(xprt_buf),
> +               .mode           = 0444,
> +               .proc_handler   = &proc_do_xprt,
> +       },
>         { .ctl_name = 0 }
>  };


The xprt_buf[] variable isn't necessary.  The /proc code uses only
the .ctl_name, .procname, and .mode fields of the ctl_table struct,
so you can safely leave .data and .maxlen as zeroes if you provide
your own .proc_handler function.


> Subject: [RFC,PATCH 33/33] knfsd: Support adding transports by writing portlist file


> The general idea is that the rpc.nfsd program would read the transports
> file and then write the portlist file to create listening endpoints
> for all or selected transports. The current mechanism of writing an
> fd would become obsolete.
> [...]
> @@ -554,6 +554,22 @@ static ssize_t write_ports(struct file *
> [...]
> +                               err = svc_create_xprt(nfsd_serv,
> +                                                     transport, port,
> +                                                     SVC_SOCK_ANONYMOUS);

So who does the portmap registration?



Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
