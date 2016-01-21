Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:48703 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751391AbcAUTfB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jan 2016 14:35:01 -0500
Date: Thu, 21 Jan 2016 14:34:59 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: David Binderman <dcb314@hotmail.com>
Cc: "jlayton@poochiereds.net" <jlayton@poochiereds.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: linux-4.4/net/sunrpc/auth_gss/gss_krb5_mech.c:296: Undefined
 Behaviour
Message-ID: <20160121193459.GC1793@fieldses.org>
References: <DUB128-W91EBE8E198A948D174CCC9CCF0@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <DUB128-W91EBE8E198A948D174CCC9CCF0@phx.gbl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 17, 2016 at 08:31:54PM +0000, David Binderman wrote:
> [linux-4.4/net/sunrpc/auth_gss/gss_krb5_mech.c:296]: (warning) Invalid test for overflow 'p+20<p'. Condition is always false unless there is overflow, and overflow is Undefined Behaviour.
> 
> Source code is
> 
>    if (unlikely(p + 20> end || p + 20 < p)) {

Looks like we make that assumption all over; e.g. see the checks in
xdr_reserve_space and __xdr_inline_decode.  I guess that should be

	if (unlikely(end - p < 20))

?

What's the practical effect right now?  (E.g. does gcc actually violate
our assumption here currently?)

--b.
