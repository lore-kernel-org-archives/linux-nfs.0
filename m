From: Olaf Kirch <okir@suse.de>
Subject: Re: NSM lock recovery fails too often
Date: Tue, 9 Mar 2004 15:22:00 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040309142200.GC14419@suse.de>
References: <482A3FA0050D21419C269D13989C61130435DD1F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0iGE-0004li-BU
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 06:31:10 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B0i7O-0002TE-TW
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 06:22:03 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DD1F@lavender-fe.eng.netapp.com>
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

On Tue, Mar 09, 2004 at 06:15:13AM -0800, Lever, Charles wrote:
> i thought the purpose of moving NSM into the kernel was
> to eliminate the need for any user-level programs because
> sometimes they don't get run at reboot..?

Yes and no. I think there's a difference security wise between starting
an RPC service by default (such as statd) vs running a small utility
that sends out NSM notifications and exits when it's done.

I also think these RPC upcalls from kernel to user land are awfully ugly,
and the entire NSM protocol is completely overengineered. For a kernel
statd, all you need is the NULL procedure and the ability to process
SM_NOTIFY messages. The rest is simply not implemented.

> how does your recovery program handle this case?

It's fairly stubborn. As long as it can open a socket, it will retry
notification for as long as you tell it to (15 minutes by default,
but you can change that)

I forgot to mention in my previous message that the kernel-statd patch
requires Andreas Gruenbacher's sunrpc patch that lets you register
several RPC services on a single socket (originally written for his
nfsacl implementation)

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
