Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 1wt.eu ([62.212.114.60]:36753 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360Ab2LNHUo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Dec 2012 02:20:44 -0500
Date: Fri, 14 Dec 2012 08:17:11 +0100
From: Willy Tarreau <w@1wt.eu>
To: Jonathan Nieder <jrnieder@gmail.com>
Cc: stable@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Jeff Layton <jlayton@redhat.com>, Chuck Lever <chuck.lever@oracle.com>,
        Tom Downes <tpdownes@gravity.phys.uwm.edu>
Subject: Re: [2.6.32.y, 2.6.34.y] Re: kernel panic when mount NFSv4
Message-ID: <20121214071711.GB30478@1wt.eu>
References: <4D0731C1.5090100@cn.fujitsu.com> <1292879966.7744.4.camel@heimdal.trondhjem.org> <20121214053958.GA4002@elie.Belkin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121214053958.GA4002@elie.Belkin>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jonathan,

On Thu, Dec 13, 2012 at 09:39:58PM -0800, Jonathan Nieder wrote:
> Hi Willy et al,
> 
> Please consider
> 
>   beb0f0a9fba1 kernel panic when mount NFSv4, 2010-12-20
> 
> for application to kernel.org's 2.6.32.y and 2.6.34.y trees.  The
> patch was applied upstream during the 2.6.38 merge window, so newer
> kernels don't need it.
> 
> (Context: <http://bugs.debian.org/695872>.)  Tom Downes (cc-ed)
> experienced the bug on a Debian kernel close to 2.6.32.58 and
> confirmed that the patch doesn't seem to hurt.
> 
> The patch is part of Fedora 13's 2.6.34-based and Fedora 14's
> 2.6.35-based kernels[1].  It was also included in the RHEL kernel at
> some point between 2.6.32-71.29.1.el6 and 2.6.32-131.0.15.el6[2].
> 
> Thoughts of all kinds welcome, as always.

Thank you for all the details, as always :-)

I'm queuing this patch for 2.6.32.61.

Best regards,
Willy

