Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gproxy8-pub.mail.unifiedlayer.com ([67.222.33.93]:56695 "HELO
	gproxy8-pub.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750960AbaHCOe5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 10:34:57 -0400
Received: from [98.248.107.106] (port=39368 helo=monster.martins.cc)
	by box503.bluehost.com with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.82)
	(envelope-from <linux@martins.cc>)
	id 1XDws8-0003gT-9j
	for linux-nfs@vger.kernel.org; Sun, 03 Aug 2014 08:34:52 -0600
Received: from monster.martins.cc (monster.martins.cc [127.0.0.1])
	by monster.martins.cc (Postfix) with ESMTP id CD577627F4
	for <linux-nfs@vger.kernel.org>; Sun,  3 Aug 2014 07:34:47 -0700 (PDT)
From: Henrique Martins <linux@martins.cc>
To: linux-nfs@vger.kernel.org
Subject: nfs-utils.spec patch
In-reply-to: <bug-1115179-43722-GPTO0t3XWU@bugzilla.redhat.com>
References: <bug-1115179-43722@bugzilla.redhat.com>
 <bug-1115179-43722-GPTO0t3XWU@bugzilla.redhat.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Date: Sun, 03 Aug 2014 07:34:47 -0700
Message-ID: <25446.1407076487@monster.martins.cc>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8


The spec file for nfs-utils-1.3.0-2.1.fc20 (nfs-utils.spec)
has a bunch of bad date entries in %changelog which cause
warnings when running rpmbuild.

Patch attached, by changing the weekday to match the day
number.

-- Henrique


--=-=-=
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment; filename=nfs-utils.spec.patch

*** SPECS/nfs-utils.spec.orig	2014-06-03 10:54:25.000000000 -0700
--- SPECS/nfs-utils.spec	2014-08-02 14:16:02.297833025 -0700
***************
*** 671,677 ****
  - Updated to the latest pseudo root release (rel10) which
    containts the upstream pseudo root release

! * Mon Jan 12 2010 Steve Dickson <steved@redhat.com> 1.2.1-9
  - Updated to latest upstream RC release: nfs-utils-1-2-2-rc5

  * Mon Jan  4 2010 Steve Dickson <steved@redhat.com> 1.2.1-8
--- 671,677 ----
  - Updated to the latest pseudo root release (rel10) which
    containts the upstream pseudo root release

! * Tue Jan 12 2010 Steve Dickson <steved@redhat.com> 1.2.1-9
  - Updated to latest upstream RC release: nfs-utils-1-2-2-rc5

  * Mon Jan  4 2010 Steve Dickson <steved@redhat.com> 1.2.1-8
***************
*** 1062,1068 ****
  - Added -o nordirplus mount option to disable READDIRPLUS (bz 240357)
  - Disabled the FSCache patch, for now...

! * Wed May 10 2007 Steve Dickson <steved@redhat.com> 1.0.12-5
  - Fix mount.nfs4 to display correct error message (bz 227212)
  - Updated mountd and showmount reverse lookup flags (bz 220772)
  - Eliminate timeout on nfsd shutdowns (bz 222001)
--- 1062,1068 ----
  - Added -o nordirplus mount option to disable READDIRPLUS (bz 240357)
  - Disabled the FSCache patch, for now...

! * Thu May 10 2007 Steve Dickson <steved@redhat.com> 1.0.12-5
  - Fix mount.nfs4 to display correct error message (bz 227212)
  - Updated mountd and showmount reverse lookup flags (bz 220772)
  - Eliminate timeout on nfsd shutdowns (bz 222001)
***************
*** 1105,1111 ****
  * Wed Dec 13 2006 Steve Dickson <steved@redhat.com> 1.0.10-5
  - Stopped v4 umounts from ping rpc.mountd (bz 215553)

! * Wed Nov 28 2006 Steve Dickson <steved@redhat.com> 1.0.10-4
  - Doing a connect on UDP sockets causes the linux network
    stack to reject UDP patches from multi-home server with
    nic on the same subnet. (bz 212471)
--- 1105,1111 ----
  * Wed Dec 13 2006 Steve Dickson <steved@redhat.com> 1.0.10-5
  - Stopped v4 umounts from ping rpc.mountd (bz 215553)

! * Tue Nov 28 2006 Steve Dickson <steved@redhat.com> 1.0.10-4
  - Doing a connect on UDP sockets causes the linux network
    stack to reject UDP patches from multi-home server with
    nic on the same subnet. (bz 212471)
***************
*** 1236,1242 ****
  - Updated libevent from 1.0b to 1.1a
  - Added libgssapi-0.4 and librpcsecgss-0.6 libs from CITI

! * Tue Sep  8 2005 Steve Dickson <SteveD@RedHat.com> 1.0.7-16
  - Reworked the nfslock init script so if lockd is running
    it will be killed which is what the HA community needs. (bz 162446)
  - Stopped rpcidmapd.init from doing extra echoing when
--- 1236,1242 ----
  - Updated libevent from 1.0b to 1.1a
  - Added libgssapi-0.4 and librpcsecgss-0.6 libs from CITI

! * Thu Sep  8 2005 Steve Dickson <SteveD@RedHat.com> 1.0.7-16
  - Reworked the nfslock init script so if lockd is running
    it will be killed which is what the HA community needs. (bz 162446)
  - Stopped rpcidmapd.init from doing extra echoing when
***************
*** 1267,1273 ****
  * Wed Apr 13 2005 Steve Dickson <SteveD@RedHat.com> 1.0.7-6
  - Fixed misformated output from nfslock script (bz 154648)

! * Mon Mar 29 2005 Steve Dickson <SteveD@RedHat.com> 1.0.7-4
  - Fixed a compile error on x86_64 machines in the gss code.
  - Updated the statd-notify-hostname.patch to eliminate
    a segmentation fault in rpc.statd when an network
--- 1267,1273 ----
  * Wed Apr 13 2005 Steve Dickson <SteveD@RedHat.com> 1.0.7-6
  - Fixed misformated output from nfslock script (bz 154648)

! * Tue Mar 29 2005 Steve Dickson <SteveD@RedHat.com> 1.0.7-4
  - Fixed a compile error on x86_64 machines in the gss code.
  - Updated the statd-notify-hostname.patch to eliminate
    a segmentation fault in rpc.statd when an network
***************
*** 1362,1368 ****
    by default, there only needs to be away of
    turning them off.

! * Thu May 10 2004 <SteveD@RedHat.com>
  - Rebuilt

  * Thu Apr 15 2004 <SteveD@RedHat.com>
--- 1362,1368 ----
    by default, there only needs to be away of
    turning them off.

! * Mon May 10 2004 <SteveD@RedHat.com>
  - Rebuilt

  * Thu Apr 15 2004 <SteveD@RedHat.com>
***************
*** 1437,1443 ****
  - Upgrated to 1.0.6
  - Commented out the acl path for fedora

! * Thu Aug  27 2003 Steve Dickson <SteveD@RedHat.com>
  - Added the setting of lockd ports via sysclt interface
  - Removed queue setting code since its no longer needed

--- 1437,1443 ----
  - Upgrated to 1.0.6
  - Commented out the acl path for fedora

! * Wed Aug  27 2003 Steve Dickson <SteveD@RedHat.com>
  - Added the setting of lockd ports via sysclt interface
  - Removed queue setting code since its no longer needed

***************
*** 1447,1453 ****
  * Wed Jul 23 2003 Steve Dickson <SteveD@RedHat.com>
  - Commented out the acl patch (for now)

! * Wed Jul 21 2003 Steve Dickson <SteveD@RedHat.com>
  - Upgrated to 1.0.5

  * Wed Jun 18 2003 Steve Dickson <SteveD@RedHat.com>
--- 1447,1453 ----
  * Wed Jul 23 2003 Steve Dickson <SteveD@RedHat.com>
  - Commented out the acl patch (for now)

! * Mon Jul 21 2003 Steve Dickson <SteveD@RedHat.com>
  - Upgrated to 1.0.5

  * Wed Jun 18 2003 Steve Dickson <SteveD@RedHat.com>
***************
*** 1536,1542 ****
  - don't use rquotad from here now; quota package contains a version that
    works with 2.4 (#33738)

! * Tue Mar 12 2001 Bob Matthews <bmatthews@redhat.com>
  - Statd logs at LOG_DAEMON rather than LOG_LOCAL5
  - s/nfs/\$0/ where appropriate in init scripts

--- 1536,1542 ----
  - don't use rquotad from here now; quota package contains a version that
    works with 2.4 (#33738)

! * Mon Mar 12 2001 Bob Matthews <bmatthews@redhat.com>
  - Statd logs at LOG_DAEMON rather than LOG_LOCAL5
  - s/nfs/\$0/ where appropriate in init scripts

***************
*** 1562,1568 ****
  - Fix incorrect file specifications in statd manpage.
  - Require gawk 'cause it's used in nfslock init script.

! * Thu Dec 13 2000 Bob Matthews <bmatthews@redhat.com>
  - Require sed because it's used in nfs init script

  * Tue Dec 12 2000 Bob Matthews <bmatthews@redhat.com>
--- 1562,1568 ----
  - Fix incorrect file specifications in statd manpage.
  - Require gawk 'cause it's used in nfslock init script.

! * Wed Dec 13 2000 Bob Matthews <bmatthews@redhat.com>
  - Require sed because it's used in nfs init script

  * Tue Dec 12 2000 Bob Matthews <bmatthews@redhat.com>

--=-=-=--
