Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34998 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756718Ab0JAVUb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 17:20:31 -0400
Date: Fri, 1 Oct 2010 17:20:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: spkm3 removal
Message-ID: <20101001212014.GC1472@fieldses.org>
References: <20101001195150.GB1472@fieldses.org>
 <1285963891.4391.0.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1285963891.4391.0.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Oct 01, 2010 at 04:11:31PM -0400, Trond Myklebust wrote:
> On Fri, 2010-10-01 at 15:51 -0400, J. Bruce Fields wrote:
> > Shall we go ahead and remove this?
> > 
> > Somebody stumbled across a security problem in the spkm3 code
> > recently--unexploitable, as far as I can tell, since you'd need an spkm3
> > context first, and those are hard to come by....  But I feel a little
> > bad leaving this code around for innocent bystanders to waste their time
> > auditing.
> 
> Agreed. Let's get rid of it.

OK, I'll give it a little more time in case anyone wants to make a case
for spkm3, then queue it up for 2.6.37--and maybe adding it to -next
will get me some email telling me what I should have done about the
defconfigs....

--b.
