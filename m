From: =?utf-8?B?5a6L5ZOy?= <songzhe-b9fPCLI57C9nsl9rxMBghA@public.gmane.org>
Subject: Re: Re: does nfs-util have a api-manual?
Date: Thu, 9 Jun 2011 09:19:44 +0800 (CST)
Message-ID: <777962.29188.qm@web15806.mail.cnb.yahoo.com>
Reply-To: =?utf-8?B?5a6L5ZOy?= <songzhe-b9fPCLI57C9nsl9rxMBghA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "SteveD@redhat.com" <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from n1c.bullet.cnmail.cnb.yahoo.com ([202.43.217.65]:42909 "HELO
	n1c.bullet.cnmail.cnb.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751426Ab1FIB0X convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jun 2011 21:26:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have wrote a server application that record audio files to a nfs=20
directory, and I write to the directory just like it is a local disk.

But when some error occurs with the nfs-connection, the "write"=20
operation is just hanged up and does not return any errors, so I want t=
o=20
use nfs-utils, and I think I can handle the error above with the tools.=
=20
But I almost know nothing about nfs-utils. Can you help me?

thanks !


________________________________
------------------=C2=A0=E5=8E=9F=E5=A7=8B=E9=82=AE=E4=BB=B6=C2=A0-----=
-------------
=E5=8F=91=E4=BB=B6=E4=BA=BA:=C2=A0"Steve=C2=A0Dickson"=C2=A0<SteveD@red=
hat.com>;
=E5=8F=91=E9=80=81=E6=97=B6=E9=97=B4:=C2=A02011=E5=B9=B406=E6=9C=8808=E6=
=97=A5=C2=A019=E7=82=B927=E5=88=86
=E6=94=B6=E4=BB=B6=E4=BA=BA:=C2=A0"=E5=AE=8B=E5=93=B2"=C2=A0<songzhe@ci=
ntel.net.cn>;=C2=A0
=E6=8A=84=E9=80=81:=C2=A0"linux-nfs@vger.kernel.org"=C2=A0<linux-nfs@vg=
er.kernel.org>;=C2=A0

=E4=B8=BB=E9=A2=98:=C2=A0Re:=C2=A0does=C2=A0nfs-util=C2=A0have=C2=A0a=C2=
=A0api-manual?=C2=A0


On=C2=A006/08/2011=C2=A005:39=C2=A0AM,=C2=A0=E5=AE=8B=E5=93=B2=C2=A0wro=
te:
>=C2=A0Does=C2=A0nfs-util=C2=A0have=C2=A0a=C2=A0api-manual?=C2=A0I=C2=A0=
can=C2=A0not=C2=A0find=C2=A0it,=C2=A0thanks!
No...=C2=A0What=C2=A0are=C2=A0you=C2=A0looking=C2=A0for?

steved.

>=C2=A0
>=C2=A0
>=C2=A0--
>=C2=A0To=C2=A0unsubscribe=C2=A0from=C2=A0this=C2=A0list:=C2=A0send=C2=A0=
the=C2=A0line=C2=A0"unsubscribe=C2=A0linux-nfs"=C2=A0in
>=C2=A0the=C2=A0body=C2=A0of=C2=A0a=C2=A0message=C2=A0to=C2=A0majordomo=
@vger.kernel.org
>=C2=A0More=C2=A0majordomo=C2=A0info=C2=A0at=C2=A0=C2=A0http://vger.ker=
nel.org/majordomo-info.html


