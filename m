From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: exportfs -u hangs on SMP
Date: Wed, 30 Jul 2003 14:10:48 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16167.17736.294132.302966@gargle.gargle.HOWL>
References: <20030720103649.A20763@ikr.uni-stuttgart.de>
	<200307261255.29823.gemkow@ikr.uni-stuttgart.de>
	<16165.56876.172730.268520@gargle.gargle.HOWL>
	<200307291727.24587.avatar@dcr.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ulrich Gemkow <gemkow@ikr.uni-stuttgart.de>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19hiIo-0006k0-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Jul 2003 21:11:03 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <avatar@dcr.net>) (for <gemkow@ikr.uni-stuttgart.de>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Wed, 30 Jul 2003 14:10:48 +1000
To: avatar@dcr.net
In-Reply-To: message from Donavan Pantke on Tuesday July 29
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

On Tuesday July 29, avatar@dcr.net wrote:
> 	WE've been seeing similar wierd locking problems (nfsd gets in a DW state), 
> and this may or may not be linked. When would this section of code get 
> executed? Only by exportfs, or could there be other times this may occur?

The section of code gets run whenever /proc/fs/nfs/exports is
accessed.
The only standard program that accesses this that I know of if
exportfs.   Ofcourse a script could equally easily access it.

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
