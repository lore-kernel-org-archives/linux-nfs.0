From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH,RFC 02/02] xprtrdma: Update the RPC memory registration
	to use FRMR
Date: Wed, 13 Aug 2008 18:37:45 -0400
Message-ID: <1218667065.9042.83.camel@localhost>
References: <48A30959.7060404@opengridcomputing.com>
	 <1218649253.9042.11.camel@localhost>
	 <1032B681-8E1C-4074-BF14-7521F34BB7E8@oracle.com>
	 <48A361AC.8010705@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Tom Talpey <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:44891 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753306AbYHMWkO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Aug 2008 18:40:14 -0400
In-Reply-To: <48A361AC.8010705@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-08-13 at 17:35 -0500, Tom Tucker wrote:

> I just copied the coding style of the function. So the proposal here is 
> to refactor this function? If yes, then I'll make it happen.

Please do, or please at least make sure that you don't repeat the
mistakes of the past when adding in new code.

Cheers
  Trond

