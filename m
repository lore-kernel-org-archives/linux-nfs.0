From: "Gregory Baker" <gregory.baker@amd.com>
Subject: Re: Linux NFS client over TCP
Date: Tue, 11 Nov 2003 14:26:27 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB145F3.4000704@amd.com>
References: <20031023124428.69700.qmail@web12004.mail.yahoo.com>
 <shs1xt4q8p0.fsf@charged.uio.no>
Reply-To: gregory.baker@amd.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii;
 format=flowed
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
   "Chang Li" <changli_99@yahoo.com>, nfs@lists.sourceforge.net,
   "Chuck Lever" <cel@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AJfDN-0007Tu-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Nov 2003 12:34:17 -0800
Received: from amdext2.amd.com ([163.181.251.1])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AJfDN-0003ij-7v
	for nfs@lists.sourceforge.net; Tue, 11 Nov 2003 12:34:17 -0800
In-Reply-To: <shs1xt4q8p0.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Trond,

I notice that many NFS fixes that we applied outside of the stock kernel 
(2.4.21 series) have made it into 2.4.23-rc1.  Great work!  Thanks!

Do you see any other patches you're going to try to feed to Marcello for 
2.4.23 release?

Can you comment on some of the patches on your web page that would may 
improve NFS client reliability in addition to the stock 2.4.23?

linux-2.4.23-03-soft2.dif:
linux-2.4.23-04-fix_unlink.dif:
linux-2.4.23-05-seekdir.dif:
	.
	.
	.


How "comfortable" do you feel of the value added for this patch?

linux-2.4.23-10-sock_disconnect.dif:

In an environment with 1000's of linux NFS clients and multiple NetApp 
filers? (Chuck?)

I'm trying to get a feel from those I respect most what the best 
recommended route is to produce the most reliable NFS client (for our 
environment and typical activity) based on the upcoming 2.4.23 release.

Thanks,

--Greg




Trond Myklebust wrote:
>>>>>>" " == Chang Li <changli_99@yahoo.com> writes:
> 
> 
>      > Trond, I would like to know some more details.  How does nfs
>      > client know that the status has gone to CLOSE_WAIT state?. NFS
>      > client does not seem to bother about the connection status
>      > while transacting. I thought it is rpc that takes care of
>      > reconnection.
> 
> Absolutely. NFS has no business poking its nose in the details of the
> RPC layer.
> 
>      > Please let me know How we can implement this. ( I'll give a try
>      > ).
> 
> Actually, I thought of an easy implementation just 30 minutes after
> firing off my reply to you. Together with Chuck Lever, I've refined
> the idea, but we haven't yet converted it into a patch:
> 
> Cheers,
>   Trond
> 
> --------------------------------------------
> Add the following fields to struct rpc_xprt:
>   struct tq_struct   task_cleanup;      /* struct work_struct in 2.6.x */
>   struct timer_list  timer;             /* Socket timeout counter */
>   unsigned long      last_used;
>  
> #define XPRT_LOCKED 1
> #define XPRT_SOCKET_TIMEOUT (300 * HZ)
>  
> In xprt_setup()
>   INIT_TQUEUE(&xprt->task_cleanup, xprt_socket_autoclose, xprt);
>   init_timer(&xprt->timer);
>   xprt->timer.function = xprt_init_autodisconnect;
>   xprt->timer.data = (unsigned long) xprt;
>   last_used = jiffies;
> 
> In xprt_release()
>   spin_lock_bh(&xprt->sock_lock);
>   if (list_empty(&xprt->recv) && !xprt->shutdown) {
>         last_used = jiffies;
>         mod_timer(&xprt->timer, jiffies + XPRT_SOCKET_TIMEOUT);
>   }
>   spin_unlock_bh(&xprt->sock_lock);
> 
> In xprt_shutdown()
>   del_timer_sync(&xprt->timer);
> 
> At the top of __xprt_lock_write(), __xprt_lock_write_next
>   if (test_and_set_bit(XPRT_LOCKED, &xprt_sockstate))
>     return 0;
> 
> In __xprt_release_write()
>   if (xprt->snd_task == task)
>     xprt->snd_task = NULL;
>   smp_mb__before_clear_bit();
>   clear_bit(XPRT_LOCKED, &xprt->sockstate);
>   smp_mb__after_clear_bit();
>   __xprt_lock_write_next(xprt);
> 
> 
> New function:
> 
> void xprt_init_autodisconnect(unsigned long data)
> {
>    struct rpc_xprt *xprt = (struct rpc_xprt *)data;
>    struct socket *sock = xprt->sock;
> 
>    spin_lock(&xprt->sock_lock);
>    if (last_used < 200*HZ)
>      goto out_abort;
>    if (test_and_set_bit(XPRT_LOCKED, &xprt_sockstate))
>      goto out_abort;
>    spin_unlock(&xprt->sock_lock);
>    /* Let keventd close the socket */
>    schedule_task(&xprt->task_cleanup);
>    return;
> out_abort:
>    spin_unlock(&xprt->sock_lock);
> }
> 
> void xprt_socket_autoclose(void *args)
> {
>    struct rpc_xprt *xprt = (struct socket *)args;
> 
>    xprt_close(xprt);
>    xprt_release_write(xprt, NULL);
> }
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: The SF.net Donation Program.
> Do you like what SourceForge.net is doing for the Open
> Source Community?  Make a contribution, and help us add new
> features and functionality. Click here: http://sourceforge.net/donate/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
----------------------------------------------------------------------
Greg Baker                                         512-602-3287 (work)
gregory.baker@amd.com                              512-603-1837 (page)
5900 E. Ben White Blvd MS 625                      512-602-6970 (fax)
Austin, TX 78741                                   512-555-1212 (info)




-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
