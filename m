Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53389 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752683Ab3KGQdf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Nov 2013 11:33:35 -0500
Date: Thu, 7 Nov 2013 11:33:10 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] gssd: cut down log chatter in gssd_search_krb5_keytab
Message-ID: <20131107113310.567c3b64@tlielax.poochiereds.net>
In-Reply-To: <20131107162123.GA9411@infradead.org>
References: <1383839253-8223-1-git-send-email-jlayton@redhat.com>
	<20131107155837.GA16658@infradead.org>
	<20131107110928.68244ea7@tlielax.poochiereds.net>
	<20131107162123.GA9411@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 7 Nov 2013 08:21:23 -0800
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Nov 07, 2013 at 11:09:28AM -0500, Jeff Layton wrote:
> > It may be the same issue. IIRC, the attempt to use krb5i by default
> > is done in the SETCLIENTID call (see kernel commit 4edaa30888 for some
> > background, but there were some later tweaks to this approach).
> 
> I'm still seing my issue after reverting that commit by hand.

Hrm...

You'd also see these messages in the log if it were the same problem:

     RPC: AUTH_GSS upcall timed out.

...it could also be a delay when trying to set up the callback channel
if you're running v4.0. Do you have the callback port firewalled off?

-- 
Jeff Layton <jlayton@redhat.com>
