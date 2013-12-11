Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:42774 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882Ab3LKLBA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Dec 2013 06:01:00 -0500
Message-ID: <52A845C6.2080109@oracle.com>
Date: Wed, 11 Dec 2013 15:00:22 +0400
From: Stanislav Kholmanskikh <stanislav.kholmanskikh@oracle.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
CC: vasily.isaenko@oracle.com, hch@infradead.org, xfs@oss.sgi.com,
        sprabhu@redhat.com, bfields@fieldses.org
Subject: Re: [PATCH] nfsd: revoking of suid/sgid bits after chown() in a consistent
 way
References: <20131206204747.GB12613@fieldses.org> <1386756996-28083-1-git-send-email-stanislav.kholmanskikh@oracle.com>
In-Reply-To: <1386756996-28083-1-git-send-email-stanislav.kholmanskikh@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/11/2013 02:16 PM, Stanislav Kholmanskikh wrote:
[cut off]
>
> This patch makes NFS to behave like local file systems.
>
[cut off]

This patch allows to run generic/193 without any issues with NFSv3.

With NFSv4 generic/193 fails (but with the other issues, which existed 
even before the patch).

generic/193 expects that suid/sgid bits are cleared after the file 
truncation:

touch file
chown fsgqa:fsgqa file
chmod u+s file
echo 'xyz' > file
ls -l file
su fsgqa -c 'echo > file'
ls -l file

With ext4 (for example), we have expectable results:
-rwSr--r-- 1 fsgqa fsgqa 4 Dec 11 05:21 file
-rw-r--r-- 1 fsgqa fsgqa 1 Dec 11 05:22 file

With NFSv3 as well:
-rwSr--r-- 1 fsgqa fsgqa 4 Dec 11 05:24 file
-rw-r--r-- 1 fsgqa fsgqa 1 Dec 11 05:25 file

But with NFSv4 the bits are not cleared:
-rwSr--r-- 1 fsgqa fsgqa 1 Dec 11 05:19 file
-rwSr--r-- 1 fsgqa fsgqa 1 Dec 11 05:21 file

'echo > file' issues:

open("file", O_WRONLY|O_CREAT|O_TRUNC, 0666)

Can it be because of design differences between NFSv3 and NFSv4?

Thank you.
