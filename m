Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33325 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753110Ab0FZPPJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Jun 2010 11:15:09 -0400
Date: Sat, 26 Jun 2010 11:15:02 -0400
To: philippe.deniel@cea.fr
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS4ERR_DELAY and OP4_PUTROOTFH
Message-ID: <20100626151502.GA3432@fieldses.org>
References: <4C246006.10708@cea.fr>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C246006.10708@cea.fr>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jun 25, 2010 at 09:51:34AM +0200, philippe.deniel@cea.fr wrote:
> Hi,
> 
> in which situation would OP4_PUTROOTFH return NFS4ERR_DELAY ? I have
> seen in rfc5661 that PUTROOTFH can return such an error, but I can't
> figure out when this can occur.

That depends entirely on the server implementation.  In the case of the
Linux server, it depends on an upcall to a userland daemon to find the
root, and the userland daemon may be slow or unresponsive.

--b.
