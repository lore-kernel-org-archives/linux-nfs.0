Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:20220 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752044Ab3KAQuC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Nov 2013 12:50:02 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
CC: "cye@redhat.com" <cye@redhat.com>,
        "dpquigl@davequigley.com" <dpquigl@davequigley.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix oops when trying to set SELinux label
Date: Fri, 1 Nov 2013 16:50:00 +0000
Message-ID: <1383324599.2911.2.camel@leira.trondhjem.org>
References: <1383317372-3373-1-git-send-email-jlayton@redhat.com>
	 <20131101120211.586aef7a@corrin.poochiereds.net>
In-Reply-To: <20131101120211.586aef7a@corrin.poochiereds.net>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-11-01 at 12:02 -0400, Jeff Layton wrote:
+AD4- It looks like +AF8-nfs4+AF8-get+AF8-security+AF8-label() has the same problem, but I've
+AD4- so far been unable to get it to be called, so I didn't patch it. It
+AD4- seems like getxattr does some special stuff for SELinux labels that
+AD4- cause them only to ever be fetched once.
+AD4- 
+AD4- Is there some trick to it?
+AD4- 

Doesn't 'ls -Z' cause them to security label to be read again?

Either way, the fix is clearly needed, so I've added the patch, and Cced
stable.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
