From: Ion Badulescu <ionut@badula.org>
Subject: Re: nfsd tuning - please help me!
Date: Fri, 14 Feb 2003 15:32:12 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200302142032.h1EKWCIJ006931@buggy.badula.org>
References: <20030214174453.11719.qmail@web12201.mail.yahoo.com>
Cc: Steve Dickson <SteveD@RedHat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ool-4351594a.dyn.optonline.net ([67.81.89.74] helo=badula.org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18jmVa-0003tR-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Feb 2003 12:32:30 -0800
To: Alan Powell <lakerfaniam2@yahoo.com>
In-Reply-To: <20030214174453.11719.qmail@web12201.mail.yahoo.com>
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

On Fri, 14 Feb 2003 09:44:53 -0800 (PST), Alan Powell <lakerfaniam2@yahoo.com> wrote:
> Unfortunately, we've tried all that already. So given
> that we are not hardware/network constrained, does all
> this mean that the Linux kernel NFS runs into
> performance issues beyond 100 file reads/sec?

It's quite possible...

What I'd recommend, however, is testing this again with a non-RedHat
kernel on the client. More precisely, try running 2.4.20 plus the 
NFSALL patch from Trond's site <http://www.fys.uio.no/~trondmy/src/>.

We've had significant performance problems over here with the RedHat
kernels, which mostly went away when we replaced the NFS client code
with 2.4.20+NFSALL.

Hope this helps,
Ion

-- 
  It is better to keep your mouth shut and be thought a fool,
            than to open it and remove all doubt.


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
