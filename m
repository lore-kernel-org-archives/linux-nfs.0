Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40289 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752943Ab1FKX7i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 11 Jun 2011 19:59:38 -0400
Date: Sat, 11 Jun 2011 19:59:37 -0400
To: Sid Moore <learnmost@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Question about EXCHANGE_ID on server.
Message-ID: <20110611235937.GB9246@fieldses.org>
References: <BANLkTikmtvLWVRX+wBx345QR-50P_Y_g5g@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BANLkTikmtvLWVRX+wBx345QR-50P_Y_g5g@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Jun 11, 2011 at 03:54:56PM +0800, Sid Moore wrote:
> Hi
> 
> on Linux NFSv4.1 server, nfsd4_exchange_id() is used for creating a
> new client incarnation or updating a confirmed client incarnation. if
> try to update a confirmed incarnation, EXCHGID4_FLAG_CONFIRMED_R
> should be set in eir_flags according to section 18.35.3, RFC5661.
> 
> but I found EXCHGID4_FLAG_CONFIRMED_R is cleared by "clid->flags =
> new->cl_exchange_flags;", which is in nfsd4_set_ex_flags() called by
> nfsd4_exchange_id().
> 
> so the sematics of RFC5661 is broken? am I correct?

On a quick glance.... I think you're correct.  Patch welcomed.

--b.
