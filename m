From: jrc@skylon.demon.co.uk
Subject: Re: Re; Strange serialisation with slow operations?
Date: Fri, 26 Sep 2003 12:14:24 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1A2qYK-000GQE-0V@anchor-post-31.mail.demon.net>
References: <E1A2ovU-0005yN-0b@anchor-post-37.mail.demon.net>
Reply-To: jrc@skylon.demon.co.uk
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2qYM-0004Xb-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Sep 2003 04:14:26 -0700
Received: from anchor-post-31.mail.demon.net ([194.217.242.89])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2qYL-0007pI-Vt
	for nfs@lists.sourceforge.net; Fri, 26 Sep 2003 04:14:26 -0700
To: jrc@skylon.demon.co.uk
In-Reply-To: <E1A2ovU-0005yN-0b@anchor-post-37.mail.demon.net>
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

jrc@skylon.demon.co.uk wrote:
> This suggests to me that perhaps the blocking is occuring at the UDP
> level.  Any comments?

Tried a similar test using the NFS client from Microsoft Services for
UNIX 3.0 running on Windows 2000 SP2.

The first few attempts to "type a" produced "The semaphore timeout
period has expired." and no output.  However, once it had settled
down, "type a" produced output after the expected delay without
blocking "type f".  Ethereal showed that the read requests were going
over the wire and that both used UDP ports 1024;948.

This seems to cast doubt on my sugguestion that the blocking was
occuring at the UDP level ...
--
John Connett



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
