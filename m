From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] Fix race corrupting rpc upcall list
Date: Tue, 07 Sep 2010 14:23:32 -0400
Message-ID: <1283883812.2788.50.camel@heimdal.trondhjem.org>
References: <20100828170953.GB5104@fieldses.org>
	 <20100830175728.GA18764@fieldses.org> <20100907050142.GA14584@fieldses.org>
	 <20100907051241.GB14584@fieldses.org> <20100907051336.GC14584@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42112 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932480Ab0IGSYD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 14:24:03 -0400
In-Reply-To: <20100907051336.GC14584@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2010-09-07 at 01:13 -0400, J. Bruce Fields wrote:
> After those two patches I can finally pass connectathon tests on 2.6.36.
> (Argh.)
> 
> --b.

OK. Both applied
