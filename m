Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dsl-67-204-24-19.acanac.net ([67.204.24.19]:50313 "EHLO
	mail.ellipticsemi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751857Ab0KDS6F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Nov 2010 14:58:05 -0400
Date: Thu, 4 Nov 2010 14:57:05 -0400
From: Nick Bowler <nbowler@elliptictech.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Andi Kleen <andi@firstfloor.org>, bjschuma@netapp.com,
        torvalds@linux-foundation.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [regression] NFS readdir change break fully cached nfs root
Message-ID: <20101104185705.GA3778@elliptictech.com>
References: <20101102180051.GA26089@basil.fritz.box>
 <1288731930.534.1.camel@heimdal.trondhjem.org>
 <20101103162423.GA3797@elliptictech.com>
 <1288886814.3285.5.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1288886814.3285.5.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-11-04 12:06 -0400, Trond Myklebust wrote:
> On Wed, 2010-11-03 at 12:24 -0400, Nick Bowler wrote:
> > I applied this patch, and it solves the lockups, but there's a new
> > problem: the directory list sometimes comes back _empty_!
[...]
> I found a couple more issues. Can you try this revision of the same
> patch?
[...]
> NFS: Fix a couple of regressions in readdir.

Unfortunately, I still have the same problem (listing comes back empty
after running the script) with the new patch.

-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
