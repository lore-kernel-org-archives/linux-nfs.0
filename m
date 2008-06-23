From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: Upcoming nfs-utils 1.1.3 release.
Date: Mon, 23 Jun 2008 22:57:04 +0200
Message-ID: <20080623205704.GU4484@ics.muni.cz>
References: <48600CCC.5000203@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:34126 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754616AbYFWU5V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jun 2008 16:57:21 -0400
In-Reply-To: <48600CCC.5000203-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On Mon, Jun 23, 2008 at 04:51:24PM -0400, Steve Dickson wrote:
> I'm thinking about making a 1.1.3 nfs-utils update release in the rel=
atively
> near future. I've made about  20 or so commits since the last release=
 so
> I was thinking that was a nice round number to cut a release...=20
>=20
> So if your sitting on some patches that you want include please post =
them to
> the list. Also if you don't see something in the git tree that should=
 be
> there (i.e.  I missed the patch posting) please bring it to my attent=
ion...=20

have there been any changes to rpc.gssd since 1.1.2? Searching for a pr=
oper
kerberos ticket was broken. I have patches to fix it and also adding an=
 extra
option to set preffered realm of the tickets (it comes handy in cross-r=
ealm
environment). I would like to see these patches included.

--=20
Luk=E1=B9 Hejtm=E1nek
