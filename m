From: Olaf Kirch <okir@suse.de>
Subject: task->tk_timeout = 0
Date: Thu, 26 Feb 2004 12:08:02 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040226110802.GE1197@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwJOt-0006B4-KT
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 03:09:55 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AwJN7-0000pP-GW
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 03:08:05 -0800
Received: from hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 08C9B249313
	for <nfs@lists.sourceforge.net>; Thu, 26 Feb 2004 12:08:03 +0100 (CET)
To: nfs@lists.sourceforge.net
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

Hi all,

I've been debugging mysterious hangs in the NFS clients for a while
now. The symptoms were always the same: NFS server goes away, comes back
after a long time, but the mount point remains stuck.

When inspecting the list of RPC tasks, I often found that one process
was on the pending queue (i.e. waiting for a reply) but task->tk_timeout
was 0.

I added a couple of diagnostic printks, and one of them triggered
yesterday, pointing to this piece of code in xprt_transmit:

if (!xprt->nocong) {
	int timer = task->tk_msg.rpc_proc->p_timer;
	timeout = rpc_calc_rto(clnt->cl_rtt, timer);
	timeout <<= rpc_ntimeo(clnt->cl_rtt, timer);
	timeout <<= clnt->cl_timeout.to_retries
		- req->rq_timeout.to_retries;
	if (timeout > req->rq_timeout.to_maxval)
		timeout = req->rq_timeout.to_maxval;
	else if (timeout == 0) {
		printk(KERN_ERR "RPC task timeout == 0, please tell okir\n");
		timeout = req->rq_timeout.to_maxval;
	}
	...
}

So apparently one of the shift operations above overflows.  I suspect
rpc_ntimeo because it can be arbitrarily large. But the ntimeouts value
isn't updated until we've received a reply (is this intentional, Trond?)

So what would have to happen for this bug to trigger is

	send request
	server hangs
	retransmit request 1000 times
	server comes back
	retransmit request
	receive reply, set ntimeout = 1000

	send another request. timeout overflows and becomes 0
	request gets lost
	task waits indefinitely.

I think the most robust way to fix this is simply this:

		- req->rq_timeout.to_retries;
	if (timeout > req->rq_timeout.to_maxval)
		timeout = req->rq_timeout.to_maxval;
-	if (timeout > req->rq_timeout.to_maxval)
+	if (!timeout || timeout > req->rq_timeout.to_maxval)
		timeout = req->rq_timeout.to_maxval;

It may also make sense to clamp the ntimeouts value to something
reasonable (e.g. 8)

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
