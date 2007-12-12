From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.24-rc3-git4 NFS crossmnt regression [SOLVED]
Date: Tue, 11 Dec 2007 18:44:01 -0800
Message-ID: <20071211184401.ab273c19.akpm@linux-foundation.org>
References: <fa4052ef0712062045o743a2666u3562a3569c1aa989@mail.gmail.com>
	<200712101705.30428.maximlevitsky@gmail.com>
	<20071210130305.d8983fdc.akpm@linux-foundation.org>
	<200712120401.57128.maximlevitsky@gmail.com>
	<20071211181559.fe21687a.akpm@linux-foundation.org>
	<1197425940.27061.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Maxim Levitsky <maximlevitsky@gmail.com>, bfields@fieldses.org,
	neilb@suse.de, rjw@sisk.pl, gnome42@gmail.com,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	den@openvz.org, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:38806 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751653AbXLLCpK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2007 21:45:10 -0500
In-Reply-To: <1197425940.27061.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 11 Dec 2007 21:19:00 -0500 Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> 
> On Tue, 2007-12-11 at 18:15 -0800, Andrew Morton wrote:
> > > 1) Stale handles - Trond's patch fixes it, but I somehow missed it.
> > 
> > What is "Trond's patch" and where is it now?
> 
> He means the one this whole thread started with. See attachment...
> 

Thanks.

Four days later that is not in mainline, not in -mm, not in git-nfs. 
There is some disconnect here.

