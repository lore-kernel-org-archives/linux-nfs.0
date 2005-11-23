From: Neil Brown <neilb@suse.de>
Subject: Re: [Fwd: [Bug 5644] New: NFS v3 TCP 3-way handshake incorrect,
 iptables blocks access]
Date: Thu, 24 Nov 2005 10:02:22 +1100
Message-ID: <17284.62718.419018.74952@cse.unsw.edu.au>
References: <1132767731.8016.24.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, Andrew Morton <akpm@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ef3dR-0004mk-Ah
	for nfs@lists.sourceforge.net; Wed, 23 Nov 2005 15:02:41 -0800
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Ef3dO-0006uL-RX
	for nfs@lists.sourceforge.net; Wed, 23 Nov 2005 15:02:41 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Wednesday November 23
Sender: nfs-admin@lists.sourceforge.net
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

On Wednesday November 23, trond.myklebust@fys.uio.no wrote:
> Neil,
> 
>   Can you see any reason why I shouldn't shunt this bug over to the
> networking folks?

No...
We have a similar report in the Novell bugzilla

  https://bugzilla.novell.com/show_bug.cgi?id=104379
(I think that should be public, but I'm not certain).
which suggests it has been around for a while in possibly different
forms and at least some forms have been fixed.  Apparently not all. 
It some sort of problem with the conntrack module.

I would ask for a tcpdump and reassign it to iptables.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
