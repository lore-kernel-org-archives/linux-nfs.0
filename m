From: Paul Heinlein <heinlein@cse.ogi.edu>
Subject: Re: Strange serialisation with slow operations?
Date: Thu, 25 Sep 2003 07:25:48 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0309250723030.25332@glenfiddich.cse.ogi.edu>
References: <E1A2TyP-0005nb-0b@anchor-post-37.mail.demon.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2X4C-00064w-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 07:26:00 -0700
Received: from franklin.cse.ogi.edu ([129.95.40.9])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A2X4A-0000h6-Sf
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 07:25:58 -0700
To: jrc@skylon.demon.co.uk
In-Reply-To: <E1A2TyP-0005nb-0b@anchor-post-37.mail.demon.net>
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

On Thu, 25 Sep 2003 jrc@skylon.demon.co.uk wrote:

> If there is any further information I can supply to diagnose this,
> please let me know ...

The two standard tools (and forgive me if I repeating something you've
already tried) would be strace and tcpdump. The former would see which
system call is the sore spot, the latter would trace the network
traffic between client and server.

--Paul Heinlein <heinlein@cse.ogi.edu>


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
