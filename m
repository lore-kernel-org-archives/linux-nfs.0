Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48686 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751323Ab3LLDjE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Dec 2013 22:39:04 -0500
Date: Wed, 11 Dec 2013 22:38:59 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kholmanskikh <stanislav.kholmanskikh@oracle.com>
Cc: linux-nfs@vger.kernel.org, vasily.isaenko@oracle.com, hch@infradead.org,
        xfs@oss.sgi.com, sprabhu@redhat.com
Subject: Re: [PATCH] nfsd: revoking of suid/sgid bits after chown() in a
 consistent way
Message-ID: <20131212033859.GA5978@fieldses.org>
References: <20131206204747.GB12613@fieldses.org>
 <1386756996-28083-1-git-send-email-stanislav.kholmanskikh@oracle.com>
 <52A845C6.2080109@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <52A845C6.2080109@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 11, 2013 at 03:00:22PM +0400, Stanislav Kholmanskikh wrote:
> 
> 
> On 12/11/2013 02:16 PM, Stanislav Kholmanskikh wrote:
> [cut off]
> >
> >This patch makes NFS to behave like local file systems.
> >
> [cut off]
> 
> This patch allows to run generic/193 without any issues with NFSv3.
> 
> With NFSv4 generic/193 fails (but with the other issues, which
> existed even before the patch).
> 
> generic/193 expects that suid/sgid bits are cleared after the file
> truncation:
> 
> touch file
> chown fsgqa:fsgqa file
> chmod u+s file
> echo 'xyz' > file
> ls -l file
> su fsgqa -c 'echo > file'
> ls -l file
> 
> With ext4 (for example), we have expectable results:
> -rwSr--r-- 1 fsgqa fsgqa 4 Dec 11 05:21 file
> -rw-r--r-- 1 fsgqa fsgqa 1 Dec 11 05:22 file
> 
> With NFSv3 as well:
> -rwSr--r-- 1 fsgqa fsgqa 4 Dec 11 05:24 file
> -rw-r--r-- 1 fsgqa fsgqa 1 Dec 11 05:25 file
> 
> But with NFSv4 the bits are not cleared:
> -rwSr--r-- 1 fsgqa fsgqa 1 Dec 11 05:19 file
> -rwSr--r-- 1 fsgqa fsgqa 1 Dec 11 05:21 file
> 
> 'echo > file' issues:
> 
> open("file", O_WRONLY|O_CREAT|O_TRUNC, 0666)
> 
> Can it be because of design differences between NFSv3 and NFSv4?

In the v3 case I'd expect the open O_TRUNC to result in a SETATTR rpc,
in the v4 case an OPEN rpc.  Both result in a call to nfsd_setattr,
though I only see nfsd_setattr turning off the SUID/SGID bits in the
chown case.  Are you sure it isn't the subsequent write that clears
those bits?

But looks to me like nfsd_vfs_write (used in both v3 & v4 cases) clears
suid & guid, so I still don't see it.

--b.
