Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46683 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754478Ab2IQQv1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 12:51:27 -0400
Date: Mon, 17 Sep 2012 12:51:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: readdir cookies
Message-ID: <20120917165126.GL30673@fieldses.org>
References: <20120917155426.GK30673@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FC8D4C@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FC8D4C@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 17, 2012 at 04:05:10PM +0000, Myklebust, Trond wrote:
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> > Sent: Monday, September 17, 2012 11:54 AM
> > To: Myklebust, Trond; Schumaker, Bryan
> > Cc: linux-nfs@vger.kernel.org
> > Subject: readdir cookies
> > 
> > How does the nfs client decide what directory cookies to return?  (As the
> > d_off field to readdir, for example).
> > 
> > I'd assumed it would return the server's cookie, but testing shows it returns a
> > simple integer sequence.
> 
> We cache the cookies and use them to figure out where the readdir cursor is after a directory update, but we use positive integers for telldir()/seekdir(). The reason is that too many servers return cookies that use > 32 bits (NFSv2-incompatible) or are unsigned.

Ok--so the tradeoff is that telldir/seekdir cookies may not be good
indefinitely?

--b.
