Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56707 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752581Ab0JAWFY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 Oct 2010 18:05:24 -0400
Date: Fri, 1 Oct 2010 18:05:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd4: adjust buflen for encoded attrs bitmap
 based on actual bitmap length
Message-ID: <20101001220508.GF1472@fieldses.org>
References: <1285872466-21013-1-git-send-email-bhalevy@panasas.com>
 <20101001145018.GD17310@fieldses.org>
 <4CA5FBAB.2040309@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4CA5FBAB.2040309@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Oct 01, 2010 at 05:18:03PM +0200, Benny Halevy wrote:
> On 2010-10-01 16:50,  J. Bruce Fields wrote:
> > On Thu, Sep 30, 2010 at 08:47:46PM +0200, Benny Halevy wrote:
> >> The existing code adjusted it based on the worst case scenario for the returned
> >> bitmap and the best case scenario for the supported attrs attribute.
> > 
> > Looks fine, thanks.  Mind if I just ditch the unlikely()s?  I know,
> > they've been there for a while, but I'm just skeptical of their value on
> > anything but the most unbelievably hot optimized-to-death code paths.
> 
> Well, they don't bother me so I don't the value of ditching them either :)

For me it's an infinitessimal optimization versus a very minor
improvement in readability.

Admittedly my scales of judgement may not be fine enough to correctly
balance such small quantities....

Anyway, applied without annotations; thanks.

--b.

> 
> They're supposed to help branch prediction thus optimizing the common
> code paths on the expense of the unlikely path but I too didn't measure
> their affect.
> 
> Bottom line is that I don't have and strong reservations either for or
> against them in this case :)
