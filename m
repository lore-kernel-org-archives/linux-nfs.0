Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49064 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751170AbdBWTnY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Feb 2017 14:43:24 -0500
Date: Thu, 23 Feb 2017 14:43:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: Weston Andros Adamson <dros@primarydata.com>,
        Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>,
        Weston Andros Adamson <dros@netapp.com>
Subject: Re: [PATCH 2/6] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Message-ID: <20170223194321.GF9417@parsley.fieldses.org>
References: <1487470070-32358-1-git-send-email-bfields@redhat.com>
 <1487470070-32358-3-git-send-email-bfields@redhat.com>
 <261D4020-D9E4-4F1E-81CF-11EAAEABA684@primarydata.com>
 <20170222223656.GG24122@parsley.fieldses.org>
 <6606b2d5-719f-9e27-6f95-eec8cebfb1a8@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6606b2d5-719f-9e27-6f95-eec8cebfb1a8@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 23, 2017 at 09:55:35AM -0500, Anna Schumaker wrote:
> 
> 
> On 02/22/2017 05:36 PM, J. Bruce Fields wrote:
> > On Tue, Feb 21, 2017 at 07:46:58PM +0000, Weston Andros Adamson wrote:
> >>
> >>> On Feb 18, 2017, at 9:07 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> >>>
> >>> From: Weston Andros Adamson <dros@netapp.com>
> >>>
> >>> We're not taking into account that the space needed for the (variable
> >>> length) attr bitmap, with the result that we'd sometimes get a spurious
> >>> ERANGE when the ACL data got close to the end of a page.
> >>>
> >>> Just add in an extra page to make sure.
> >>>
> >>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> >>
> >> Thanks, you can add:
> >>
> >> Signed-off-by: Weston Andros Adamson <dros@primarydata.com>
> > 
> > Thanks.
> > 
> > Anna, could we get this one in now?
> > 
> > The rest of it still needs some work to account for the problem Andreas
> > notes (where we can return a length successfully even though we'll never
> > accept an ACL of that length).  But this one is an easy fix for a real
> > bug.
> > 
> > Let me know if you need it resent.
> 
> I don't mind taking just the one patch.  Have you made any changes to it since this posting?  If not, then I can take it from the email.

Just Dros's signoff.  Actually, we should probably take the first two.
I'll resend them just to make sure.

--b.
