From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux NFS client over TCP
Date: 23 Oct 2003 10:23:39 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs1xt4q8p0.fsf@charged.uio.no>
References: <20031023124428.69700.qmail@web12004.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ACmwC-0000M1-00
	for <nfs@lists.sourceforge.net>; Thu, 23 Oct 2003 14:24:08 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1ACmpj-0000Yp-Nk
	for nfs@lists.sourceforge.net; Thu, 23 Oct 2003 14:17:28 -0700
To: Chang Li <changli_99@yahoo.com>
In-Reply-To: <20031023124428.69700.qmail@web12004.mail.yahoo.com>
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

>>>>> " " == Chang Li <changli_99@yahoo.com> writes:

     > Trond, I would like to know some more details.  How does nfs
     > client know that the status has gone to CLOSE_WAIT state?. NFS
     > client does not seem to bother about the connection status
     > while transacting. I thought it is rpc that takes care of
     > reconnection.

Absolutely. NFS has no business poking its nose in the details of the
RPC layer.

     > Please let me know How we can implement this. ( I'll give a try
     > ).

Actually, I thought of an easy implementation just 30 minutes after
firing off my reply to you. Together with Chuck Lever, I've refined
the idea, but we haven't yet converted it into a patch:

Cheers,
  Trond

--------------------------------------------
Add the following fields to struct rpc_xprt:
  struct tq_struct   task_cleanup;      /* struct work_struct in 2.6.x */
  struct timer_list  timer;             /* Socket timeout counter */
  unsigned long      last_used;
 
#define XPRT_LOCKED 1
#define XPRT_SOCKET_TIMEOUT (300 * HZ)
 
In xprt_setup()
  INIT_TQUEUE(&xprt->task_cleanup, xprt_socket_autoclose, xprt);
  init_timer(&xprt->timer);
  xprt->timer.function = xprt_init_autodisconnect;
  xprt->timer.data = (unsigned long) xprt;
  last_used = jiffies;

In xprt_release()
  spin_lock_bh(&xprt->sock_lock);
  if (list_empty(&xprt->recv) && !xprt->shutdown) {
        last_used = jiffies;
        mod_timer(&xprt->timer, jiffies + XPRT_SOCKET_TIMEOUT);
  }
  spin_unlock_bh(&xprt->sock_lock);

In xprt_shutdown()
  del_timer_sync(&xprt->timer);

At the top of __xprt_lock_write(), __xprt_lock_write_next
  if (test_and_set_bit(XPRT_LOCKED, &xprt_sockstate))
    return 0;

In __xprt_release_write()
  if (xprt->snd_task == task)
    xprt->snd_task = NULL;
  smp_mb__before_clear_bit();
  clear_bit(XPRT_LOCKED, &xprt->sockstate);
  smp_mb__after_clear_bit();
  __xprt_lock_write_next(xprt);


New function:

void xprt_init_autodisconnect(unsigned long data)
{
   struct rpc_xprt *xprt = (struct rpc_xprt *)data;
   struct socket *sock = xprt->sock;

   spin_lock(&xprt->sock_lock);
   if (last_used < 200*HZ)
     goto out_abort;
   if (test_and_set_bit(XPRT_LOCKED, &xprt_sockstate))
     goto out_abort;
   spin_unlock(&xprt->sock_lock);
   /* Let keventd close the socket */
   schedule_task(&xprt->task_cleanup);
   return;
out_abort:
   spin_unlock(&xprt->sock_lock);
}

void xprt_socket_autoclose(void *args)
{
   struct rpc_xprt *xprt = (struct socket *)args;

   xprt_close(xprt);
   xprt_release_write(xprt, NULL);
}


-------------------------------------------------------
This SF.net email is sponsored by: The SF.net Donation Program.
Do you like what SourceForge.net is doing for the Open
Source Community?  Make a contribution, and help us add new
features and functionality. Click here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
