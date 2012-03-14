Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:35016 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208Ab2CNFPR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Mar 2012 01:15:17 -0400
Date: Wed, 14 Mar 2012 05:15:09 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfs-obj: Uglify objio_segment allocation for the sake
 of the principle :-(
Message-ID: <20120314051509.GH23916@ZenIV.linux.org.uk>
References: <4F60141A.709@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F60141A.709@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 13, 2012 at 08:44:26PM -0700, Boaz Harrosh wrote:
> +/*	This is the in memory structure of the objio_segment
> + *
> + *	struct __alloc_objio_segment {
> + *		struct objio_segment olseg;
> + *		struct ore_dev *ods[numdevs];
> + *		struct ore_comp	comps[numdevs];
> + *	} *aolseg;
> + *	NOTE: The code as above compiles and runs perfectly. It is elegant,
> + *	type safe and compact.

In which type system?  Not C99 - there variably-modified types are not
allowed as structure or union members...
