Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53185 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751044Ab0JLRsO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Oct 2010 13:48:14 -0400
Date: Tue, 12 Oct 2010 13:48:10 -0400
To: Jim Rees <rees@umich.edu>
Cc: DENIEL Philippe <philippe.deniel@cea.fr>, linux-nfs@vger.kernel.org
Subject: Re: POSIX's "tables of the law"
Message-ID: <20101012174810.GF22495@fieldses.org>
References: <4CB443F6.5060106@cea.fr>
 <20101012115026.GB2577@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101012115026.GB2577@merit.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Oct 12, 2010 at 07:50:26AM -0400, Jim Rees wrote:
> DENIEL Philippe wrote:
> 
>   on many aspects, knowing the POSIX standard and behavior is quite
>   important when working on implementing something like NFSv4. There a
>   problem occur : if I need information on NFS (whatever version) or
>   any "related" protocol (RPCSEC_GSS, ONCRPC, ...) I can easily find a
>   document that is the absolute reference to use. But what about POSIX
>   ? I must have missed something but I never see such a reference. Do
>   you have book references to provide me with about this subject ?
> 
> The posix spec situation is confused because there are many different specs
> published at different times, and the ones that are most important (like
> acls) were never ratified as far as I know, so are still in draft form.
> Originally they were ISO specs, which cost big money, which is why you won't
> find them on the web.  More recently I think the Open Group has been working
> on them, maybe you'll find copies there: www.opengroup.org

I think you want:

	http://www.unix.org/single_unix_specification/

You have to fill out a form but there's no charge.

Of course you can also write little test programs and such to find out
what other filesystems or platforms do.  No spec is perfect, alas.

--b.
