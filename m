Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fn.samba.org ([216.83.154.106]:33919 "EHLO mail.samba.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757928AbbEWPvB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 23 May 2015 11:51:01 -0400
Date: Sat, 23 May 2015 08:50:56 -0700
From: Jeremy Allison <jra@samba.org>
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-api@vger.kernel.org,
        samba-technical@lists.samba.org, linux-security-module@vger.kernel.org
Subject: Re: [RFC v3 00/45] Richacls
Message-ID: <20150523155056.GA2845@jeremy-HP>
Reply-To: Jeremy Allison <jra@samba.org>
References: <cover.1429868795.git.agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <cover.1429868795.git.agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2015 at 01:03:57PM +0200, Andreas Gruenbacher wrote:
> Hello,
> 
> here's another update of the richacl patch queue.  The changes since the last
> posting (https://lwn.net/Articles/638242/) include:
> 
>  * The nfs client now allocates pages for received acls on demand like the
>    server does.  It no longer caches the acl size between calls.
> 
>  * All possible acls consisting of only owner@, group@, and everyone@ entries
>    which are equivalent to the file mode permission bits are now recognized.
>    This is needed because by the NFSv4 specification, the nfs server must
>    translate the file mode permission bits into an acl if it supports acls at
>    all.
> 
>  * Support for the dacl attribute over NFSv4.1 for Automatic Inheritance, and
>    also for the write_retention and write_retention_hold permissions.
> 
>  * The richacl_compute_max_masks() documentation has been improved.
> 
>  * Various minor bug fixes.
> 
> The git version is available here:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/agruen/linux-richacl.git \
> 	richacl-2015-04-24

FYI. I have a mostly (needs test suite adding) working module
for Samba for Andreas's richacls code.

Using it we map incoming Windows ACLs directly to richacls
using the same mapping as we use for existing ZFS ACLs.

Jeremy.
