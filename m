From: Donavan Pantke <avatar@dcr.net>
Subject: Re: exportfs -u hangs on SMP
Date: Tue, 29 Jul 2003 17:27:24 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200307291727.24587.avatar@dcr.net>
References: <20030720103649.A20763@ikr.uni-stuttgart.de> <200307261255.29823.gemkow@ikr.uni-stuttgart.de> <16165.56876.172730.268520@gargle.gargle.HOWL>
Reply-To: avatar@dcr.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 216-7-67-178.ip.win.net ([216.7.67.178] helo=richard.dpapt.spellboundnet.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19hc0G-0001Z3-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Jul 2003 14:27:28 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>,
	Ulrich Gemkow <gemkow@ikr.uni-stuttgart.de>
In-Reply-To: <16165.56876.172730.268520@gargle.gargle.HOWL>
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

	WE've been seeing similar wierd locking problems (nfsd gets in a DW state), 
and this may or may not be linked. When would this section of code get 
executed? Only by exportfs, or could there be other times this may occur?

	Thanks!
	Donavan Pantke
	Network Engineer
	Appriss, Inc.


On Monday 28 July 2003 22:38, Neil Brown wrote:
> On Saturday July 26, gemkow@ikr.uni-stuttgart.de wrote:
> > Hello Neil,
> >
> > I tested the patch and our server survived for almost one week now - much
> > longer than without the patch. So it seems the patch solves the problem
> > and would be helpful in mainline too.
>
> Thanks for letting me know.  The patch will be in 2.4.22
>
> NeilBrown
>
>
> -------------------------------------------------------
> This SF.Net email sponsored by: Free pre-built ASP.NET sites including
> Data Reports, E-commerce, Portals, and Forums are available now.
> Download today and enter to win an XBOX or Visual Studio .NET.
> http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
