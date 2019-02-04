Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC0A1C282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 20:11:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A4B5220821
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 20:11:46 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727740AbfBDULq (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 15:11:46 -0500
Received: from fieldses.org ([173.255.197.46]:51814 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727692AbfBDULp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Feb 2019 15:11:45 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 7DE2B1E3A; Mon,  4 Feb 2019 15:11:45 -0500 (EST)
Date:   Mon, 4 Feb 2019 15:11:45 -0500
From:   Bruce Fields <bfields@fieldses.org>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>, simo@redhat.com
Subject: Re: [PATCH RFC 09/10] SUNRPC: Remove xdr_buf_trim()
Message-ID: <20190204201145.GF1816@fieldses.org>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195814.11389.4023.stgit@manet.1015granger.net>
 <20190204194615.GC1816@fieldses.org>
 <014F38E7-993C-4FD6-A8C6-9FE113A54A03@oracle.com>
 <20190204200044.GD1816@fieldses.org>
 <BB18AC3C-0EAA-4E63-9C87-5377070D1F4E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BB18AC3C-0EAA-4E63-9C87-5377070D1F4E@oracle.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Mon, Feb 04, 2019 at 03:07:26PM -0500, Chuck Lever wrote:
> 
> 
> > On Feb 4, 2019, at 3:00 PM, Bruce Fields <bfields@fieldses.org> wrote:
> > 
> > On Mon, Feb 04, 2019 at 02:49:11PM -0500, Chuck Lever wrote:
> >> 
> >> 
> >>> On Feb 4, 2019, at 2:46 PM, bfields@fieldses.org wrote:
> >>> 
> >>> On Fri, Feb 01, 2019 at 02:58:14PM -0500, Chuck Lever wrote:
> >>>> The key action of xdr_buf_trim() is that it shortens buf->len, the
> >>>> length of the xdr_buf' content. The other actions -- shortening the
> >>>> head, pages, and tail components -- are actually not necessary. In
> >>>> some cases, changing the size of those components corrupts the RPC
> >>>> message contained in the buffer.
> >>> 
> >>> That's really burying the lede.... Is there an actual user-visible bug
> >>> here?
> >> 
> >> I don't think so. This is more of the form:
> >> 
> >> a) the function does fundamentally the wrong thing, so
> >> 
> >> b) certain changes to this code path result is unexpected and incorrect
> >>   behavior
> >> 
> >> Thus typically only developers hacking on this code run into a problem.
> > 
> > OK, got it.  It'd help just to make it clear in the changelog that that
> > this is an accident waiting to happen rather than a current bug (as far
> > as we know).
> 
> With said improvement to the changelog, can I add your Acked-by
> when I submit this through Anna's tree?

Sure, thanks.

--b.
