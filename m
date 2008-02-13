From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: AES support for RPCSEC_GSS?
Date: Wed, 13 Feb 2008 12:59:16 -0500
Message-ID: <20080213175916.GD13462@fieldses.org>
References: <20080212012007.GA6993@goelette.ens.fr> <20080212043715.GD4561@fieldses.org> <20080213170155.GA12551@goelette.ens.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Quentin Godfroy <godfroy-7pss2ddYZfWsyDt4atOG6g@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:40725 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934259AbYBMR7R (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Feb 2008 12:59:17 -0500
In-Reply-To: <20080213170155.GA12551-Gn1em/8t8udFYcqGaMRPHA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 13, 2008 at 06:01:56PM +0100, Quentin Godfroy wrote:
> I'll be glad to try it once it is available
> 
> >        Is there something in particular you need or want to work on?
> 
> No, not really. I find the current implementation sufficient for my needs.
> Maybe the server not being IPv6 compatible is not pleasing to the mind.
> Unfortunately my coding experience is low and probably the nfsd code is not
> the easy way to start.

I *think* the ipv6 stuff is also on track to be done by 2.6.26 or
2.6.27, but I'm not the expert there....

--b.
