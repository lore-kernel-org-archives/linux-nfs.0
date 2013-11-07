Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60726 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751405Ab3KGRGB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Nov 2013 12:06:01 -0500
Date: Thu, 7 Nov 2013 12:05:53 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Benny Halevy <bhalevy@primarydata.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: remove_stid can be incorporated into
 nfs4_put_delegation
Message-ID: <20131107170553.GD21932@fieldses.org>
References: <525CE711.1040107@primarydata.com>
 <1381820280-14120-1-git-send-email-bhalevy@primarydata.com>
 <20131104224758.GB8828@fieldses.org>
 <52786E74.8030505@primarydata.com>
 <20131107170204.GA10530@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131107170204.GA10530@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 07, 2013 at 09:02:04AM -0800, Christoph Hellwig wrote:
> On Mon, Nov 04, 2013 at 08:05:08PM -0800, Benny Halevy wrote:
> > On 2013-11-04 14:47, J. Bruce Fields wrote:
> > > On Tue, Oct 15, 2013 at 09:58:00AM +0300, Benny Halevy wrote:
> > >> All calls to nfs4_put_delegation are preceded with remove_stid.
> > > 
> > > Whoops, no, we missed the nfs4_put_delegation call in
> > > fs/nfsd/nfs4callback.c.
> > > 
> > > Noticed because some pynfs tests triggered idr warnings about freeing
> > > the same id twice.
> > > 
> > > I guess I'll revert.
> > 
> > OK.
> 
> Not sure which patch in your submitted series it was, but with the
> whole series xfstests on NFS 4.1 crashed and burned early on.  I'd
> recommend you run xfstests to test any future changes to the state
> handling code in nfsd.

What did you run it on exactly?  (One of my branches or one of Benny's?)

I keep saying I should do regular xfstest runs and keep not doing it.
Do you have a sample commandline to share for nfs testing?

--b.
