From: Greg Lindahl <lindahl@keyresearch.com>
Subject: Re: nfs over TCP stable?
Date: Sat, 3 May 2003 16:29:41 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030503232941.GB4957@greglaptop.attbi.com>
References: <3EB44527.6090005@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 12-234-18-241.client.attbi.com ([12.234.18.241] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19C6SX-0001bT-00
	for <nfs@lists.sourceforge.net>; Sat, 03 May 2003 16:30:25 -0700
Received: from localhost.localdomain (greglaptop [127.0.0.1])
	by localhost.localdomain (8.12.8/8.12.5) with ESMTP id h43NTq37005091
	for <nfs@lists.sourceforge.net>; Sat, 3 May 2003 16:29:53 -0700
Received: (from lindahl@localhost)
	by localhost.localdomain (8.12.8/8.12.8/Submit) id h43NTfn3005089
	for nfs@lists.sourceforge.net; Sat, 3 May 2003 16:29:41 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <3EB44527.6090005@wanadoo.es>
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

On Sun, May 04, 2003 at 12:39:35AM +0200, Xose Vazquez Perez wrote:

> Red Hat 9-kernel 2.4.20-9 doesn't include nfs over TCP because they
> said that "it doesn't work good enough in our testing....."
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=88583

Note that they are talking about CONFIG_NFSD_TCP, i.e. the daemon side
of TCP support. Client support is much older, and Redhat has had it
turned on for ages.

greg




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
