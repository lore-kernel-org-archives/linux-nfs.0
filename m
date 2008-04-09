From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] SELinux: don't BUG if fs reuses a superblock
Date: Thu, 10 Apr 2008 09:04:21 +1000 (EST)
Message-ID: <Xine.LNX.4.64.0804100903430.30176@us.intercode.com.au>
References: <1207764515.3070.39.camel@localhost.localdomain>
 <1207773091.11881.27.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Paris <eparis@redhat.com>, linux-nfs@vger.kernel.org,
	selinux@tycho.nsa.gov, steved@redhat.com, jlayton@redhat.com,
	sds@tycho.nsa.gov, chuck.lever@oracle.com
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from namei.org ([69.55.235.186]:40847 "EHLO us.intercode.com.au"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752659AbYDIXHL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Apr 2008 19:07:11 -0400
In-Reply-To: <1207773091.11881.27.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 9 Apr 2008, Trond Myklebust wrote:

> > Signed-off-by: Eric Paris <eparis@redhat.com>
> 
> Ack...

Applied and pushed to Linus.


-- 
James Morris
<jmorris@namei.org>
