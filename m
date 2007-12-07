From: Valdis.Kletnieks@vt.edu
Subject: Re: [NFS] NFSv2/3 broken exporting/mounting (permission denied) in
	2.6.24-rc4
Date: Fri, 07 Dec 2007 15:38:44 -0500
Message-ID: <4734.1197059924__35839.9667930373$1197061738$gmane$org@turing-police.cc.vt.edu>
References: <20071207025504.GA3070@fieldses.org>
	<200712072000.lB7K0DZ5013256@agora.fsl.cs.sunysb.edu>
	<20071207200655.GD2204@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2099070259=="
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>,
	nfs@lists.sourceforge.net,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Pavel Machek <pavel@ucw.cz>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Ingo Molnar <mingo@elte.hu>, Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pavel Emelyanov <xemul@openvz.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:48087 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752652AbXLGVI3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2007 16:08:29 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1J0kQu-0007fy-8S
	for linux-nfs@vger.kernel.org; Sat, 08 Dec 2007 08:08:28 +1100
In-Reply-To: Your message of "Fri, 07 Dec 2007 15:06:55 EST."
	<20071207200655.GD2204@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--===============2099070259==
Content-Type: multipart/signed; boundary="==_Exmh_1197059924_2992P";
	micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit

--==_Exmh_1197059924_2992P
Content-Type: text/plain; charset="us-ascii"
Content-Id: <4728.1197059924.1-+bZmOdGhbsPr6rcHtW+onFJE71vCis6O@public.gmane.org>

On Fri, 07 Dec 2007 15:06:55 EST, "J. Bruce Fields" said:
> On Fri, Dec 07, 2007 at 03:00:13PM -0500, Erez Zadok wrote:

> > commit 2b1e300a9dfc3196ccddf6f1d74b91b7af55e416
> > Author: Eric W. Biederman <ebiederm@xmission.com>
> > Date:   Sun Dec 2 00:33:17 2007 +1100

> Those files are actually in a separate filesystem (of type "nfsd") which
> is supposed to be mounted on /proc/fs/nfsd/.   So that mount must have
> failed in the bad case?  It's not immediately obvious to me what this
> patch has to do with that.  Hm.

For what it's worth, the startup scripts for 'wine' and 'jexec' fail as well,
and at shutdown, I get complaints about being unable to dismount 
/proc/sys/fs/binfmt_misc. 'strace' says:

open("/proc/sys/fs/binfmt_misc/windows", O_WRONLY|O_CREAT|O_TRUNC, 0666) = -1 EN
OENT (No such file or directory)

# grep binfmt /proc/mounts
none /proc/sys/fs/binfmt_misc binfmt_misc rw 0 0
none /proc/sys/fs/binfmt_misc binfmt_misc rw 0 0

I have to wonder if the fact there's 2 of them mounted is related to the
fact that 2 startup scripts tried to touch files under fs/binfmt_misc/ ?


--==_Exmh_1197059924_2992P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFHWa9UcC3lWbTT17ARAjjLAJ0ZJ9G1fu8JZl8pBUtGi20lb1YGnQCeNVV6
zrGR7CdbouAlqBPVylThcRs=
=b2cP
-----END PGP SIGNATURE-----

--==_Exmh_1197059924_2992P--


--===============2099070259==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
SF.Net email is sponsored by:
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
--===============2099070259==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============2099070259==--


