Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46370 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946184AbbEOVdy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 May 2015 17:33:54 -0400
Date: Fri, 15 May 2015 17:33:53 -0400
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Andreas Gruenbacher <agruen@kernel.org>
Subject: Re: [RFC v3 25/45] richacl: acl editing helper functions
Message-ID: <20150515213353.GH29627@fieldses.org>
References: <cover.1429868795.git.agruenba@redhat.com>
 <a74bc8fdb5d8ee5bdd5defad9729d17211266079.1429868795.git.agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <a74bc8fdb5d8ee5bdd5defad9729d17211266079.1429868795.git.agruenba@redhat.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2015 at 01:04:22PM +0200, Andreas Gruenbacher wrote:
> +/**
> + * richace_change_mask  -  set the mask of @ace to @mask
> + * @x:		acl and number of allocated entries
> + * @ace:	entry to modify
> + * @mask:	new mask for @ace
> + *
> + * If @ace is inheritable, a inherit-only ace is inserted before @ace which
> + * includes the inheritable permissions of @ace and the inheritance flags of
> + * @ace are cleared before changing the mask.
> + *
> + * If @mode is 0, the original ace is turned into an inherit-only entry if

s/@mode/@mask/ ?

--b.
