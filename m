From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: RE: Race condition in xprt_disconnect
Date: Tue, 06 Apr 2004 10:11:29 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1081260688.2846.30.camel@lade.trondhjem.org>
References: <1081197570.2641.133.camel@lade.trondhjem.org>
	 <20040406092401.GA29906@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BArIY-0003Jq-VY
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 07:11:30 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BArIY-0008MO-Ji
	for nfs@lists.sourceforge.net; Tue, 06 Apr 2004 07:11:30 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040406092401.GA29906@suse.de>
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

On Tue, 2004-04-06 at 05:24, Olaf Kirch wrote:
> > Presumably this is
> > occurring because xprt->snd_task is timing out and then being woken up
> > from xprt->pending.
> 
> I'm not sure it's a timeout, actually. Looking at the syslog, the NFS
> Server closes the connection, and the oops happens one second later.
> 
> I've been looking around the code a little more, and here's a
> different theory.
> 
>  -	server drops connection
>  -	tcp_state_change is called and wakes up all tasks with ENOTCONN
>  -	rpciod schedules all tasks. The first one gets the write lock,
>  	and schedules the xprt_socket_connect worker. Goes to
> 	sleep on xprt->pending.
>  -	xprt_socket_connect runs and calls xprt_close->xprt_disconnect
>  	which wakes up all tasks with ENOTCONN. While xprt_socket_connect
> 	is calling various network functions to create a socket, bind
> 	and connect it, the following happens on CPU B:
>  -	rpciod wakes up, schedules the task that was waiting for the
>  	connect. Oops, we already have the send lock (we're snd_task),
> 	so go ahead and try to reconnect. Thus we schedule
> 	xprt_socket_connect a second time, which gets run. Note that
> 	the workqueue stuff resets the pending bit before calling
> 	xprt_socket_connect. First thing xprt_socket_connect does
> 	is close xprt->sock.
>  -	Back on CPU A, we find the socket we're just trying to
>  	connect is gone. Oops.
> 
> My patch proposed earlier to change xprt_close to not wake up all tasks
> when called from xprt_socket_connect should also prevent this race. The
> general case of snd_task waking up before the worker thread has run is
> not covered by this, though. But that should only happen due to timeout,
> and a 60 second timeout should be sufficient for keventd even on a slow
> day.

Can't tcp_state_change() inject a few more wakeups when we call
xprt_close()?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
