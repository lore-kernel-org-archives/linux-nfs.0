Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48752 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754057Ab1HZX5e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Aug 2011 19:57:34 -0400
Date: Fri, 26 Aug 2011 19:57:31 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD: nfsd4_open Avoid race with grace period
 expiration
Message-ID: <20110826235731.GE18699@fieldses.org>
References: <4E45C164.1070604@panasas.com>
 <20110826203924.GC17196@fieldses.org>
 <4E58119A.3090403@panasas.com>
 <20110826215451.GF16090@pad.fieldses.org>
 <4E583292.1070707@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E583292.1070707@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Aug 26, 2011 at 04:56:02PM -0700, Boaz Harrosh wrote:
> On 08/26/2011 02:54 PM, J. Bruce Fields wrote:
> > On Fri, Aug 26, 2011 at 02:35:22PM -0700, Boaz Harrosh wrote:
> > 
> > 
> > If it's really necessary then maybe do it with printk_once().
> > 
> > Which clients are you worried about exactly?
> > 
> 
> I'm afraid of Server bugs, actually, as demonstrated lately.

OK.

> I'll summit a patch that atleast does a dprint to help
> someone that tries to debug his problems.

Sounds fine.

--b.
