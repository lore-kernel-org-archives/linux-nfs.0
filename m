Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35841 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846Ab1CQRSe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 13:18:34 -0400
Date: Thu, 17 Mar 2011 13:18:31 -0400
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Use of READDIRPLUS on large directories
Message-ID: <20110317171831.GA30180@fieldses.org>
References: <20110316155528.31913c58@notabene.brown>
 <24085EE6-EF0B-4F36-8F6A-100AB863F408@oracle.com>
 <4D80C5C6.2060003@netapp.com>
 <1300285203.16266.46.camel@lade.trondhjem.org>
 <20110317083034.479ecb5f@notabene.brown>
 <1300311755.30551.17.camel@lade.trondhjem.org>
 <20110317094019.23f31f53@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110317094019.23f31f53@notabene.brown>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 17, 2011 at 09:40:19AM +1100, NeilBrown wrote:
> On Wed, 16 Mar 2011 17:42:35 -0400 Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> 
>  
> > > So it is obvious that there is sometimes value in using readdirplus,
> > > it is equally obvious that there is sometimes a cost.
> > > 
> > > Switching the default from "not paying the cost when it is big" to
> > > "always paying the cost" is wrong.
> > 
> > That's what the nordirplus mount flag is for. Keeping an arbitrary limit
> > in the face of evidence that it is hurting is equally wrong.
> > 
> 
> If people didn't need 'nordirplus' previously to get acceptable
> performance, and do need it now, then that is a regression.

Agreed.

Unfortunately, reversion at this point would also be a regression for a
different group of folks.  A smaller one, since *their* problem was
fixed only more recently, but still there's probably no sensible way out
of this but forwards....

--b.
