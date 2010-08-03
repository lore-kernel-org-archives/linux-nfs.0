Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41882 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754421Ab0HCTXh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Aug 2010 15:23:37 -0400
Date: Tue, 3 Aug 2010 15:22:16 -0400
To: Jim Rees <rees@umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: numeric UIDs
Message-ID: <20100803192216.GC31579@fieldses.org>
References: <201008030401.33552.dreck@vmsd.ath.cx>
 <20100803164318.GB13896@merit.edu>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20100803164318.GB13896@merit.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 03, 2010 at 12:43:18PM -0400, Jim Rees wrote:
> Victor Mataré wrote:
> 
>   I'd like to try and 
>   make a case for implementing an option to turn off UID mapping completely (or 
>   at least for unknown UIDs).
> 
> I've always thought this would be useful too, just as an option for auth_sys
> of course.  Some people think it's a security problem but since there is no
> security in an auth_sys mount I don't see what the issue is.

I'm not sure what the security flavor has to do with it.

I'll admit I like the idea of a v2/v3-compatibility mode that uses
(ascii-encoded) uid's only, though I think it's a technical violation of
the spec.

--b.
