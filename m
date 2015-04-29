Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43557 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966088AbbD2OYi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Apr 2015 10:24:38 -0400
Date: Wed, 29 Apr 2015 10:24:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: sachin@primarydata.com
Cc: Jeff Layton <jeff.layton@primarydata.com>, Christoph Hellwig <hch@lst.de>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: two odstate optimizations
Message-ID: <20150429142437.GD16016@fieldses.org>
References: <1430222449-3921-1-git-send-email-hch@lst.de>
 <20150428085006.7d4b9708@tlielax.poochiereds.net>
 <CANMZn7___SXopxOB-dO0fBj3keVrkXOTwLaYPazzVLHGtgLvPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CANMZn7___SXopxOB-dO0fBj3keVrkXOTwLaYPazzVLHGtgLvPw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 29, 2015 at 01:26:15AM -0700, Sachin Bhamare wrote:
> On Tue, Apr 28, 2015 at 5:50 AM, Jeff Layton <jeff.layton@primarydata.com>
> wrote:
> 
> > On Tue, 28 Apr 2015 14:00:47 +0200
> > Christoph Hellwig <hch@lst.de> wrote:
> >
> > > Two small optimizations for the odstate handling.  Feel free to squash
> > them
> > > into "nfsd: fix pNFS return on close semantics" if you need to rebase
> > anyway.
> > >
> >
> > Both look good to me!
> >
> > Acked-by: Jeff Layton <jeff.layton@primarydata.com>
> >
> 
> ​For both patches :
> 
> Acked-by: Sachin Bhamare <sachin.bhamare@primarydata.com>
> ​

Thanks.--b.
