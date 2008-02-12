From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: AES support for RPCSEC_GSS?
Date: Mon, 11 Feb 2008 23:37:15 -0500
Message-ID: <20080212043715.GD4561@fieldses.org>
References: <20080212012007.GA6993@goelette.ens.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Quentin Godfroy <godfroy-7pss2ddYZfWsyDt4atOG6g@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47684 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750773AbYBLEhR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2008 23:37:17 -0500
In-Reply-To: <20080212012007.GA6993-Gn1em/8t8udFYcqGaMRPHA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 12, 2008 at 02:20:07AM +0100, Quentin Godfroy wrote:
> in all the faqs it is said that there is no working support for
> anything else than DES which is a bit outdated and not secure
> nowadays.
> 
> It seemed to me that there was some code in the nfs-utils which
> would do some security negociation (somewhere around utils/gssd/krb5_util.c),
> but the kernel had nothing to support that.
> 
> I suppose this will be the last thing to be done once the security features
> are working with the three versions of NFS.
> 
> What are the missing features in this field, and would it be difficult to
> add support for other encryption schemes?

Kevin Coffman is working on support for AES (and other algorithms).
It's mostly working at this point, so I think we'll be posting patches
soon.  Is there something in particular you need or want to work on?

--b.
