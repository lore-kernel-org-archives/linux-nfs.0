From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: 2.4.20+NFS_ALL mount hanging, procs stuck in D state
Date: Thu, 16 Jan 2003 08:32:52 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.40.0301160821590.2908-100000@bolt.sonic.net>
References: <shshec9p7zs.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from a.smtp-out.sonic.net ([208.201.224.38])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ZCwn-0003Ls-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Jan 2003 08:32:53 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shshec9p7zs.fsf@charged.uio.no>
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

On 16 Jan 2003, Trond Myklebust wrote:
> I disagree: it looks like a hardware problem. From what I can see from
> your RPC dump, the NFS client is treating what it is getting from the
> server as if it were junk data. This is what I would expect to occur
> if the server and client RPC streams are getting desynchronized due to
> data corruption.

This machine has a long and faithful service record, although of course
that doesn't rule out hardware failure.

I can try to dig further into this process to find out exactly what is
triggering the hang. But, so you know, I switched the mount to UDP
(rw,udp,nfsvers=3,rsize=32768,wsize=32768,intr,hard) and now the process
completes normally.

Not being a kernel developer, I do wonder why a single piece of corrupted
data can have the effect of hanging the mount for all users and all
processes. It also creates an unkillable process, requiring the
machine to be rebooted, relating to the 'unmount -f' discussion that's
been going on here lately.

>
> Try using the eepro100 driver and/or a different card.

Swapping cards not so easy, this is a motherboard with built-in ethernet.
I can try the eepro100 driver though.


thanks,
andrew



-------------------------------------------------------
This SF.NET email is sponsored by: Thawte.com
Understand how to protect your customers personal information by implementing
SSL on your Apache Web Server. Click here to get our FREE Thawte Apache 
Guide: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0029en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
