Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:45004
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753175Ab1DTWAH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 18:00:07 -0400
Date: Wed, 20 Apr 2011 23:59:59 +0200
From: Michael Guntsche <mike@it-loops.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, kwc@umich.edu
Subject: Re: [BUG] supported_krb5_enctypes not available if GSS support
 compiled as a module
Message-ID: <20110420235654@it-loops.com>
References: <20110420224241@it-loops.com>
 <20110420213906.GB24503@pad.home.fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110420213906.GB24503@pad.home.fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 20 Apr 11 17:39, J. Bruce Fields wrote:
> On Wed, Apr 20, 2011 at 10:49:51PM +0200, Michael Guntsche wrote:
> > Hello Bruce,
> > 
> > Commit 0a5e5f122c nfsd: fix compile error fixed a compile error by
> > putting the code between an #ifdef CONFIG_SUNRPC_GSS.
> > 
> > In my case this is compiled as a module so CONFIG_SUNRPC_GSS_MODULE is
> > defined but not CONFIG_SUNRPC_GSS. I do not know if this was on purpose
> > but as it is now "supported_krb5_enctypes" is only available if GSS
> > support is compiled in the kernel.
> 
> Ugh, fuzzy thinking on my part.
> 
> So I guess to do this right we want modules to be able to dynamically
> add files to the nfsd filesystem at module load time?
This seems to be working already. The problem is that CONFIG_SUNRPC_GSS
is not defined when configured as a module so the code is not being
built in the first place. I tested this by defining CONFIG_SUNRPC_GSS at
the beginning of the file. 

Of course you can test for both CONFIG_SUNRPC_GSS AND *GSS_MODULE but I
do not know if this is the correct way.

/Michael
