Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mails1n0-route0.email.arizona.edu ([128.196.130.69]:44638 "EHLO
        mails1n0-route0.email.arizona.edu" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1730055AbeGRBD2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jul 2018 21:03:28 -0400
Subject: Re: RDMA connection closed and not re-opened
References: <f1e596cf-0e70-39af-99e9-a0a7e912bad3@genome.arizona.edu>
 <4A72535B-E6D2-4E8A-B6DB-BF09856A41EB@gmail.com>
 <19cd3809-669b-2d63-d453-ed553c9e01a9@genome.arizona.edu>
 <E7AAFE10-FBFE-41E9-9731-D9C50DD2F654@oracle.com>
 <57cf42c5-d12d-fff3-fd77-0d191d32111e@genome.arizona.edu>
 <9b0802b9-ad7c-0969-6087-9f2aef703143@genome.arizona.edu>
 <0423D037-63F9-4BA6-882A-CBD9EBC630F2@oracle.com>
 <5b08ea1b-4cde-c432-92cc-04eff469ed54@genome.arizona.edu>
 <7F74B5E4-DCAD-46E1-988F-68E79FBD72FA@oracle.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: admin@genome.arizona.edu
Message-ID: <034ccdc2-a673-1005-d28c-ea6c75acab25@genome.arizona.edu>
Date: Tue, 17 Jul 2018 17:27:58 -0700
MIME-Version: 1.0
In-Reply-To: <7F74B5E4-DCAD-46E1-988F-68E79FBD72FA@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote on 07/14/2018 07:37 AM> I wasn't entirely clear: Does 
pac mount itself?
No, why would we do that?  Do people do that?  Here is a listing of 
relevant mounts on our server pac:

/dev/sdc1 on /data type xfs (rw)
/dev/sdb1 on /projects type xfs (rw)
/dev/sde1 on /working type xfs (rw,nobarrier)
nfsd on /proc/fs/nfsd type nfsd (rw)
/dev/drbd0 on /newwing type xfs (rw)
150.x.x.116:/wing on /wing type nfs (rw,addr=150.x.x.116)
150.x.x.116:/archive on /archive type nfs (rw,addr=150.x.x.116)
150.x.x.116:/backups on /backups type nfs (rw,addr=150.x.x.116)

The backup jobs read from the mounted local disks /data and /projects 
and write to the remote NFS server at /backups and /archive.  I have 
noticed in the log files for our other servers which mount the pac 
exports, "nfs: server pac not responding, timed out" which all show up 
after 8PM when the backup jobs are running.

And here is listing of our pac server exports:

/data	10.10.10.0/24(rw,no_root_squash,async)
/data	10.10.11.0/24(rw,no_root_squash,async)
/data	150.x.x.192/27(rw,no_root_squash,async)
/data	150.x.x.64/26(rw,no_root_squash,async)
/home	10.10.10.0/24(rw,no_root_squash,async)
/home	10.10.11.0/24(rw,no_root_squash,async)
/opt	10.10.10.0/24(rw,no_root_squash,async)
/opt	10.10.11.0/24(rw,no_root_squash,async)
/projects	10.10.10.0/24(rw,no_root_squash,async)
/projects	10.10.11.0/24(rw,no_root_squash,async)
/projects	150.x.x.192/27(rw,no_root_squash,async)
/projects	150.x.x.64/26(rw,no_root_squash,async)
/tools	10.10.10.0/24(rw,no_root_squash,async)
/tools	10.10.11.0/24(rw,no_root_squash,async)
/usr/share/gridengine     10.10.10.10/24(rw,no_root_squash,async)
/usr/share/gridengine     10.10.11.10/24(rw,no_root_squash,async)
/usr/local	10.10.10.10/24(rw,no_root_squash,async)
/usr/local	10.10.11.10/24(rw,no_root_squash,async)
/working	10.10.10.0/24(rw,no_root_squash,async)
/working	10.10.11.0/24(rw,no_root_squash,async)
/working	150.x.x.192/27(rw,no_root_squash,async)
/working	150.x.x.64/26(rw,no_root_squash,async)
/newwing	10.10.10.0/24(rw,no_root_squash,async)
/newwing	10.10.11.0/24(rw,no_root_squash,async)
/newwing	150.x.x.192/27(rw,no_root_squash,async)
/newwing	150.x.x.64/26(rw,no_root_squash,async)

The 10.10.10.0/24 network is 1GbE and the 10.10.11.0/24 is the 
Infiniband.  The other networks are also 1GbE.  Our cluster nodes will 
normally mount all of these using the Infiniband with RDMA and the 
computation jobs will normally be using /working which will see the most 
reading/writing but /newwing, /projects, and /data are also used.

It does continue to seem to be a bug in NFS.  Somehow seems to be 
triggered when the NFS server runs the backup job.  I just tried it now 
and about 20 mins into the backup job the server stopped responding to 
some things, like iotop froze.  top remained active and could see the 
load on the server going up but only to about 22/24 and still about 95% 
idle cpu time.  Also noticed the "nfs: server pac not responding, timed 
out" messages on our other servers.  After about 10 minutes the server 
became responsive again and load dropped down to 3/24 while the backup 
job continued.

Perhaps it could be  mitigated if I change the backup job to use SSH 
instead of NFS.  I'll try that and see if it helps, then once our job 
has completed I can try going back to RDMA to see if it still happens....


