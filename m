Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55774 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932105Ab0EYUhn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 May 2010 16:37:43 -0400
Date: Tue, 25 May 2010 16:37:42 -0400
To: David Greaves <david@dgreaves.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS wiki : NFSv4 Enduser doc kerberos
Message-ID: <20100525203742.GL7085@fieldses.org>
References: <4BFBCF77.2070702@dgreaves.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4BFBCF77.2070702@dgreaves.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 25, 2010 at 02:24:07PM +0100, David Greaves wrote:
> FYI I've made an attempt to update this page:
>   http://wiki.linux-nfs.org/wiki/index.php/Enduser_doc_kerberos
>
> If someone could please take a look and correct any errors I've made that 
> would be nice.
>
> Some questions:
> * should a client have an nfs/<fqdn> principal  (it works without)

I'm actually not sure what the latest client requires--I thought it
still needed some kind of machine credential on the client.

> * Is the "allow_weak_crypto=true" part still correct?

Yes, unless you're running the very latest (unreleased) upstream kernel
and nfs-utils, which includes support for stronger crypto.

--b.
