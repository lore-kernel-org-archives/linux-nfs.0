From: "Gareth" <gareth@bim7.com>
Subject: RE: Premission denied
Date: Wed, 29 Oct 2003 22:46:18 -0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <HPEELKALMOKIEBNDKBCCAEDJDGAA.gareth@bim7.com>
References: <20031029215815.GO29526@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Chip Salzenberg" <chip@pobox.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AEz56-0003uk-00
	for <nfs@lists.sourceforge.net>; Wed, 29 Oct 2003 14:46:24 -0800
Received: from bim7dsl.plus.com ([81.174.146.28] helo=mailgate.bim7.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AEz56-0001Kw-3j
	for nfs@lists.sourceforge.net; Wed, 29 Oct 2003 14:46:24 -0800
To: <nfs@lists.sourceforge.net>
In-Reply-To: <20031029215815.GO29526@perlsupport.com>
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

> -----Original Message-----
> From: Chip Salzenberg
> > Oct 29 09:25:44 paris rpc.mountd: Fake hostname paris.bim for
> 192.168.17.4
> > - forward lookup doesn't match reverse
> > Oct 29 09:25:44 paris rpc.mountd: refused mount request from
> 192.168.17.4
> > for /nfsroot (/): no export entry
> > Oct 29 09:29:09 paris rpc.mountd: export request from 127.0.0.1
> > Oct 29 09:39:37 paris rpc.mountd: refused mount request from
> paris.bim for
> > /nfsroot (/): no export entry
>
> You have two failures there.  One says DNS, the other doesn't.
>
> > Someone at work suggested its a reverse DNS problem... but running
> > nslookup hostname returns my IP address, and vice versa.
>
> The log says there was a reverse DNS problem.  It says it clearly,
> right there in the log.  Are you suggesting that it's lying?

LOL! Of course I'm not saying its lying...LOL

I read the log file too... but I'm not sure why the error is there, given a
reverse lookup works fine. It's also the first time the error appeared,
despite hours of testing - and it hasn't reappeared since.


Gareth



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
