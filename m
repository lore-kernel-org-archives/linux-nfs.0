From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: exportfs -u hangs on SMP
Date: Tue, 29 Jul 2003 12:38:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16165.56876.172730.268520@gargle.gargle.HOWL>
References: <20030720103649.A20763@ikr.uni-stuttgart.de>
	<16155.8767.278825.712370@gargle.gargle.HOWL>
	<200307261255.29823.gemkow@ikr.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19hKO5-0003TI-00
	for <nfs@lists.sourceforge.net>; Mon, 28 Jul 2003 19:38:53 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <gemkow@ikr.uni-stuttgart.de>) (for <nfs@lists.sourceforge.net>)
	By note With Smtp ; Tue, 29 Jul 2003 12:38:36 +1000
To: Ulrich Gemkow <gemkow@ikr.uni-stuttgart.de>
In-Reply-To: message from Ulrich Gemkow on Saturday July 26
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

On Saturday July 26, gemkow@ikr.uni-stuttgart.de wrote:
> Hello Neil,
> 
> I tested the patch and our server survived for almost one week now - much
> longer than without the patch. So it seems the patch solves the problem
> and would be helpful in mainline too.

Thanks for letting me know.  The patch will be in 2.4.22

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
