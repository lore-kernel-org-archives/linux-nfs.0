From: Ramon van Alteren <ramon@vanalteren.nl>
Subject: Re: nfs over 2tb limitation
Date: Fri, 7 Apr 2006 09:45:28 +0200
Message-ID: <CFE76CD0-194C-477D-8865-80F13BBB1854@vanalteren.nl>
References: <E80C016468F5454E93FBC2FBF2F93AE47FB4F6@EINSTEIN.idg.idgrup.com>
Mime-Version: 1.0 (Apple Message framework v749.3)
Content-Type: multipart/alternative; boundary=Apple-Mail-2-732488020
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FRlex-0002c7-Rl
	for nfs@lists.sourceforge.net; Fri, 07 Apr 2006 00:45:35 -0700
Received: from cust.92.104.adsl.cistron.nl ([195.64.92.104] helo=router.forgottenland.net)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FRlex-0007Sx-Cn
	for nfs@lists.sourceforge.net; Fri, 07 Apr 2006 00:45:36 -0700
In-Reply-To: <E80C016468F5454E93FBC2FBF2F93AE47FB4F6@EINSTEIN.idg.idgrup.com>
To: Julio Prada <julio.prada@idgrup.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--Apple-Mail-2-732488020
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=WINDOWS-1252;
	delsp=yes;
	format=flowed

See below for output from a 32-bit nfs client to our 9Tb NAS.

10.10.0.80:/data/MEDIA
                       9.0T  5.5T  3.6T  62% /mnt/spinvis
# 09:43:07 > uname -a
Linux 2.6.12-gentoo-r6 #1 SMP Mon Oct 24 13:16:38 CEST 2005 i686 Intel=20=

(R) Pentium(R) 4 CPU 3.00GHz GenuineIntel GNU/Linux

Does that answer your question ?

Regards,

Ramon

On 7 Apr , 2006, at 9:34 AM, Julio Prada wrote:

> The scenario is a Hp clustered gateway that theorically can =20
> virtualize up to 16TB, and it seems that the limitation it=92s on NFS =20=

> client that only can reach up to 2TB on large filesystems.
>
> Please, could you confirm whether nfs client cannot see more than 2 =20=

> TB file systems?
>
> There is any workaround?

--
Change what you're saying,
Don't change what you said

The Eels




--Apple-Mail-2-732488020
Content-Transfer-Encoding: quoted-printable
Content-Type: text/html;
	charset=WINDOWS-1252

<HTML><BODY style=3D"word-wrap: break-word; -khtml-nbsp-mode: space; =
-khtml-line-break: after-white-space; "><DIV>See below for output from a =
32-bit nfs client to our 9Tb NAS.</DIV><DIV><BR =
class=3D"khtml-block-placeholder"></DIV><DIV>10.10.0.80:/data/MEDIA</DIV><=
DIV>=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 9.0T=A0 5.5T=A0 3.6T=A0 =
62% /mnt/spinvis</DIV><DIV># 09:43:07 &gt; uname -a</DIV><DIV>Linux =
2.6.12-gentoo-r6 #1 SMP Mon Oct 24 13:16:38 CEST 2005 i686 Intel(R) =
Pentium(R) 4 CPU 3.00GHz GenuineIntel GNU/Linux</DIV><DIV><BR =
class=3D"khtml-block-placeholder"></DIV><DIV>Does that answer your =
question ?</DIV><DIV><BR =
class=3D"khtml-block-placeholder"></DIV><DIV>Regards,</DIV><DIV><BR =
class=3D"khtml-block-placeholder"></DIV><DIV>Ramon</DIV><BR><DIV><DIV>On =
7 Apr , 2006, at 9:34 AM, Julio Prada wrote:</DIV><BR =
class=3D"Apple-interchange-newline"><BLOCKQUOTE type=3D"cite"><SPAN =
class=3D"Apple-style-span" style=3D"border-collapse: separate; =
border-spacing: 0px 0px; color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant: normal; font-weight: =
normal; letter-spacing: normal; line-height: normal; text-align: auto; =
-khtml-text-decorations-in-effect: none; text-indent: 0px; =
-apple-text-size-adjust: auto; text-transform: none; orphans: 2; =
white-space: normal; widows: 2; word-spacing: 0px; "><DIV =
class=3D"Section1"><P class=3D"MsoNormal"><FONT size=3D"2" =
face=3D"Arial"><SPAN style=3D"font-size:10.0pt; font-family:Arial; =
font-size: 13.3333px; "><SPAN class=3D"Apple-style-span" =
style=3D"font-family: Arial; font-size: 13.3333px; ">The scenario is a =
Hp clustered gateway that theorically can virtualize up to 16TB, and it =
seems that the limitation it=92s on NFS client that only can reach up to =
2TB on large filesystems.</SPAN><O:P style=3D"font-family: Arial; =
font-size: 13.3333px; "></O:P></SPAN></FONT></P><P =
class=3D"MsoNormal"><FONT size=3D"2" face=3D"Arial"><SPAN =
style=3D"font-size:10.0pt; font-family:Arial; font-size: 13.3333px; =
"><SPAN class=3D"Apple-style-span" style=3D"font-family: Arial; =
font-size: 13.3333px; ">Please, could you confirm whether nfs client =
cannot see more than 2 TB file systems?</SPAN><O:P style=3D"font-family: =
Arial; font-size: 13.3333px; "></O:P></SPAN></FONT></P><P =
class=3D"MsoNormal"><FONT size=3D"2" face=3D"Arial"><SPAN =
style=3D"font-size:10.0pt; font-family:Arial; font-size: 13.3333px; =
"><SPAN class=3D"Apple-style-span" style=3D"font-family: Arial; =
font-size: 13.3333px; ">There is any workaround?</SPAN><O:P =
style=3D"font-family: Arial; font-size: 13.3333px; =
"></O:P></SPAN></FONT></P></DIV></SPAN></BLOCKQUOTE></DIV><BR><DIV> =
<SPAN class=3D"Apple-style-span" style=3D"border-collapse: separate; =
border-spacing: 0px 0px; color: rgb(0, 0, 0); font-family: Helvetica; =
font-size: 12px; font-style: normal; font-variant: normal; font-weight: =
normal; letter-spacing: normal; line-height: normal; text-align: auto; =
-khtml-text-decorations-in-effect: none; text-indent: 0px; =
-apple-text-size-adjust: auto; text-transform: none; orphans: 2; =
white-space: normal; widows: 2; word-spacing: 0px; =
"><DIV>--</DIV><DIV>Change what you're saying,</DIV><DIV>Don't change =
what you said</DIV><DIV><BR =
class=3D"khtml-block-placeholder"></DIV><DIV>The Eels</DIV><DIV><BR =
class=3D"khtml-block-placeholder"></DIV><BR =
class=3D"Apple-interchange-newline"></SPAN> </DIV><BR></BODY></HTML>=

--Apple-Mail-2-732488020--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
