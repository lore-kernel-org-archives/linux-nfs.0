Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57696 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751437Ab3BEOnS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Feb 2013 09:43:18 -0500
Date: Tue, 5 Feb 2013 09:43:16 -0500
From: bfields <bfields@fieldses.org>
To: Tejun Heo <tj@kernel.org>
Cc: majianpeng <majianpeng@gmail.com>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsd: Fix memleak.
Message-ID: <20130205144316.GC9886@fieldses.org>
References: <201301291315585633212@gmail.com>
 <20130129222926.GA6219@fieldses.org>
 <20130204192905.GY27963@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130204192905.GY27963@mtj.dyndns.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 04, 2013 at 11:29:44AM -0800, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jan 29, 2013 at 05:29:26PM -0500, bfields wrote:
> > Tejun, maybe this could be added to your series?
> > 
> > (Or should I just take it without the idr_remove_all()?)
> 
> There are gonna be other related nfs changes anyway, so I think it
> would be better to just route it through the usual nfs channel.  We
> can deal with conflicts / conversion later.

Thanks, applying for 3.9.--b
