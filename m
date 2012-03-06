Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58729 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757168Ab2CFSU3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Mar 2012 13:20:29 -0500
Date: Tue, 6 Mar 2012 13:20:27 -0500
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "stable@vger.kernel.org" <stable@vger.kernel.org>
Subject: Re: [PATCH 1/3] NFSv4.1: Fix the checking of the stateid when
 returning a delegation
Message-ID: <20120306182027.GA24416@fieldses.org>
References: <1331045205-3031-1-git-send-email-andros@netapp.com>
 <1331045205-3031-2-git-send-email-andros@netapp.com>
 <1331045839.3260.8.camel@lade.trondhjem.org>
 <0A25AB17-8DC0-4524-A276-2BB1B80348C5@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <0A25AB17-8DC0-4524-A276-2BB1B80348C5@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 06, 2012 at 03:13:37PM +0000, Adamson, Andy wrote:
> 
> On Mar 6, 2012, at 9:57 AM, Myklebust, Trond wrote:
> 
> > On Tue, 2012-03-06 at 09:46 -0500, andros@netapp.com wrote:
> >> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> >> 
> >> nfs41_validate_delegation_stateid is broken if we supply a stateid with
> >> a non-zero sequence id. Instead of trying to match the sequence id,
> >> the function assumes that we always want to error. While this is
> >> true for a delegation callback, it is not true in general.
> >> 
> >> Also fix a typo in nfs4_callback_recall.
> >> 
> >> Reported-by: Andy Adamson <andros@netapp.com>
> >> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > Did you really intend to Cc: stable on these before we've committed them
> > upstream?
> 
> I guess I misunderstood when to add the Cc: stable.

Me too--I thought the stable folks would wait till they see a commit?

Though adding a Cc: line with the Signed-off-by's and leaving them out
of the email header would seem simpler.

--b.
