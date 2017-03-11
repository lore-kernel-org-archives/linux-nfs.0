Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:48463 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933156AbdCKQxz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Mar 2017 11:53:55 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: nfsd: delegation conflicts between NFSv3 and NFSv4 accessors
Date: Sat, 11 Mar 2017 11:53:47 -0500
Message-Id: <F2A98574-693E-4F72-B7D1-5FCEA851BC7C@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@redhat.com>,
        Jeff Layton <jlayton@redhat.com>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce, Jeff-

I've observed some interesting Linux NFS server behavior (v4.1.12).

We have a single system that has an NFSv4 mount via the kernel NFS
client, and an NFSv3 mount of the same export via a user space NFS
client. These two clients are accessing the same set of files.

The following pattern is seen on the wire. I've filtered a recent
capture on the FH of one of the shared files.

---- cut here ----

18507  19.483085    10.0.2.11 -> 10.0.1.8     NFS 238 V4 Call ACCESS FH: 0xc930444f, [Check: RD MD XT XE]
18508  19.483827     10.0.1.8 -> 10.0.2.11    NFS 194 V4 Reply (Call In 18507) ACCESS, [Access Denied: XE], [Allowed: RD MD XT]
18510  19.484676     10.0.1.8 -> 10.0.2.11    NFS 434 V4 Reply (Call In 18509) OPEN StateID: 0x6de3

This OPEN reply offers a read delegation to the kernel NFS client.

18511  19.484806    10.0.2.11 -> 10.0.1.8     NFS 230 V4 Call GETATTR FH: 0xc930444f
18512  19.485549     10.0.1.8 -> 10.0.2.11    NFS 274 V4 Reply (Call In 18511) GETATTR
18513  19.485611    10.0.2.11 -> 10.0.1.8     NFS 230 V4 Call GETATTR FH: 0xc930444f
18514  19.486375     10.0.1.8 -> 10.0.2.11    NFS 186 V4 Reply (Call In 18513) GETATTR
18515  19.486464    10.0.2.11 -> 10.0.1.8     NFS 254 V4 Call CLOSE StateID: 0x6de3
18516  19.487201     10.0.1.8 -> 10.0.2.11    NFS 202 V4 Reply (Call In 18515) CLOSE
18556  19.498617    10.0.2.11 -> 10.0.1.8     NFS 210 V3 READ Call, FH: 0xc930444f Offset: 8192 Len: 8192

This READ call by the user space client does not conflict with the
read delegation.

18559  19.499396     10.0.1.8 -> 10.0.2.11    NFS 8390 V3 READ Reply (Call In 18556) Len: 8192
18726  19.568975     10.0.1.8 -> 10.0.2.11    NFS 310 V3 LOOKUP Reply (Call In 18725), FH: 0xc930444f
18727  19.569170    10.0.2.11 -> 10.0.1.8     NFS 210 V3 READ Call, FH: 0xc930444f Offset: 0 Len: 512
18728  19.569923     10.0.1.8 -> 10.0.2.11    NFS 710 V3 READ Reply (Call In 18727) Len: 512
18729  19.570135    10.0.2.11 -> 10.0.1.8     NFS 234 V3 SETATTR Call, FH: 0xc930444f
18730  19.570901     10.0.1.8 -> 10.0.2.11    NFS 214 V3 SETATTR Reply (Call In 18729) Error: NFS3ERR_JUKEBOX

The user space client has attempted to extend the file. This does
conflict with the read delegation held by the kernel NFS client,
so the server returns JUKEBOX, the equivalent of NFS4ERR_DELAY.
This causes a negative performance impact on the user space NFS
client.

18731  19.575396    10.0.2.11 -> 10.0.1.8     NFS 250 V4 Call DELEGRETURN StateID: 0x6de3
18732  19.576132     10.0.1.8 -> 10.0.2.11    NFS 186 V4 Reply (Call In 18731) DELEGRETURN

No CB_RECALL was done to trigger this DELEGRETURN. Apparently
the application that was accessing this file via the kernel OS
client decided already that it no longer needed the file before
the server could send the CB_RECALL. Sign of perhaps a race
between the applications accessing the file via these two
mounts.

---- cut here ----

The server is aware of non-NFSv4 accessors of this file in frame
18556. NFSv3 has no OPEN operation, of course, so it's not
possible for the server to determine how the NFSv3 client will
subsequently access this file.

Seems like at frame 18556, it would be a best practice to recall
the delegation to avoid potential future conflicts, such as the
SETATTR in frame 18729.

Or, perhaps that READ isn't the first NFSv3 access of that file.
After all, a LOOKUP would have to be done to retrieve that file's
FH. The OPEN in frame 18556 perhaps could have avoided offering
the READ delegation, knowing there is a recent non-NFSv4 accessor
of that file.

Would these be difficult or inappropriate policies to implement?


--
Chuck Lever



