Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f182.google.com ([209.85.215.182]:51595 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932750Ab3E1MvC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 May 2013 08:51:02 -0400
Received: by mail-ea0-f182.google.com with SMTP id r16so4552047ead.41
        for <linux-nfs@vger.kernel.org>; Tue, 28 May 2013 05:51:00 -0700 (PDT)
Message-ID: <51A4A830.5040103@tonian.com>
Date: Tue, 28 May 2013 15:50:56 +0300
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>, nfsv4 mailing list <nfsv4@ietf.org>,
        Idan Keidar <idank@tonian.com>, Lev Solomonov <solo@tonian.com>,
        Nadav Shemer <nadav@tonian.com>, "Welch, Brent" <welch@panasas.com>,
        Boaz Harrosh <bharrosh@panasas.com>, Peng Tao <peng_tao@emc.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: Client security considerations for out of band I/O
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond, with the latest code for issuing LAYOUTGET with the right credentials
we still seem to have a problem with the objects and blocks layout where
the security enforcement over out-of-band I/O differs from than the one
over in-band I/O.

Consider the following scenario:

file is owned by <uid1, gid1>, mode 660
process p1 successfully opens the file for RW with <uid1, gid1> (client sent OPEN)
process p2 successfully opens the file for RW with <uid2, gid1> (client sent ACCESS)
client gets a layout using LAYOUTGET for IOMODE_RW
the file is chmod'ed to 600

now, empirically, in-band I/O would succeed for p1 and fail for p2 (as seen on linux
and some commercial servers)

for out-of-band I/O, an object-based server will fence-off the object and recall the layout
to enforce the client to refresh its layout, send a LAYOUTGET, reauthorize, and get
a new capability. BUT, that's not enough as the new layout and capability, would allow both
p1 and p2 access to the object (as the layout is global to the client), yet we want only p1
to have access now.

How about sending ACCESS for any principal before using a newly retrieved layout
at OPEN time or after the layout was revoked/reacquired to simulate the in-band behavior in
a practical manner?

Note that I expect some inaccuracies in behavior even with sending ACCESS as
the linux nfs server and other commercial servers bypass permission checking for the file owner
at I/O time but not for ACCESS.  I believe this was done to simulate (sort of) Posix behavior
that allows I/O to an open file even after changing its security attributes.

Also, do we deal correctly with LAYOUTGET failing on NFS4ERR_ACCESS?
In the example above, if the open order was reversed, LAYOUTGET would have failed for p2's
creds as it doesn't have RW access to the file.  That would result to reverting to the MDS
and the I/O would fail on NFS4ERR_ACCESS as well, yet we'll keep trying (and failing)
LAYOUTGET.  Optionally, the client could try other creds that opened the file.
If the first process to open the file closes it, should we use different creds for LAYOUTGET?
With the latest implementation we keep the first opener creds referenced until we return the
whole layout, right?

Regards,

Benny
