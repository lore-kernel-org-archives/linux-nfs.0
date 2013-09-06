Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp1-g21.free.fr ([212.27.42.1]:39780 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755545Ab3IFQzO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Sep 2013 12:55:14 -0400
Date: Fri, 6 Sep 2013 18:55:08 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Hard to debug NFS loss of connectivity
Message-ID: <20130906185508.3f0d2730@harpe.intellique.com>
In-Reply-To: <20130906160735.GA16396@fieldses.org>
References: <20130905191800.1c75b2fb@harpe.intellique.com>
	<20130905204536.GB24805@fieldses.org>
	<20130905233449.5eb8bf79@galadriel.home>
	<20130905214002.GD24805@fieldses.org>
	<20130906175721.30082c11@harpe.intellique.com>
	<20130906160735.GA16396@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/znUGl3A.LkznY3z=EJZuohx"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--MP_/znUGl3A.LkznY3z=EJZuohx
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Le Fri, 6 Sep 2013 12:07:35 -0400
"J. Bruce Fields" <bfields@fieldses.org> =E9crivait:

> Weird.  Things look normal up through frame 14, which is a READDIRPLUS
> reply.  Then the server resends the reply after .2s, and and the
> client resends its call shortly thereafter (but without acking the
> latest reply).  And then the rest of the trace is resends of the
> reply.
>=20
> So it looks like the client stopped ACKing the server's replies?
>=20
> You may also have filtered out some TCP ACKs, which makes this harder
> to work out.

Ah yes, my bad, one TCP ACK was filtered out. Here I've kept trafic
between the two machines but ssh.

Here I was capturing from the server, maybe I should try capturing on
the client side?

--=20
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------

--MP_/znUGl3A.LkznY3z=EJZuohx
Content-Type: application/vnd.tcpdump.pcap
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=nfserror2.pcap

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

--MP_/znUGl3A.LkznY3z=EJZuohx--
