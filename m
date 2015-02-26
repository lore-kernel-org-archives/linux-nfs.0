Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:56564 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751570AbbBZQ7j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Feb 2015 11:59:39 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1655.1424969471@warthog.procyon.org.uk>
References: <1655.1424969471@warthog.procyon.org.uk> <1424964991.10136.8.camel@primarydata.com> <1411654543.3044.24.camel@leira.trondhjem.org> <28059.1411650278@warthog.procyon.org.uk> <6150.1424947519@warthog.procyon.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: NMI/soft lockup in nfs_delegation_need_return()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 26 Feb 2015 16:59:34 +0000
Message-ID: <1830.1424969974@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > This patch ensures that the superblock doesn't go ahead and disappear
> > underneath us while the state manager thread is returning delegations.
> 
> It doesn't help.  It seem likely that it would, though.  The superblock is

It doesn't seem likely, that is...

> unlikely to disappear since there's an active tar running against it.

David
