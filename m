Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbaIYNHz convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Sep 2014 09:07:55 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <28059.1411650278@warthog.procyon.org.uk>
References: <28059.1411650278@warthog.procyon.org.uk>
To: trond.myklebust@primarydata.com
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org, steved@redhat.com
Subject: Re: NMI/soft lockup in nfs_delegation_need_return()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 25 Sep 2014 14:07:50 +0100
Message-ID: <28111.1411650470@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> I'm seeing the soft lockup below occasionally.  I'm using the head of Linus's
> master branch (005f800508eb391480f463dad3d54e5b4ec67d57).  Plus a pair of
> cachefiles patches that should have no bearing on the matter.  I'm seeing the
> lockup both with and without a cache.  I did the following:

I should mention that the server is running the most recent Fedora 20 kernel:

	3.16.2-201.fc20.x86_64

and that and the client are connected by gigabit ethernet with not much other
traffic on the network.

David
