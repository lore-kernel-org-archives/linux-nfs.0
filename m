From: "justin case" <justin_case@gmx.net>
Subject: server locks up totally
Date: Tue, 1 Jul 2003 00:07:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <LIEOIFOFHAJEGKGKHBEJMEJKDAAA.justin_case@gmx.net>
Reply-To: <justin_case@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.gmx.de ([213.165.64.20] helo=mail.gmx.net)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19X6nL-0006hk-00
	for <nfs@lists.sourceforge.net>; Mon, 30 Jun 2003 15:06:43 -0700
To: <nfs@lists.sourceforge.net>
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

hi,

i build up a diskless-system  using etherboot and root on an nfs-share. both
systems are redhat9 with 2.4.20 kernels.

so far everything works well now but strangely the nfs-server tends to lock
up out of the blue. this is not reconstructable and just happens sooner or
later.

since it always locks up the entire machine(!) i can't get any error-message
and slowly i am a little desperate here..

i don't use any automouter and my /etc/exports file only contains:

tftpboot/gate01 192.168.1.20(rw,no_root_squash)

i can reboot the server and the client starts working again the second the
nfs-share is available again, so the client-side seems to be ok.

sorry for coming up with such little info  :(
hopefully anybody has an idea..

my regards
/jc



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
