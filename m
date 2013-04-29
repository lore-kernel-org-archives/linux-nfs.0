Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:49241 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758394Ab3D2SPy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Apr 2013 14:15:54 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] NFSv4: Servers should only check SETATTR stateid
 open mode on size change
Date: Mon, 29 Apr 2013 18:15:52 +0000
Message-ID: <1367259352.19515.16.camel@leira.trondhjem.org>
References: <1367248534-33387-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1367248534-33387-1-git-send-email-Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-04-29 at 11:15 -0400, Trond Myklebust wrote:
> The NFSv4 and NFSv4.1 specs are both clear that the server should only check
> stateid open mode if a SETATTR specifies the size attribute. If the
> open mode is not one that allows writing, then it returns NFS4ERR_OPENMODE.
> 
> In the case where the SETATTR is not changing the size, the client will
> still pass it the delegation stateid to ensure that the server does not
> recall that delegation. In that case, the server should _ignore_ the
> delegation open mode, and simply apply standard permission checks.

Bruce, what does the Linux server do when we send it a delegation
stateid as part of a SETATTR that just changes the mode or acl (no size
change)? Will it recall the delegation? How about the delegations held
by other clients?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
