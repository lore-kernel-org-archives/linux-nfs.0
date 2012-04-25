Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:50886 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759048Ab2DYWUB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 18:20:01 -0400
Date: Wed, 25 Apr 2012 18:20:00 -0400
To: steve <steve@steve-ss.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: LOOKUP Reply Error:NFS3ERR_NO_ENT
Message-ID: <20120425222000.GD3251@fieldses.org>
References: <4F986760.2000908@steve-ss.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F986760.2000908@steve-ss.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 25, 2012 at 11:06:40PM +0200, steve wrote:
> Hi
> Without Kerberos, I can rw to the share just fine. With Krb5, I get
> 'Permission denied' when I try and write to it. The only error I can
> see on wireshark is:
> LOOKUP Reply Error:NFS3ERR_NO_ENT
> 
> Any ideas where to start looking?

What does your exports file look like?

--b.
