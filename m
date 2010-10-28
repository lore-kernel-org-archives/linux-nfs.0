Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50561 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753217Ab0J1VbO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 17:31:14 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o9SLVD9K006154
	for <linux-nfs@vger.kernel.org>; Thu, 28 Oct 2010 14:31:13 -0700 (PDT)
Subject: Re: [PATCH 1/6] NFSv4.1: Callback share session between ops
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andy Adamson <andros@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <9E0EAD33-34BB-4284-95E9-16CDC6EB0484@netapp.com>
References: <1288293001-26289-1-git-send-email-iisaman@netapp.com>
	 <1288294526.14221.18.camel@heimdal.trondhjem.org>
	 <9E0EAD33-34BB-4284-95E9-16CDC6EB0484@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Oct 2010 17:31:07 -0400
Message-ID: <1288301467.14221.32.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-10-28 at 16:18 -0400, Andy Adamson wrote:
> On Oct 28, 2010, at 3:35 PM, Trond Myklebust wrote:
> 
> > On Thu, 2010-10-28 at 15:09 -0400, Fred Isaman wrote:
> >> From: Andy Adamson <andros@netapp.com>
> >>
> >> The NFSv4.1 session found in cb_sequence needs to be shared by other
> >> callback operations in the same cb_compound.
> >> Hold a reference to the session's nfs_client throughout the  
> >> cb_compound
> >> processing.
> >
> > Wait... That isn't holding a reference. This patch ends up just  
> > taking a
> > pointer.
> 
> See comments in line. cb_sequence gets a reference to nfs_client and  
> it's (for nfsv4.1) held until nfs4_callback_compound is done  
> processing the compound.

Yes, but that doesn't offer you any guarantee that the nfs_client still
exists when you get to cb_sequence.

> > What guarantees that the session+nfs_client won't die on you
> > while you're processing the callback? Do we wait for callbacks to  
> > finish
> > before closing the session?
> 
> I think so. I'll look.

It seems to me that is a "must have" requirement.

Cheers
  Trond
