Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:57405 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbbCTGuM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 20 Mar 2015 02:50:12 -0400
Date: Fri, 20 Mar 2015 07:50:10 +0100
From: Christoph Hellwig <hch@lst.de>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@sandeen.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150320065010.GC626@lst.de>
References: <20150304020826.GD19439@fieldses.org> <20150304155421.GE1627@fieldses.org> <20150304220900.GX18360@dastard> <20150304222709.GI1627@fieldses.org> <20150304224557.GY4251@dastard> <54F78BE5.1020608@sandeen.net> <20150304225623.GZ4251@dastard> <20150305040849.GJ1627@fieldses.org> <20150305131731.GA16235@lst.de> <CAB6yy341fvF8Bsg0_hViQm+zRLVdJ2WOE9duDwdU+S0CkOEpbg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAB6yy341fvF8Bsg0_hViQm+zRLVdJ2WOE9duDwdU+S0CkOEpbg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 20, 2015 at 12:06:18PM +0800, Kinglong Mee wrote:
> Maybe you want adding "trace_layout_recall_fail(&ls->ls_stid.sc_stateid);" here?
> I think the following is better,

It is!  That's indeed what I had in my old trees before the big rebase.

Can you write up a small changelog and add a signoff?

Thanks a lot!
