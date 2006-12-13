From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 000 of 14] knfsd: Assorted nfsd patches for 2.6.20 - prepare
 for IPv6 and more
Date: Wed, 13 Dec 2006 00:40:19 -0500
Message-ID: <457F9243.9090701@garzik.org>
References: <20061213105528.21128.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964946AbWLMGIQ@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
In-Reply-To: <20061213105528.21128.patches@notabene>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

NeilBrown wrote:
> Following are 14 patches for knfsd that are suitable for inclusion in 2.6.20.
> First 13 are from Chuck Lever and make preparations for IPv6 support (I think we've
> get them right this time).
> 
> Last is from Peter Staubach and fixes and issue with exclusive create
> interacting badly with some ACLs.


Any word on this 2.6.19 oops?

http://lkml.org/lkml/2006/12/8/110

	Jeff
