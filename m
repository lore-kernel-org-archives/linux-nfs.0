From: Chip Salzenberg <chip@pobox.com>
Subject: Re: Premission denied
Date: Wed, 29 Oct 2003 16:58:16 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031029215815.GO29526@perlsupport.com>
References: <10334.62.49.205.2.1067421598.squirrel@squirrelmail.bim7.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AEyKR-00021b-00
	for <nfs@lists.sourceforge.net>; Wed, 29 Oct 2003 13:58:11 -0800
Received: from topaz.cx
	([66.220.6.227] helo=mail.topaz.cx ident=mail)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AEyKJ-0002hm-RD
	for nfs@lists.sourceforge.net; Wed, 29 Oct 2003 13:58:03 -0800
To: Gareth <gareth@bim7.com>
In-Reply-To: <10334.62.49.205.2.1067421598.squirrel@squirrelmail.bim7.com>
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

According to Gareth:
> Oct 29 09:25:44 paris rpc.mountd: Fake hostname paris.bim for 192.168.17.4
> - forward lookup doesn't match reverse
> Oct 29 09:25:44 paris rpc.mountd: refused mount request from 192.168.17.4
> for /nfsroot (/): no export entry
> Oct 29 09:29:09 paris rpc.mountd: export request from 127.0.0.1
> Oct 29 09:39:37 paris rpc.mountd: refused mount request from paris.bim for
> /nfsroot (/): no export entry

You have two failures there.  One says DNS, the other doesn't.

> Someone at work suggested its a reverse DNS problem... but running
> nslookup hostname returns my IP address, and vice versa.

The log says there was a reverse DNS problem.  It says it clearly,
right there in the log.  Are you suggesting that it's lying?

"The error message!  Read the error message!"
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
