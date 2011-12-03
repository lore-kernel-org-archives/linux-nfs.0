Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out.selfhost.de ([82.98.82.95]:54893 "EHLO outgoing.selfhost.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754498Ab1LCL2g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 3 Dec 2011 06:28:36 -0500
Message-ID: <4EDA0650.9080702@afaics.de>
Date: Sat, 03 Dec 2011 12:21:52 +0100
From: Harald Dunkel <harri@afaics.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFSv4 fsid=0 export still necessary?
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi folks,

several NFSv4-HOWTOs in the net require to export a root directory
with fsid=0 first. Other exported directory trees should be nested
within this root directory and exported with nohide. AFAIU the advan-
tage of the root dir is that the client can mount "server:/somedir"
instead of "server:/remote_mount_point/somedir".

Question: Is the common root directory optional? Since NFSv3 doesn't
support this name space feature, wouldn't it be more wise to omit
the root directory?


Any helpful comment would be highly appreciated

Harri
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEARECAAYFAk7aBlAACgkQUTlbRTxpHjeO0wCggdEdfcBzswibHAOG6w2xJa5r
B4QAn3MsYZR7xCh60c1X4AsNLnutXSPI
=nEBr
-----END PGP SIGNATURE-----
