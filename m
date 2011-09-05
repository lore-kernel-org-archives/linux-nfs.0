Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from nm7-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.192]:39850 "HELO
	nm7-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751867Ab1IEWmU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Sep 2011 18:42:20 -0400
Message-ID: <4E655049.6060507@schaufler-ca.com>
Date: Mon, 05 Sep 2011 15:42:17 -0700
From: Casey Schaufler <casey@schaufler-ca.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
CC: agruen@kernel.org, bfields@fieldses.org, akpm@linux-foundation.org,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        LSM <linux-security-module@vger.kernel.org>,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH -V6 00/26]  New ACL format for better NFSv4 acl interoperability
References: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1315243548-18664-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 9/5/2011 10:25 AM, Aneesh Kumar K.V wrote:
> Hi,
>
> The following set of patches implements VFS and ext4 changes needed to implement
> a new acl model for linux. Rich ACLs are an implementation of NFSv4 ACLs,
> extended by file masks to fit into the standard POSIX file permission model.
> They are designed to work seamlessly locally as well as across the NFSv4 and
> CIFS/SMB2 network file system protocols.

POSIX ACLs predate the LSM and can't be done as an LSM due to
the interactions between mode bits and ACLs as defined by the
POSIX DRAFT specification. Is there a reason that "rich" ACLs
can not be done as an LSM?

>
> A user-space utility for displaying and changing richacls is available at [4]
> (a number of examples can be found at http://acl.bestbits.at/richacl/examples.html).
>
> [4] git://git.kernel.org/pub/scm/fs/acl/kvaneesh/richacl.git master
>
> To test richacl on ext4 use -o richacl mount option. This mount option may later be
> dropped in favour of a feature flag.
>
> More details regarding richacl can be found at
> http://acl.bestbits.at/richacl/
>
> Changes from v5:
> a) rebase to v3.1-rc4-131-g9e79e3e
>
> NOTE: The kernel changes will be pushed to
> git://git.kernel.org/pub/scm/linux/kernel/git/kvaneesh/linux-richacl.git richacl
> when kernel.org is back
>
> -aneesh
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-ext4" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

