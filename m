Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54908 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759698Ab3BYUwS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Feb 2013 15:52:18 -0500
Date: Mon, 25 Feb 2013 15:52:16 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Mark Lord <kernel@start.ca>
Cc: Mark Lord <kernel@teksavvy.com>, linux-nfs@vger.kernel.org,
        Linux Kernel <linux-kernel@vger.kernel.org>
Subject: Re: BUG at net/sunrpc/svc_xprt.c:921
Message-ID: <20130225205216.GB26298@fieldses.org>
References: <50F42F85.50907@teksavvy.com>
 <50F7F898.5050605@teksavvy.com>
 <20130117135333.GF6598@fieldses.org>
 <512BCD53.8070904@start.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <512BCD53.8070904@start.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 25, 2013 at 03:45:07PM -0500, Mark Lord wrote:
> On 13-01-17 08:53 AM, J. Bruce Fields wrote:
> > On Thu, Jan 17, 2013 at 08:11:52AM -0500, Mark Lord wrote:
> >> On 13-01-14 11:17 AM, Mark Lord wrote:
> >>>
> >>> Here's the code with the BUG() at net/sunrpc/svc_xprt.c line 921:
> >>>
> >>> /*
> >>>  * Remove a dead transport
> >>>  */
> >>> static void svc_delete_xprt(struct svc_xprt *xprt)
> >>> {
> >>>         struct svc_serv *serv = xprt->xpt_server;
> >>>         struct svc_deferred_req *dr;
> >>>
> >>>         /* Only do this once */
> >>>         if (test_and_set_bit(XPT_DEAD, &xprt->xpt_flags))
> >>>                 BUG();
> >>
> 
> Saw this again today on 3.7.9 -- dunno if your changes are in that kernel yet though.

Nope.  The nfsd changes for 3.9 should get merged in a few days and then
backported to stable kernels not much later.

--b.
