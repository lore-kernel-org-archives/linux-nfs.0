From: "justin case" <justin_case@gmx.net>
Subject: server doesn't lock up anymore! (was: server still locks up)
Date: Sat, 12 Jul 2003 01:30:52 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <LIEOIFOFHAJEGKGKHBEJAEPKDGAA.justin_case@gmx.net>
References: <LIEOIFOFHAJEGKGKHBEJGEPLDAAA.justin_case@gmx.net>
Reply-To: <justin_case@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pop.gmx.net ([213.165.64.20] helo=mail.gmx.net)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19b7LR-0003vm-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 16:30:29 -0700
To: <nfs@lists.sourceforge.net>
In-Reply-To: <LIEOIFOFHAJEGKGKHBEJGEPLDAAA.justin_case@gmx.net>
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

argh!
after reinstalling the server, since i made the client work on a second
nfs-machine, it still did the nasty thing. i got pissed and made the ram
work a little slower in the bios and everything was fine.

i didn't think of that in the first place, because it worked for a couple of
days when i first installed it and quit duty after a week or so without me
even touching the bios.

strange but solved..

/jc

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net
> [mailto:nfs-admin@lists.sourceforge.net]On Behalf Of justin case
> Sent: Friday, July 04, 2003 12:57 PM
> To: NFS@lists.sourceforge.net
> Subject: [NFS] server still locks up
>
>
> hi again,
>
> i still couldn't solve the riddle of the freezing server. i
> transferred the
> shared directory and the according exports-entry to another machine and
> everything ran fine.
>
> i believe the trouble to be nfs-related, since besides that issue, the
> machine performs all tasks stable.
> i installed the latest version of nfs-tools - same problems.
>
> i built a new kernel again, checking all my options very carefully but no
> change.
> tcpdump >log didn't show any anomalies and the lines in the log repeated
> themselves until the last line was cut of before ended, so also here no
> usefull information.
>
> if nobody has a further idea how to track the error down i'll
> have to build
> the whole machine from scratch :(
> at least i have now seen a working example so i know it would be worth the
> effort. what bothers me, though, is that i have only seen this
> technique of
> eliminating an error with windows so far.
>
> regards,
> /jc
>
>
> -------------------------------------------------------
> This SF.Net email sponsored by: Free pre-built ASP.NET sites including
> Data Reports, E-commerce, Portals, and Forums are available now.
> Download today and enter to win an XBOX or Visual Studio .NET.
> http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>



-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
