Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:41168 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753692AbdBNUIL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Feb 2017 15:08:11 -0500
From: "Mora, Jorge" <Jorge.Mora@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Question about NFSv4.2 server-side copy implementation
Date: Tue, 14 Feb 2017 20:07:48 +0000
Message-ID: <BLUPR06MB54767D9B4746E210D176C3AE1580@BLUPR06MB547.namprd06.prod.outlook.com>
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,
=20
The NFSv4.2 spec (RFC 7862) on section 15.2.3 (COPY description) says the f=
ollowing:
=20
If the source offset or the source offset plus count is greater than
the size of the source file, the operation MUST fail with
NFS4ERR_INVAL.
=20
I can understand failing with NFS4ERR_INVAL when the source offset is beyon=
d the end of the file,
but do you think failing with NFS4ERR_INVAL is too strict when the source o=
ffset plus the count is beyond the end of the file?
What is the rationalization for failing on this specific instance?
Why not return a short copy instead?
Can the COPY return a count less than what it requested (a short copy)?
=20
As of right now, the implementation on the Linux server adheres to the spec=
 but copy_file_range succeeds
when it is called against the local file system, NFSv4.x or NFSv3.
For the local file system, NFSv4.x or NFSv3 copy_file_range falls back to r=
egular copy by
reading from the source file and then writing to the destination file but I=
 do believe the
syscall should be consistent regardless of the underlying file system.
=20
=20
--Jorge
