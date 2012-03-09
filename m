Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42609 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755569Ab2CIVys (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 16:54:48 -0500
Date: Fri, 9 Mar 2012 16:54:46 -0500
To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Cc: Simo Sorce <simo@redhat.com>, steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/7] Kill SPKM3 auth method
Message-ID: <20120309215446.GA22068@fieldses.org>
References: <1331322586-4631-1-git-send-email-simo@redhat.com>
 <4F5A76CD.9080809@fifthhorseman.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F5A76CD.9080809@fifthhorseman.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 09, 2012 at 04:31:57PM -0500, Daniel Kahn Gillmor wrote:
> On 03/09/2012 02:49 PM, Simo Sorce wrote:
> >This authentication method is obsolete and it is time it dies for good.
> 
> Can i ask what it has been obsoleted by?

I think pku2u?  Someone who's following that effort will have to comment
on how far along it is.

> Neither https://tools.ietf.org/html/rfc2025 [SPKM] nor
> https://tools.ietf.org/html/rfc2847 [LIPKEY] seem to suggest an
> inheritor, and kerberos5 does not provide direct public-key-based
> authentication (it's still reliant on an active and trusted
> third-party).
> 
> So it seems like SPKM and LIPKEY offer a cryptographic model that is
> otherwise unavailable for authentication between NFS endpoints.

Understood that people would like such a thing, but alas spkm3 and
lipkey never quite managed to provide it.

--b.
