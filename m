From: trond.myklebust@fys.uio.no
Subject: Re: task->tk_timeout = 0
Date: Thu, 26 Feb 2004 13:50:12 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <32895.207.214.87.84.1077799812.squirrel@webmail.uio.no>
References: <20040226110802.GE1197@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwKzx-0003aB-N8
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 04:52:17 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AwKy9-0006DV-7a
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 04:50:25 -0800
To: "Olaf Kirch" <okir@suse.de>
In-Reply-To: <20040226110802.GE1197@suse.de>
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

På to , 26/02/2004 klokka 03:08, skreiv Olaf Kirch:
> So apparently one of the shift operations above overflows.  I suspect
rpc_ntimeo because it can be arbitrarily large. But the ntimeouts value
isn't updated until we've received a reply (is this intentional, Trond?)
>
> So what would have to happen for this bug to trigger is
>
> 	send request
> 	server hangs
> 	retransmit request 1000 times
> 	server comes back
> 	retransmit request
> 	receive reply, set ntimeout = 1000
>
> 	send another request. timeout overflows and becomes 0
> 	request gets lost
> 	task waits indefinitely.
>
> I think the most robust way to fix this is simply this:
>
> 		- req->rq_timeout.to_retries;
> 	if (timeout > req->rq_timeout.to_maxval)
> 		timeout = req->rq_timeout.to_maxval;
> -	if (timeout > req->rq_timeout.to_maxval)
> +	if (!timeout || timeout > req->rq_timeout.to_maxval)
> 		timeout = req->rq_timeout.to_maxval;
>
> It may also make sense to clamp the ntimeouts value to something
reasonable (e.g. 8)

Agreed, and in fact, I believe at some point it was clamped to 8.
Thanks, and well spotted...

Cheers,
  Trond





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
