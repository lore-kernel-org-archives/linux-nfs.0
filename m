From: kjetil.mikkelborg@kongsberg.com
Subject: NFS server support in Redhat Advanced Server
Date: Fri, 17 Jan 2003 08:59:16 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <75587E33AC778145AACCE1601EEABF420D8C23@kda-beexc-02.kda.kongsberg.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C2BDFE.551A7F50"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailgw.kongsberg.com ([193.71.180.98] helo=mailgw1.kongsberg.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ZRPR-0006Lq-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Jan 2003 23:59:25 -0800
Received: from kda-mailhub-01.kda.kongsberg.com (unverified) by mailgw1.kongsberg.com
 (Content Technologies SMTPRS 4.2.10) with ESMTP id <T5fd7c5b5c7c147b462850@mailgw1.kongsberg.com> for <nfs@lists.sourceforge.net>;
 Fri, 17 Jan 2003 08:59:11 +0100
To: nfs@lists.sourceforge.net
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

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C2BDFE.551A7F50
Content-Type: text/plain

Hi.

I am looking at using RHAS for primary a backup solution, but I also see the
need for it to handle a pretty high nfs load also. Anyone who knows if RHAS
has the performance/NFS stability needed? Looks to me that RHAS uses a
modded 2.4.9 kernel, with backport for AsyncIO and other snacks, but has it
also most of the kernel patches which are needed for getting NFS to work
well? 

I know this is actually a more RH question, but wanted to ask some people
outside RH, since then i might get a more honest reply to my questions :) (
not stating that RH is dishonest, just that sales people usually want to
sell products ).

Thanks for your time
Kjetil Mikkelborg

------_=_NextPart_001_01C2BDFE.551A7F50
Content-Type: text/html
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
5.5.2653.12">
<TITLE>NFS server support in Redhat Advanced Server</TITLE>
</HEAD>
<BODY>

<P><FONT SIZE=3D2>Hi.</FONT>
</P>

<P><FONT SIZE=3D2>I am looking at using RHAS for primary a backup =
solution, but I also see the need for it to handle a pretty high nfs =
load also. Anyone who knows if RHAS has the performance/NFS stability =
needed? Looks to me that RHAS uses a modded 2.4.9 kernel, with backport =
for AsyncIO and other snacks, but has it also most of the kernel =
patches which are needed for getting NFS to work well? </FONT></P>

<P><FONT SIZE=3D2>I know this is actually a more RH question, but =
wanted to ask some people outside RH, since then i might get a more =
honest reply to my questions :) ( not stating that RH is dishonest, =
just that sales people usually want to sell products ).</FONT></P>

<P><FONT SIZE=3D2>Thanks for your time</FONT>
<BR><FONT SIZE=3D2>Kjetil Mikkelborg</FONT>
</P>

</BODY>
</HTML>
------_=_NextPart_001_01C2BDFE.551A7F50--


-------------------------------------------------------
This SF.NET email is sponsored by: Thawte.com
Understand how to protect your customers personal information by implementing
SSL on your Apache Web Server. Click here to get our FREE Thawte Apache 
Guide: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0029en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
