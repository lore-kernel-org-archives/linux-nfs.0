Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:42996 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726793AbeGNO4X (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 14 Jul 2018 10:56:23 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: RDMA connection closed and not re-opened
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <5b08ea1b-4cde-c432-92cc-04eff469ed54@genome.arizona.edu>
Date: Sat, 14 Jul 2018 10:37:00 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7F74B5E4-DCAD-46E1-988F-68E79FBD72FA@oracle.com>
References: <f1e596cf-0e70-39af-99e9-a0a7e912bad3@genome.arizona.edu>
 <4A72535B-E6D2-4E8A-B6DB-BF09856A41EB@gmail.com>
 <19cd3809-669b-2d63-d453-ed553c9e01a9@genome.arizona.edu>
 <E7AAFE10-FBFE-41E9-9731-D9C50DD2F654@oracle.com>
 <57cf42c5-d12d-fff3-fd77-0d191d32111e@genome.arizona.edu>
 <9b0802b9-ad7c-0969-6087-9f2aef703143@genome.arizona.edu>
 <0423D037-63F9-4BA6-882A-CBD9EBC630F2@oracle.com>
 <5b08ea1b-4cde-c432-92cc-04eff469ed54@genome.arizona.edu>
To: admin@genome.arizona.edu
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jul 13, 2018, at 6:32 PM, admin@genome.arizona.edu wrote:
>=20
> Chuck Lever wrote on 07/13/2018 07:36 AM:
>> You should be able to mount using "proto=3Dtcp" with your mlx4 cards.
>> That avoids the use of NFS/RDMA but would enable the use of the
>> higher bandwidth network fabric.
> Thanks I could definitely try that.  IPoIB has it's own set of issues =
though but can cross that bridge when I get to it....

Stick with connected mode and keep rsize and wsize smaller
than the IPoIB MTU, which can be set as high as 65KB.


>> Can you diagram your full configuration during the backup?
> The main server in relation to this issue, which is named "pac" in the =
log files, has several local storage devices which are exported over the =
Ethernet and Infiniband interfaces.  In addition, it has several other =
mounts over Ethernet to some of our other NFS servers.  The =
rsnapshot/backup job uses rsync to read from the local storage and sends =
to the NFS mounts to another server using standard 1Gb ethernet and TCP =
protocol.  So the answer to your second question,
>> Does the
>> NFS client mount the NFS server on this same host?
> I believe is "yes"

I wasn't entirely clear: Does pac mount itself?

I don't know what the workload is like on this "self mount" but
we recommend not to use this kind of configuration, because it
is prone to deadlock with a significant workload.


>> Does it use
>> NFS/RDMA or can it use ssh instead of NFS?
> Currently just uses NFS/TCP over 1Gb Ethernet link.  rsnapshot does =
have the ability to use SSH

I was thinking that it might be better to use ssh and avoid NFS
for the backup workload, in order to avoid pac mounting itself.


>> I'm not familiar with the CentOS bug database. If there's an "NFS"
>> category, I would go with that.
> There is no "NFS" category, only nfs-utils, nfs-utils-lib, and =
nfs4-acl-tools.  So I'm guessing if we want to report against NFS then =
"kernel" would be the category?

In the "kernel" category, there might be an "NFS or NFSD"
subcomponent.


>> Before filing, you should search that database to see if there are
>> similar bugs. Simply Googling "peername failed!" brings up several
>> NFSD related entries right at the top of the list that appear
>> similar to your circumstance (and there is no mention of NFS/RDMA).
> Thanks I will be checking that out

--
Chuck Lever



