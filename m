Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp2-g21.free.fr ([212.27.42.2]:48651 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753894Ab3IFP51 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Sep 2013 11:57:27 -0400
Date: Fri, 6 Sep 2013 17:57:21 +0200
From: Emmanuel Florac <eflorac@intellique.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Hard to debug NFS loss of connectivity
Message-ID: <20130906175721.30082c11@harpe.intellique.com>
In-Reply-To: <20130905214002.GD24805@fieldses.org>
References: <20130905191800.1c75b2fb@harpe.intellique.com>
	<20130905204536.GB24805@fieldses.org>
	<20130905233449.5eb8bf79@galadriel.home>
	<20130905214002.GD24805@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_//wQNq0x5QV.+yHLHe9Ao716"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--MP_//wQNq0x5QV.+yHLHe9Ao716
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Le Thu, 5 Sep 2013 17:40:02 -0400
"J. Bruce Fields" <bfields@fieldses.org> =E9crivait:

> I was asking about the on-the-wire errors and getattr replies here,
> not the application system calls.
>=20

OK, I've done the dump; I've kept just the last few working calls, then
the failure calls, and filtered for NFS traffic (there are SSH and
LACP frames interspersed here). I have absolutely no idea about what's
going on there :) Any light from the network savvy?

--=20
------------------------------------------------------------------------
Emmanuel Florac     |   Direction technique
                    |   Intellique
                    |	<eflorac@intellique.com>
                    |   +33 1 78 94 84 02
------------------------------------------------------------------------

--MP_//wQNq0x5QV.+yHLHe9Ao716
Content-Type: application/vnd.tcpdump.pcap
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=nfserror.pcap

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

--MP_//wQNq0x5QV.+yHLHe9Ao716--
