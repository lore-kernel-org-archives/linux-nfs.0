From: Olaf Kirch <okir@suse.de>
Subject: Re: 2.6.5-pre TCP connect problems
Date: Mon, 29 Mar 2004 17:28:01 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040329152801.GB19311@suse.de>
References: <20040329135042.GG2992@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B7ygG-00036L-J1
	for nfs@lists.sourceforge.net; Mon, 29 Mar 2004 07:28:04 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B7ygF-00068S-LW
	for nfs@lists.sourceforge.net; Mon, 29 Mar 2004 07:28:04 -0800
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id ECE9239EF9E
	for <nfs@lists.sourceforge.net>; Mon, 29 Mar 2004 17:28:01 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20040329135042.GG2992@suse.de>
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

On Mon, Mar 29, 2004 at 03:50:42PM +0200, Olaf Kirch wrote:
> I'm currently debugging a problem with TCP reconnects in 2.6.5-pre where
> the TCP reconnect code got rewritten to use worker queues.  What happens
> is that the NFS server drops the connection immediately and that state
> change isn't propagated to the transport.

I debugged this a little more. The problem I'be been seeing was
caused by too many TCP connections. The NFS server was dropping
connections randomly. Randomly means that the newest connection
will be dropped with a probability of 50%, so that the connection
dies before the client has sent the first packet. This causes
the client to back off for 60 seconds.

I'm not sure why this effect wasn't visible with 2.6.4, but it
seems it used a lower timeout (REESTABLISH_TIMEOUT = 15sec)
when the connection was refused or dropped instantly, and may
have been less noticeable therefore.

I'm not sure if it's a good idea to be more aggressive about
reconnecting, but I think the client should at least log
a message to syslog that a connection attempt failed. Likewise,
the server should probably log a message when it finds it's
dropping too many TCP connections.

Finally, I think the way nfsd drops connections is bad. Dropping
the most recent connection doesn't prevent DoS, and as this example
demonstrates, it does unexpected things to your clients.

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
