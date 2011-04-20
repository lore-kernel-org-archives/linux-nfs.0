Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20165 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752737Ab1DTVjO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Apr 2011 17:39:14 -0400
Date: Wed, 20 Apr 2011 17:39:07 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Michael Guntsche <mike@it-loops.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, kwc@umich.edu
Subject: Re: [BUG] supported_krb5_enctypes not available if GSS support
 compiled as a module
Message-ID: <20110420213906.GB24503@pad.home.fieldses.org>
References: <20110420224241@it-loops.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110420224241@it-loops.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Apr 20, 2011 at 10:49:51PM +0200, Michael Guntsche wrote:
> Hello Bruce,
> 
> Commit 0a5e5f122c nfsd: fix compile error fixed a compile error by
> putting the code between an #ifdef CONFIG_SUNRPC_GSS.
> 
> In my case this is compiled as a module so CONFIG_SUNRPC_GSS_MODULE is
> defined but not CONFIG_SUNRPC_GSS. I do not know if this was on purpose
> but as it is now "supported_krb5_enctypes" is only available if GSS
> support is compiled in the kernel.

Ugh, fuzzy thinking on my part.

So I guess to do this right we want modules to be able to dynamically
add files to the nfsd filesystem at module load time?

--b.
