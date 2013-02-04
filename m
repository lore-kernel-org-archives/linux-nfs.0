Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46693 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756345Ab3BDQS2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Feb 2013 11:18:28 -0500
Date: Mon, 4 Feb 2013 11:18:25 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc: move address copy/cmp/convert routines and
 prototypes from clnt.h to addr.h
Message-ID: <20130204161825.GF815@fieldses.org>
References: <1359991431-25579-1-git-send-email-jlayton@redhat.com>
 <20130204160955.GD815@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91835C73B@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91835C73B@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 04, 2013 at 04:15:43PM +0000, Myklebust, Trond wrote:
> On Mon, 2013-02-04 at 11:09 -0500, J. Bruce Fields wrote:
> > On Mon, Feb 04, 2013 at 10:23:51AM -0500, Jeff Layton wrote:
> > > These routines are used by server and client code, so having them in a
> > > separate header would be best.
> > 
> > I'll apply this and the scope id patch if it gets Trond's ACK.
> > 
> > (Or they have my ACK if Trond wants to take them.)
> 
> Feel free to take them through the nfsd tree.
> 
> Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Thanks.  I needed to add the following.

We should make sure none of the other files including clnt.h might also
need one of these.

--b.

commit a487a5ec9e2f37472097a3ff3535c87c6af334e9
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Mon Feb 4 11:13:24 2013 -0500

    foldme

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index e761ee9..255ae32 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -10,6 +10,7 @@
 #include <linux/module.h>
 #include <linux/nsproxy.h>
 #include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/addr.h>
 #include <asm/uaccess.h>
 
 #include "state.h"
