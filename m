Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1028 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753753Ab1ATVLW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Jan 2011 16:11:22 -0500
Message-ID: <4D38A4F5.8070904@redhat.com>
Date: Thu, 20 Jan 2011 22:11:17 +0100
From: Milan Broz <mbroz@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS: Fix "kernel BUG at fs/nfs/nfs3xdr.c:1338!"
References: <20110120191639.3122.24837.stgit@matisse.1015granger.net>
In-Reply-To: <20110120191639.3122.24837.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 01/20/2011 08:18 PM, Chuck Lever wrote:
> Milan Broz <mbroz@redhat.com> reports:

>> [  105.327979] kernel BUG at fs/nfs/nfs3xdr.c:1338!

> 
> nfs3_xdr_enc_setacl3args() is not properly setting up the target
> buffer before nfsacl_encode() attempts to encode the ACL.
> 
> Introduced by commit d9c407b1 "NFS: Introduce new-style XDR encoding
> functions for NFSv3."

Yes, patch fixes the problem for me.

Thanks,
Milan
