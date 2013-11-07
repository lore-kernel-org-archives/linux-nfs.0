Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:55187 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751743Ab3KGT0j convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Nov 2013 14:26:39 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] Adding the nfs4_use_min_auth module parameter
Date: Thu, 7 Nov 2013 19:26:23 +0000
Message-ID: <1383852380.12966.5.camel@leira.trondhjem.org>
References: <1383851364-8370-1-git-send-email-steved@redhat.com>
In-Reply-To: <1383851364-8370-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-11-07 at 14:09 -0500, Steve Dickson wrote:
+AD4- This new module parameter makes the v4 client
+AD4- use the minimal authentication flavor (AUTH+AF8-UNIX)
+AD4- when establishing NFSV4 state and doing the
+AD4- pseudoroot lookup
+AD4- 

That looks very ad-hoc. Quite frankly, you can do the exact same thing
already by simply blacklisting the rpcsec+AF8-gss+AF8-krb5 and/or auth+AF8-rpcgss
modules.

I think we should rather looks at adding a new mount option for
specifying the security flavour to use when establishing basic NFSv4.x
state, and then perhaps specifying the +AF8-default+AF8- for that mount option
using a module parameter.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
