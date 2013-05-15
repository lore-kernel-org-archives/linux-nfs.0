Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:60970 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759086Ab3EONxH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 May 2013 09:53:07 -0400
Message-ID: <51939338.3070902@RedHat.com>
Date: Wed, 15 May 2013 09:52:56 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 00/13] lnfs: linux-3.10-rc1 release
References: <1368472317-5602-1-git-send-email-SteveD@redhat.com> <20130514214057.GB16811@fieldses.org>
In-Reply-To: <20130514214057.GB16811@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 14/05/13 17:40, J. Bruce Fields wrote:
> On Mon, May 13, 2013 at 03:11:44PM -0400, Steve Dickson wrote:
>> From: Steve Dickson <steved@redhat.com>
>>
>> Here is an the next rlease of the label NFS patches
>> ported to the linux-3-10.rc1 release. 
> 
> Steve, note James Morris acked patches 1, 2, 3, 4, 11, and 12.  Could
> you please add the 
> 
> 	Acked-by: James Morris <james.l.morris@oracle.com>
> 
> to those before the next resend?
Will do... 

steved.

> 
> --b.
> 
>>
>> Note, this release only include the security and 
>> NFS client patches since the server patches have 
>> already been merged into Bruce's tree... I did
>> uses those patches to test the release. 
>>
>> Bruce, thank you very much for all you help! 
>>
>> There were no functional changes in the security 
>> patches. There were some simple merge conflicts 
>> in a couple header files. 
>>
>> The following has was changed in the client code
>>
>> * Labels were taken out of the cache consistency 
>>   bitmask. The means the ACCESS and DELEGRETURN 
>>   will no longer pass labels. 
>>
>> * Looking to get the label out of the I/O path, 
>>   I found the follow ops allocate labels but never 
>>   process them (aka they never send a GETATTR in 
>>   the compound) 
>>       READ, CLOSE, REMOVE, RENAME. 
>>
>>   So the label code was be removed from those ops.
>>
>> So that leaves LOOKUP, READDIR, GETATTR, LINK, SETATTR, CREATE and OPEN 
>> that will continue to pass labels... 
>>
>> David Quigley (8):
>>   Security: Add hook to calculate context based on a negative dentry.
>>   Security: Add Hook to test if the particular xattr is part of a MAC
>>     model.
>>   LSM: Add flags field to security_sb_set_mnt_opts for in kernel mount
>>     data.
>>   SELinux: Add new labeling type native labels
>>   NFSv4: Add label recommended attribute and NFSv4 flags
>>   NFSv4: Introduce new label structure
>>   NFSv4: Extend fattr bitmaps to support all 3 words
>>   NFS: Extend NFS xattr handlers to accept the security namespace
>>
>> Steve Dickson (5):
>>   NFSv4.2: Added NFS v4.2 support to the NFS client
>>   NFS:Add labels to client function prototypes
>>   NFS: Add label lifecycle management
>>   NFS: Client implementation of Labeled-NFS
>>   Kconfig: Add Kconfig entry for Labeled NFS V4 client
>>
>>  fs/nfs/Kconfig                      |  28 ++
>>  fs/nfs/callback.c                   |   1 +
>>  fs/nfs/callback_xdr.c               |   6 +-
>>  fs/nfs/client.c                     |   2 +-
>>  fs/nfs/dir.c                        |  46 ++-
>>  fs/nfs/getroot.c                    |   2 +-
>>  fs/nfs/inode.c                      | 133 +++++++--
>>  fs/nfs/namespace.c                  |   2 +-
>>  fs/nfs/nfs3acl.c                    |   4 +-
>>  fs/nfs/nfs3proc.c                   |  41 +--
>>  fs/nfs/nfs4_fs.h                    |   8 +-
>>  fs/nfs/nfs4client.c                 |   5 +
>>  fs/nfs/nfs4namespace.c              |   2 +-
>>  fs/nfs/nfs4proc.c                   | 548 ++++++++++++++++++++++++++++++++----
>>  fs/nfs/nfs4xdr.c                    | 184 +++++++++---
>>  fs/nfs/proc.c                       |  15 +-
>>  fs/nfs/super.c                      |  24 +-
>>  include/linux/nfs4.h                |  11 +
>>  include/linux/nfs_fs.h              |  30 +-
>>  include/linux/nfs_fs_sb.h           |   8 +-
>>  include/linux/nfs_xdr.h             |  30 +-
>>  include/linux/security.h            |  57 +++-
>>  include/uapi/linux/nfs4.h           |   2 +-
>>  security/capability.c               |  19 +-
>>  security/security.c                 |  24 +-
>>  security/selinux/hooks.c            |  92 +++++-
>>  security/selinux/include/security.h |   2 +
>>  security/selinux/ss/policydb.c      |   5 +-
>>  security/smack/smack_lsm.c          |  11 +
>>  29 files changed, 1132 insertions(+), 210 deletions(-)
>>
>> -- 
>> 1.8.1.4
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
