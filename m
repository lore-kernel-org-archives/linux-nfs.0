From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: flock LOCK_EX hangs
Date: Wed, 16 May 2007 13:30:08 -0400
Message-ID: <20070516173008.GD9895@fieldses.org>
References: <20070516131253.GC19167@radix50.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Baurzhan Ismagulov <ibr@radix50.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoNKG-0005vo-Ql
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 10:30:13 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HoNKI-000520-CL
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 10:30:15 -0700
In-Reply-To: <20070516131253.GC19167@radix50.net>
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

On Wed, May 16, 2007 at 03:12:53PM +0200, Baurzhan Ismagulov wrote:
> I'm experiencing problems with the kernel NFS server. The client hangs
> on the flock call. This is Debian etch, Linux 2.6.16-1-686-smp, the
> server and the client is the same machine. The directory is exported
> with rw, no mount options. The lockd kernel thread is present, rpcinfo
> -p reports nlockmgr registered, the firewall passes all the traffic
> through.
> 
> I've googled and searched the list archive, the postings are usually
> quite old (only two were from 2006 and referred to Linux 2.6), and I
> couldn't see how I could further analyze the problem. I've also tried
> mounting with nolock, but this apparently makes flock / fcntl to fail,
> since the tools I use (automake and debootstrap, although I checked this
> only with the latter) exited with an error code, and I rely upon it.

Might be fun to watch the network traffic as this is happening.  I'd
probably do something like

	wireshark -Slk -ilo

then try to get a lock, and try to understand what's happening on the
"network": is the client sending requests that the server doesn't
answer?  Or are there errors coming back?  Etc.

Or you could run

	tcpdump -s0 -ilo -wtmp.pcap

and mail a copy of tmp.pcap and somebody could take a look.

There's also been a lot fixed since 2.6.16, so it might be worth trying
something newer.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
