Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:23897 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523Ab3AaVGz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Jan 2013 16:06:55 -0500
Date: Thu, 31 Jan 2013 16:06:46 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 01/16] nfsd: fix IPv6 address handling in the DRC
Message-ID: <20130131160646.59c8de8f@corrin.poochiereds.net>
In-Reply-To: <20130131205901.GC24252@fieldses.org>
References: <1359402082-29195-1-git-send-email-jlayton@redhat.com>
	<1359402082-29195-2-git-send-email-jlayton@redhat.com>
	<20130131205901.GC24252@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 31 Jan 2013 15:59:01 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Jan 28, 2013 at 02:41:07PM -0500, Jeff Layton wrote:
> > Currently, it only stores the first 16 bytes of any address. struct
> > sockaddr_in6 is 28 bytes however, so we're currently ignoring the last
> > 12 bytes of the address.
> > 
> > Expand the c_addr field to a sockaddr_in6, and cast it to a sockaddr_in
> > as necessary. Also fix the comparitor to use the existing RPC
> > helpers for this.
> 
> Applying.  (Assuming the fix for link-local case will be separate.)
> 
> --b.
> 

Thanks. Yep, I'll do that as a separate patch.

-- 
Jeff Layton <jlayton@redhat.com>
