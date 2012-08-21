Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45707 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758482Ab2HUVmf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 17:42:35 -0400
Date: Tue, 21 Aug 2012 17:42:33 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/14] svcrpc: ignore unknown address type in udp
 receive
Message-ID: <20120821214233.GA19185@fieldses.org>
References: <1345582652-18476-1-git-send-email-bfields@redhat.com>
 <1345582652-18476-9-git-send-email-bfields@redhat.com>
 <05C6926C-B688-4A71-AA1C-26F251BBD635@oracle.com>
 <20120821212431.GC18637@fieldses.org>
 <822DBA73-7B4C-43CC-B096-9D8B4A219390@oracle.com>
 <20120821213352.GE18637@fieldses.org>
 <E2217068-BD91-4428-913A-4CDA910250AE@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E2217068-BD91-4428-913A-4CDA910250AE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 21, 2012 at 05:38:26PM -0400, Chuck Lever wrote:
> 
> On Aug 21, 2012, at 5:33 PM, J. Bruce Fields wrote:
> 
> > On Tue, Aug 21, 2012 at 05:29:16PM -0400, Chuck Lever wrote:
> >> 
> >> On Aug 21, 2012, at 5:24 PM, J. Bruce Fields wrote:
> >> 
> >>> On Tue, Aug 21, 2012 at 05:02:14PM -0400, Chuck Lever wrote:
> >>>> 
> >>>> On Aug 21, 2012, at 4:57 PM, J. Bruce Fields wrote:
> >>>> 
> >>>>> From: "J. Bruce Fields" <bfields@redhat.com>
> >>>>> 
> >>>>> How would this happen?
> >>>> 
> >>>> If an unsupported address family is used in the rqstp.
> >>> 
> >>> Right, but that's impossible, isn't it?
> >> 
> >> The point is to catch this case when someone adds support for new address families.  It won't happen in current code.
> >> 
> >>>>> In any case, it appears this would be returned all the way up to the
> >>>>> caller of svc_recv(), and it's obvious that none of them are equipped to
> >>>>> handle it, and not clear what they would want to do with it anyway.
> >>>>> Let's just drop this and return -EAGAIN.
> >>>> 
> >>>> EAGAIN is incorrect; the correct error code is EAFNOSUPPORT.  If callers are not prepared for this error return, perhaps BUG_ON() would be more appropriate here.
> >>> 
> >>> Yeah.  Actually on a quick check this is the only caller that even
> >>> checks for this case.  So probably the check should go in svc_addr_len.
> >>> Maybe we should be nice and make it a warning.
> >> 
> >> I normally find BUG pretty harsh, but in this case it's true a software error, and as you say, should be "impossible": thus it should be a BUG.  The code should stop before the zero length is used.
> > 
> > Eh, OK, I guess I can live with that.
> > 
> > commit 751f877b10f8ce0d12b40d2a102f3b42b26dc08d
> > Author: J. Bruce Fields <bfields@redhat.com>
> > Date:   Tue Aug 21 17:22:11 2012 -0400
> > 
> >    svcrpc: don't bother checking bad svc_addr_len result
> > 
> >    None of the callers should see an unsupported address family (only one
> >    of them even bothers to check for that case), so just check for the
> >    buggy case in svc_addr_len and don't bother elsewhere.
> > 
> >    Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> Acked-by: Chuck Lever <chuck.lever@oracle.com>

Ok, thanks.--b.
