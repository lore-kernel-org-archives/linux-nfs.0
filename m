From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: server still locks up
Date: Fri, 4 Jul 2003 16:21:33 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200307041621.33594.bernd-schubert@web.de>
References: <LIEOIFOFHAJEGKGKHBEJGEPLDAAA.justin_case@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
To: <justin_case@gmx.net>, <NFS@lists.sourceforge.net>
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

Hi,

perhaps you should mail some information about your hardware and your curre=
nt=20
kernel configuration, otherwise no one will ever have an idea whats wrong.

However, I think anyway we can give only general suggustions.  Usually lock=
ups=20
mean hardware problems and those are difficult to detect from software, but=
=20
based on my personal experience there are often based on memory problems, s=
o=20
first you should try to run a complete memtest86 test (say 'all tests' in t=
he=20
options). Next you could/should capture the output of your system via seria=
l=20
console, this should give you more information than the screen may give you=
=20
when your system crashes.

Hope it helps,
	Bernd


On Friday 04 July 2003 12:56, justin case wrote:
> hi again,
>
> i still couldn't solve the riddle of the freezing server. i transferred t=
he
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
> if nobody has a further idea how to track the error down i'll have to bui=
ld
> the whole machine from scratch :(
> at least i have now seen a working example so i know it would be worth the
> effort. what bothers me, though, is that i have only seen this technique =
of
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

=2D-=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
