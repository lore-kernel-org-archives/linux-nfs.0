From: Donavan Pantke <avatar@dcr.net>
Subject: Re: Problems with mounting NFS
Date: Tue, 21 Jan 2003 14:20:45 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200301211420.45694.avatar@dcr.net>
References: <7184.1043166875@www62.gmx.net>
Reply-To: avatar@dcr.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 216-7-67-178.ip.win.net ([216.7.67.178] helo=richard.dpapt.spellboundnet.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18b3uv-0007cc-00
	for <nfs@lists.sourceforge.net>; Tue, 21 Jan 2003 11:18:37 -0800
To: Daniel Koch <DanielKoch@gmx.net>, nfs@lists.sourceforge.net
In-Reply-To: <7184.1043166875@www62.gmx.net>
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

On Tuesday 21 January 2003 11:34, Daniel Koch wrote:
> Hi,
>
> I'm having problems with my NFS mounting at boottime. It takes about 8-=
10
> min to boot, and when I do dmesg I get the following message:
>
> nfs warning: mount version older than kernel
> portmap: server localhost not responding, timed out
> portmap: server localhost not responding, timed out
> lockd_up: makesock failed, error=3D-5
> portmap: server localhost not responding, timed out

=09This problem is because you don't have portmap running on the client. =
NFS=20
needs protmap running on both server and client, or you will see this=20
slownees, and probably other issues, most likely dealing with file lockin=
g.


>
> The problems occured after switching the client`s operating system from
> Whitedwarf Linux version 1.1 (kernel 2.2.14) to version 1.2 (kernel
> above). I`m a newbie to NFS, so I do apologize if this is a faq (I didn=
`t
> find a solution when I read the very good NFS manual here at sourceforg=
e).
> I'd appreciate any help.

=09The mount log entires dealing with versions probably have to do with t=
he=20
upgrade to 1.2 not putting an updated version of mount on the machine. I'=
m=20
not familiar with Whitedwarf, but if it uses a package management system =
of=20
any kind, check to make sure that the package that has the mount daemon i=
s=20
the version that came with 1.2.

=09Hope this helps!
=09Donavan Pantke


-------------------------------------------------------
This SF.net email is sponsored by: Scholarships for Techies!
Can't afford IT training? All 2003 ictp students receive scholarships.
Get hands-on training in Microsoft, Cisco, Sun, Linux/UNIX, and more.
www.ictp.com/training/sourceforge.asp
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
