From: "justin case" <justin_case@gmx.net>
Subject: server still locks up
Date: Fri, 4 Jul 2003 12:56:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <LIEOIFOFHAJEGKGKHBEJGEPLDAAA.justin_case@gmx.net>
Reply-To: <justin_case@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
To: <NFS@lists.sourceforge.net>
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

hi again,

i still couldn't solve the riddle of the freezing server. i transferred the
shared directory and the according exports-entry to another machine and
everything ran fine.

i believe the trouble to be nfs-related, since besides that issue, the
machine performs all tasks stable.
i installed the latest version of nfs-tools - same problems.

i built a new kernel again, checking all my options very carefully but no
change.
tcpdump >log didn't show any anomalies and the lines in the log repeated
themselves until the last line was cut of before ended, so also here no
usefull information.

if nobody has a further idea how to track the error down i'll have to build
the whole machine from scratch :(
at least i have now seen a working example so i know it would be worth the
effort. what bothers me, though, is that i have only seen this technique of
eliminating an error with windows so far.

regards,
/jc


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
