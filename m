Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34957 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752654Ab0FWSqW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jun 2010 14:46:22 -0400
Date: Wed, 23 Jun 2010 14:46:20 -0400
To: Yudong Gao <stgyd@umich.edu>
Cc: Benny Halevy <bhalevy@panasas.com>, linux-nfs@vger.kernel.org
Subject: Re: Supported cluster file system in v4.1
Message-ID: <20100623184620.GD28346@fieldses.org>
References: <AANLkTilWpNghO37nF9Cmu3F7SxcHU2AI8hKyeDvNSi8d@mail.gmail.com> <4C21AE7F.9080103@panasas.com> <AANLkTimvyf-KbN-XWkawxp3SHG_WgHJ_sBXnlJjWMIjM@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTimvyf-KbN-XWkawxp3SHG_WgHJ_sBXnlJjWMIjM@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jun 23, 2010 at 10:14:09AM -0700, Yudong Gao wrote:
> Hi Benny,
> 
> Thanks a lot for the reply! I will check exofs.
> 
> We are looking for a block-based cluster file system that can be
> deployed on top of a cluster of commodity machines and can use the
> machines' local storage instead of using a SAN. We find that OCFS2 is
> a good candidate.

As far as I can tell OCFS2 and GFS2 are identical in their requirement
for a shared disk.

--b.

> Is it possible to use OCFS2 as the storage server in
> pNFS?
