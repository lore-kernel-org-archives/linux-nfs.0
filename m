From: Greg Lindahl <lindahl@keyresearch.com>
Subject: Re: Retransmissions over TCP ...
Date: Fri, 19 Sep 2003 15:43:56 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030919224356.GB5027@greglaptop.internal.keyresearch.com>
References: <20030910200444.49715.qmail@web21104.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A0Uix-0005ob-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Sep 2003 16:31:39 -0700
Received: from 64.221.211.207.ptr.us.xo.net ([64.221.211.207] helo=localhost.localdomain)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.22)
	id 1A0Uiw-0001LQ-OY
	for nfs@lists.sourceforge.net; Fri, 19 Sep 2003 16:31:38 -0700
Received: from localhost.localdomain (greglaptop [127.0.0.1])
	by localhost.localdomain (8.12.8/8.12.5) with ESMTP id h8JMhuor005135
	for <nfs@lists.sourceforge.net>; Fri, 19 Sep 2003 15:43:56 -0700
Received: (from lindahl@localhost)
	by localhost.localdomain (8.12.8/8.12.8/Submit) id h8JMhuAZ005133
	for nfs@lists.sourceforge.net; Fri, 19 Sep 2003 15:43:56 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20030910200444.49715.qmail@web21104.mail.yahoo.com>
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

On Wed, Sep 10, 2003 at 09:04:44PM +0100, Amey Inamdar wrote:

>     I could not understand why does RPC layer
> underneath NFS client retransmit the request while
> using NFS over TCP. TCP does reliable delivery of RPC,
> ain't it?  Is it because NFS server may drop the
> requests/connection at its end?

In addition to trond's answer, note that when a TCP stream fails, you
have no idea how much information was lost. The acks and retransmits
allow the client to simply re-open the TCP connection, and no
transactions get lost.

-- greg





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
