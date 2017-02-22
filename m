Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43416 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933234AbdBVWhA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 22 Feb 2017 17:37:00 -0500
Date: Wed, 22 Feb 2017 17:36:57 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@netapp.com>
Subject: Re: [PATCH 2/6] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Message-ID: <20170222223656.GG24122@parsley.fieldses.org>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-3-git-send-email-bfields@redhat.com>
 <261D4020-D9E4-4F1E-81CF-11EAAEABA684@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <261D4020-D9E4-4F1E-81CF-11EAAEABA684@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 21, 2017 at 07:46:58PM +0000, Weston Andros Adamson wrote:
> 
> > On Feb 18, 2017, at 9:07 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > 
> > From: Weston Andros Adamson <dros@netapp.com>
> > 
> > We're not taking into account that the space needed for the (variable
> > length) attr bitmap, with the result that we'd sometimes get a spurious
> > ERANGE when the ACL data got close to the end of a page.
> > 
> > Just add in an extra page to make sure.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> Thanks, you can add:
> 
> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>

Thanks.

Anna, could we get this one in now?

The rest of it still needs some work to account for the problem Andreas
notes (where we can return a length successfully even though we'll never
accept an ACL of that length).  But this one is an easy fix for a real
bug.

Let me know if you need it resent.

--b.
