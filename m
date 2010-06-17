From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Syslog flooded: "NFSD: preprocess_seqid_op: magic stateid!"
Date: Wed, 16 Jun 2010 22:32:57 -0400
Message-ID: <20100617023257.GB20645@fieldses.org>
References: <501A322854D4C944BCAF0528CFC7B65E3B30E7F5EE@BALZ00SW-MBX.ads.mwn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Joschi Brauchle <joschi.brauchle@tum.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44797 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759287Ab0FQCc5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jun 2010 22:32:57 -0400
In-Reply-To: <501A322854D4C944BCAF0528CFC7B65E3B30E7F5EE-7sgYbYbIMHsZ3TY+6YjGZ+/kjxG1y2if@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 16, 2010 at 10:20:15AM +0200, Joschi Brauchle wrote:
> Second problem:
> We recently downgraded from a patched nfs-utils 1.0.9 (patched to acc=
ept the =E2=80=9C-h=E2=80=9D option for different hostname in Kerberos =
service creds in a high availability environment) to the original Novel=
l RPM providing nfs-utils 1.0.7 (now using the undocumented =E2=80=9C-c=
=E2=80=9D switch to read the accepted creds from keytab file). (Note: t=
he first problem has already occurred before this downgrade)
>=20
> Since this change, we are experiencing massive lags (1-10 sec freezes=
, irregularly, but a couple times an hour) on our client machines, whic=
h are mounting their homes via NFSv4. There seem to be no related messa=
ges or warnings on the server nor the clients.
>=20
> We come to the conclusion that 1.0.9 was the more stable version. The=
 resulting question is: Which nfs-utils version would be best suited fo=
r SLES10SP3 (see kernel version above). Can we go straight to the lates=
t 1.2.2 available or should we stick with 1.0.xx version?

No idea.  We'd have to figure out the cause of the lags.

--b.
