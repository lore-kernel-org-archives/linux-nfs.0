Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:40722 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751392AbbJWUFP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Oct 2015 16:05:15 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Andreas Gruenbacher'" <agruenba@redhat.com>,
        "'Alexander Viro'" <viro@zeniv.linux.org.uk>,
        "'Theodore Ts'o'" <tytso@mit.edu>,
        "'Andreas Dilger'" <adilger.kernel@dilger.ca>,
        "'J. Bruce Fields'" <bfields@fieldses.org>,
        "'Jeff Layton'" <jlayton@poochiereds.net>,
        "'Trond Myklebust'" <trond.myklebust@primarydata.com>,
        "'Anna Schumaker'" <anna.schumaker@netapp.com>,
        "'Dave Chinner'" <david@fromorbit.com>, <linux-ext4@vger.kernel.org>,
        <xfs@oss.sgi.com>, <linux-kernel@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <linux-cifs@vger.kernel.org>, <linux-api@vger.kernel.org>
References: <1445625722-13791-1-git-send-email-agruenba@redhat.com>
In-Reply-To: <1445625722-13791-1-git-send-email-agruenba@redhat.com>
Subject: RE: [PATCH v12 00/49] Richacls
Date: Fri, 23 Oct 2015 13:03:59 -0700
Message-ID: <002f01d10dcd$f5f9f170$e1edd450$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Andreas Gruenbacher:
> 
> Here is another update of the richacl patch queue.  I would like to ask
for
> feedback so that the core and local filesystem code (patches 1-25) can be
> merged in the 4.4 merge window.
> 
> Changes since the last posting (http://lwn.net/Articles/661078/):
> 
>  * On ext4, filesystems with the richacl feature can no longer be mounted
>    with -o noacl; richacls cannot be turned off.
> 
>  * XFS was listing richacl xattrs as "trusted.system.richacl"; this has
>    been fixed.
> 
>  * Some definitions have been moved from include/linux/ to
>    include/uapi/linux/.  The license of the uapi headers has been changed
>    to LGPL.

Thanks for that last. I kept meaning to ask about that for cleaner use in
Ganesha.

Frank



---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus

