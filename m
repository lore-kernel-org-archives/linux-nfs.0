Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40707 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324AbaFBWMP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Jun 2014 18:12:15 -0400
Date: Mon, 2 Jun 2014 18:12:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        "Frank S. Filz" <ffilzlnx@mindspring.com>
Subject: Re: [PATCH 41/52] nfsd4: turn off zero-copy-read in exotic cases
Message-ID: <20140602221209.GB24103@fieldses.org>
References: <1400787148-25941-1-git-send-email-bfields@redhat.com>
 <1400787148-25941-42-git-send-email-bfields@redhat.com>
 <20140528080945.GA6797@infradead.org>
 <20140528140151.GB13012@pad.redhat.com>
 <20140528210858.GF22210@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140528210858.GF22210@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 28, 2014 at 05:08:59PM -0400, bfields wrote:
> On Wed, May 28, 2014 at 10:01:52AM -0400, J. Bruce Fields wrote:
> > On Wed, May 28, 2014 at 01:09:45AM -0700, Christoph Hellwig wrote:
> > > On Thu, May 22, 2014 at 03:32:16PM -0400, J. Bruce Fields wrote:
> > > > Later patches handle those "exotic compounds", this one just makes sure
> > > > zero-copy is turned off in those cases.
> > > 
> > > How did you test these exotic compounds?
> > 
> > I have is a pynfs test that sends a compound with multiple reads in it.
> 
> But, look, it wasn't turned on in my regular tests so, surprise, I
> regressed recently without noticing; I intend to fold in the below after
> some more testing.
> 
> > I don't think that's pushed out to my regular pynfs tree, I'll try to do
> > that today.
> 
> Still working on that.

I've pushed out some minimal tests of the new xdr code to

	git://linux-nfs.org/~bfields/pynfs.git master

Frank, some of those might not really be appropriate for any server, I'm
not sure.

--b.
