From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH v2] sunrpc: fix build-time warning
Date: Wed, 06 Jan 2010 18:10:20 -0500
Message-ID: <1262819420.4251.171.camel@localhost>
References: <1262226195-27733-1-git-send-email-jlayton@redhat.com>
	 <20091231091815.a1ea7e51.rdunlap@xenotime.net>
	 <20091231205454.0f84f091@tupile.poochiereds.net>
	 <20100101182514.cb1f49ef.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jeff Layton <jlayton@redhat.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:36511 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932372Ab0AFXKf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Jan 2010 18:10:35 -0500
In-Reply-To: <20100101182514.cb1f49ef.randy.dunlap@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-01-01 at 18:25 -0800, Randy Dunlap wrote: 
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix auth_gss printk format warning:
> 
> net/sunrpc/auth_gss/auth_gss.c:660: warning: format '%ld' expects type 'long int', but argument 3 has type 'ssize_t'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Thanks Randy!

Sorry for the delay. This patch has been applied today, and should
therefore appear in the linux-next tree tomorrow...

Cheers
  Trond

