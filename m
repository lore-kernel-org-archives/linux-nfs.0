Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out.selfhost.de ([82.98.82.95]:39699 "EHLO outgoing.selfhost.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754500Ab2DOOxw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 15 Apr 2012 10:53:52 -0400
Message-ID: <4F8ADF6B.2050602@afaics.de>
Date: Sun, 15 Apr 2012 16:47:07 +0200
From: Harald Dunkel <harri@afaics.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: hdunkel@aixigo.de
Subject: what is NFSERR_EAGAIN needed for?
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi folks,

AFAICS the RFCs about NFS don't define NFSERR_EAGAIN, so I
wonder why is it in nfs.h?

enum nfs_stat {
	NFS_OK = 0,			/* v2 v3 v4 */
	:
	NFSERR_NXIO = 6,		/* v2 v3 v4 */
	NFSERR_EAGAIN = 11,		/* v2 v3 */
	NFSERR_ACCES = 13,		/* v2 v3 v4 */
	NFSERR_EXIST = 17,		/* v2 v3 v4 */
	:


Reason for asking is: I'm running a NFS server on Linux.
NFS on a Solaris 10 client gets stuck several times a week.
/var/adm/messages on this client says

:
Apr  2 16:28:02 srvs008 nfs: [ID 527099 kern.notice] NFS write error on host nfs-home: error 11.
Apr  2 16:28:02 srvs008 nfs: [ID 702911 kern.notice] (file handle: 1070001 100a0003 0 95b93472 2c4eeb8d b933e4af 8a7789c7 105c3be4 15bf4bcb)
Apr  2 16:28:02 srvs008 genunix: [ID 456612 kern.notice] file temporarily unavailable on the server, retrying...
Apr  4 09:53:07 srvs008 genunix: [ID 456612 kern.notice] file temporarily unavailable on the server, retrying...
Apr  5 16:17:32 srvs008 genunix: [ID 456612 kern.notice] file temporarily unavailable on the server, retrying...
Apr  6 12:47:15 srvs008 nfs: [ID 333984 kern.notice] NFS server nfs-home not responding still trying
Apr  6 12:50:15 srvs008 nfs: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 12:50:15 srvs008 genunix: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 12:51:15 srvs008 last message repeated 3 times
Apr  6 12:57:15 srvs008 genunix: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 13:01:15 srvs008 last message repeated 5 times
Apr  6 13:10:15 srvs008 genunix: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 13:12:01 srvs008 last message repeated 3 times
Apr  6 13:20:15 srvs008 genunix: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 13:21:15 srvs008 last message repeated 3 times
Apr  6 13:30:15 srvs008 genunix: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 13:32:01 srvs008 last message repeated 3 times
Apr  6 13:40:15 srvs008 genunix: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 13:41:15 srvs008 last message repeated 2 times
Apr  6 13:42:12 srvs008 genunix: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 13:52:12 srvs008 last message repeated 5 times
Apr  6 13:58:01 srvs008 genunix: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 14:01:15 srvs008 last message repeated 4 times
Apr  6 14:02:12 srvs008 genunix: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 14:12:12 srvs008 last message repeated 5 times
Apr  6 14:20:15 srvs008 genunix: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 14:21:15 srvs008 last message repeated 3 times
Apr  6 14:30:15 srvs008 genunix: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 14:32:12 srvs008 last message repeated 3 times
Apr  6 14:41:01 srvs008 genunix: [ID 333984 kern.notice] NFS server nfs-data not responding still trying
Apr  6 14:41:12 srvs008 last message repeated 1 time
:

(nfs-home and nfs-data are host name aliases for the same Linux
server.)

It seems to follow this pattern: first there is an EAGAIN, and some time
later NFS on the client stops working with these "still trying" messages.
Other clients are not affected, AFAICS.


Any helpful comment would be highly appreciated.

harri
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iEYEARECAAYFAk+K32YACgkQUTlbRTxpHjfW6ACeIFFUwuOfW3xnmNa55sReGDNI
k3EAnRZXli1KR3QWwi5QGoe+BePw8NAf
=AfkD
-----END PGP SIGNATURE-----
