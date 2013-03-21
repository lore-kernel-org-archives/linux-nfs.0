Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49320 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932184Ab3CUNra (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Mar 2013 09:47:30 -0400
Date: Thu, 21 Mar 2013 09:47:29 -0400
To: Christopher T Vogan <cvogan@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: What is NFSv4 READDIR doesn't return a filehandle....
Message-ID: <20130321134729.GC27838@fieldses.org>
References: <OF5A466E86.6A319FE3-ON87257B34.007C6188-86257B34.007C87C8@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF5A466E86.6A319FE3-ON87257B34.007C6188-86257B34.007C87C8@us.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 20, 2013 at 05:40:11PM -0500, Christopher T Vogan wrote:
> This condition is easily recoverable, as ANY missing attribute on a 
> readdir
> is with a lookup/readdir.

By the same token, the server can just as well recover by doing that
extra lookup itself, can't it?  (That's more-or-less how the Linux
server gets attributes on readdir.)

Understood that it can be a pain (the Linux server's readdir
implementation has needed some minor surgery over the years to get this
right), but I do think it's the server's responsibility....

--b.

> Our decision to not return the FH on a readdir 
> reply under certain narrow conditions is not one of convenience but of 
> limitations of some underlying filesystem types, and if "convenience" is
> to be used as an accusative, it can easily be returned to the client's 
> refusal to deal with the legal withholding of an attribute on a readdir
> reply.
