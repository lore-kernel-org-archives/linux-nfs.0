From: Olaf Kirch <okir@suse.de>
Subject: Re: RE: Race condition in xprt_disconnect
Date: Tue, 6 Apr 2004 11:24:01 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040406092401.GA29906@suse.de>
References: <1081197570.2641.133.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BAmoO-0003a2-DG
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 02:24:04 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BAmoN-0005lS-Nc
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 02:24:04 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1081197570.2641.133.camel@lade.trondhjem.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi Trond,

On Mon, Apr 05, 2004 at 04:39:30PM -0400, Trond Myklebust wrote:
> The only way I see that we can have duplicate calls to sock_release() is
> if we are scheduling xprt_socket_autoclose() or xprt_socket_connect()
> more than once.
> Normally xprt_lock_write() should protect us against this, and so AFAICS
> any duplicates must imply that xprt_lock_write() is getting lost before
> xprt_socket_connect() has had a chance to run.

Yes, that's what it looks like. I had another oops now happening
in some selinux function called from tcp_connect. This looks like
two processes in xprt_socket_connect; the first having just opened
the socket and calling connect, and the second one having released
the socket inbetween.

So yes, you're right. My patch is probably not sufficient.

> Presumably this is
> occurring because xprt->snd_task is timing out and then being woken up
> from xprt->pending.

I'm not sure it's a timeout, actually. Looking at the syslog, the NFS
Server closes the connection, and the oops happens one second later.

I've been looking around the code a little more, and here's a
different theory.

 -	server drops connection
 -	tcp_state_change is called and wakes up all tasks with ENOTCONN
 -	rpciod schedules all tasks. The first one gets the write lock,
 	and schedules the xprt_socket_connect worker. Goes to
	sleep on xprt->pending.
 -	xprt_socket_connect runs and calls xprt_close->xprt_disconnect
 	which wakes up all tasks with ENOTCONN. While xprt_socket_connect
	is calling various network functions to create a socket, bind
	and connect it, the following happens on CPU B:
 -	rpciod wakes up, schedules the task that was waiting for the
 	connect. Oops, we already have the send lock (we're snd_task),
	so go ahead and try to reconnect. Thus we schedule
	xprt_socket_connect a second time, which gets run. Note that
	the workqueue stuff resets the pending bit before calling
	xprt_socket_connect. First thing xprt_socket_connect does
	is close xprt->sock.
 -	Back on CPU A, we find the socket we're just trying to
 	connect is gone. Oops.

My patch proposed earlier to change xprt_close to not wake up all tasks
when called from xprt_socket_connect should also prevent this race. The
general case of snd_task waking up before the worker thread has run is
not covered by this, though. But that should only happen due to timeout,
and a 60 second timeout should be sufficient for keventd even on a slow
day.

> Note that in that case we don't actually *want* to schedule a new
> connect(), since the problem is not that the networking operation timed
> out, but rather that keventd is being too slow...

The additional XPRT_PENDING bit may help. It should be sufficient to
set it in xprt_connect and clear it in xprt_connect_status, I think.

Alternatively, it would also help if we canceled the pending work request
in __xprt_release_write. Unfortunately the workqueue api doesn't seem
to support cancellation. Alternatively we could just call
flush_pending_work.

Et ceterum censeo: sunrpc needs a rewrite :)
I'd like to spend some time on it this summer...

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
