From: Chip Salzenberg <chip@pobox.com>
Subject: Debian Bug#203077: Locks not released on NFS client reboot
Date: Sun, 27 Jul 2003 12:31:24 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030727163124.GC19877@perlsupport.com>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19goRD-0003dm-00
	for <nfs@lists.sourceforge.net>; Sun, 27 Jul 2003 09:31:59 -0700
Received: from node-423a4e3a.pne.onnet.us.uu.net ([66.58.78.58] helo=tytlal)
	by tandu.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 19goQf-0001Ug-00
	for <nfs@lists.sourceforge.net>; Sun, 27 Jul 2003 09:31:25 -0700
Received: from chip by tytlal with local (Exim 3.35 #1 (Debian))
	id 19goQe-0007aX-00
	for <nfs@lists.sourceforge.net>; Sun, 27 Jul 2003 12:31:24 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
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

I confess I don't quite understand this bug report.  Is this person
asking for something that NFS can't do, or is there perhaps some error
in configuration ... ?

Please advise.

The report is again Debian stable (woody), which uses nfs-utils 1.02.

According to Nick Nassar:
> File locks on NFS clients are not released on reboot. When machines shut
> down unexpectedly for whatever reason, the locks stay there with no
> apparent way to clear them except restarting NFS on the server.
> 
> See "I'm having a lock file problem. What do I do?" in
> http://www.gnome.org/projects/gconf/ for an example of the kind of problem
> caused by this.
> 
> The machine that I'm specifically having the trouble with is using a stock
> 2.4.20 kernel that I compiled from source.


-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
