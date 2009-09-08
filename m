From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH 0/5] NFSv4.1 DRC rewrite version 6
Date: Tue, 8 Sep 2009 10:43:08 -0400
Message-ID: <20090908144308.GD22120@fieldses.org>
References: <1251389264-3009-1-git-send-email-andros@netapp.com> <20090828224247.GG2462@fieldses.org> <20090828225608.GH2462@fieldses.org> <20090828230727.GI2462@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43745 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750843AbZIHOnG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Sep 2009 10:43:06 -0400
In-Reply-To: <20090828230727.GI2462@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 28, 2009 at 07:07:27PM -0400, bfields wrote:
> On Fri, Aug 28, 2009 at 06:56:08PM -0400, bfields wrote:
> > On Fri, Aug 28, 2009 at 06:42:48PM -0400, J. Bruce Fields wrote:
> > > By the way, any hints on getting the 4.1 pynfs stuff running?
> > 
> > OK, solution seemed to be
> > 
> > 	cd gssapi
> > 	python setup.py build_ext --inplace
> > 
> > But now almost everything fails.with SERVERFAULT.  Bah.
> 
> Does anyone have a list of which tests are expected to pass at this point?  If
> I ask for "all" tests, I get "4 skipped, 103 failed, 0 warned, 26 passed--full
> list available if anyone wants.  I seem to be passing connectathon tests
> OK over 4.1.

If someone could just send a copy of what they consider succesful (for
now) pynfs output, that would be useful.

--b.
