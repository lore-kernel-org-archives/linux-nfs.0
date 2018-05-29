Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:36409 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966399AbeE2Uc1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 May 2018 16:32:27 -0400
From: Goldwyn Rodrigues <rgoldwyn@suse.de>
Subject: nfs4_acl restricts copy_up in overlayfs
To: linux-nfs@vger.kernel.org,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>
Message-ID: <f74fae81-d1bc-1c0e-7b41-69502bd7c489@suse.de>
Date: Tue, 29 May 2018 15:32:23 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


While mounting overlayfs with NFS as a lower directory and a local
filesystem as an upper layer leads to copy_up failures because NFS4 has
an extra system.nfs4_acl which cannot be copied up. This has been
discussed before [1] and [2] with the suggestion that nfs4_acl is
derived from posix_acls or just inode->i_mode *most* of the times and
hence it can be mapped back.

The problem is NFS client knows nothing about nfs4_acl and it is decoded
in nfs4-acl-tools. Even if we make nfs client capable of understand
nfs4_acl xattr, can it be used to perform ACL's for the system. AFAIU,
it is uses user/group names as opposed uid/gid to perform id mapping.
Can the client map it back to user names and derive if it is just an
replica of inode's i_mode?

The idea is to suppress nfs4_acl if it is the same as inode's i_mode.
This means nfs4-acl-tools/nfs4_getacl would give no results when
requesting for ACLs. This would break existing applications if they
expect some output from nfs4_getfacl.

Is there a better way to identify if nfs4_acl is just a representation
of i_mode at the client end and can be safely ignored during an
overlayfs copy_up? Can we include a flag for this?


[1] https://www.spinics.net/lists/linux-nfs/msg61045.html
[2] https://www.spinics.net/lists/linux-unionfs/msg04736.html

-- 
Goldwyn
