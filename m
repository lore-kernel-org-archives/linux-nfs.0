Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56654 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752666AbdBTPuW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 20 Feb 2017 10:50:22 -0500
Date: Mon, 20 Feb 2017 10:50:19 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>, linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@primarydata.com>
Subject: Re: [PATCH 1/6] NFSv4: fix getacl head length estimation
Message-ID: <20170220155019.GA12335@parsley.fieldses.org>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-2-git-send-email-bfields@redhat.com>
 <81d554b6-7b8d-51e8-c7ad-b23acd70f717@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <81d554b6-7b8d-51e8-c7ad-b23acd70f717@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 20, 2017 at 09:19:14PM +0800, Kinglong Mee wrote:
> On 2/19/2017 10:07, J. Bruce Fields wrote:
> > From: "J. Bruce Fields" <bfields@redhat.com>
> > 
> > Bitmap and attrlen follow immediately after the op reply header, so I'm
> > not sure what this extra "+1" was for.
...
> The +1 is set at 28f566942c "NFS: use dynamically computed compound_hdr.replen
> for xdr_inline_pages offset", 
...
> But, forget remove it at commit bf118a342f,
> "NFSv4: include bitmap in nfsv4 get acl data".
> 
> Reviewed-by: Kinglong Mee <kinglongmee@gmail.com>

Thanks for the history, and the review.  I've added a "Fixes:
bf118a342f10" line.

--b.
