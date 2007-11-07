From: Neil Brown <neilb@suse.de>
Subject: Re: odd kernel-nfs-server messages
Date: Wed, 7 Nov 2007 15:56:44 +1100
Message-ID: <18225.17804.342785.5822@notabene.brown>
References: <87fxzi1y9m.fsf@mcs.anl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Narayan Desai <desai@mcs.anl.gov>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpcyE-0000Eb-9b
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 20:56:54 -0800
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IpcyG-0006RH-MB
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 20:57:00 -0800
In-Reply-To: message from Narayan Desai on Tuesday November 6
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

On Tuesday November 6, desai@mcs.anl.gov wrote:
> We are running into some kernel nfs server errors that we are having
> trouble deciphering. 
> 
> We are running a x86_64 nfs server. The server is running ubuntu
> feisty, with their 2.6.20-16-generic kernel. 
> 
> The clients are also running linux (2.6.15 kernel; we are waiting on
> the system vendor to finish their port to a newer kernel) on mips64. 

This looks a lot like the bug fixed by commit

   e0ab53deaa91293a7958d63d5a2cf4c5645ad6f0

which was still present in 2.6.15 (fix in 2.6.18).

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=e0ab53deaa91293a7958d63d5a2cf4c5645ad6f0


If the client gets an error sending data (because there is no buffer
space), the remainder of the packet is discard, but it keeps the same
tcp connection open.  When it sends another packet, presumably when
buffer space is available, it gets sent and appears to be part of the
previous packet.  Confusion ensues.

NeilBrown


> 
> Under fairly heavy load (400-800 clients, not a ton of reads and
> writes) we get the following messages:
> 
> [1724467.119033] RPC: bad TCP reclen 0x337e08af (large)
> [1738771.833213] RPC: bad TCP reclen 0x00000014 (non-terminal)
> [1738801.224098] RPC: bad TCP reclen 0x6d346e31 (non-terminal)
> [1738965.738860] RPC: bad TCP reclen 0x6d376e39 (non-terminal)
> [1739183.459936] RPC: bad TCP reclen 0x342e7363 (non-terminal)
> [1739295.006403] RPC: bad TCP reclen 0x73797374 (non-terminal)
> [1739383.784788] RPC: bad TCP reclen 0x00000003 (non-terminal)

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
