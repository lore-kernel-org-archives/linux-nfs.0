Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55043 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750832AbbCDNVy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Mar 2015 08:21:54 -0500
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAHQdGtT9GZpUw5T3zjmRMtO_e34CWy9ds14hB2CAGs8h9f2Jvw@mail.gmail.com>
References: <CAHQdGtT9GZpUw5T3zjmRMtO_e34CWy9ds14hB2CAGs8h9f2Jvw@mail.gmail.com> <1424964991.10136.8.camel@primarydata.com> <1411654543.3044.24.camel@leira.trondhjem.org> <28059.1411650278@warthog.procyon.org.uk> <6150.1424947519@warthog.procyon.org.uk> <1655.1424969471@warthog.procyon.org.uk> <1830.1424969974@warthog.procyon.org.uk>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: dhowells@redhat.com, Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>
Subject: Re: NMI/soft lockup in nfs_delegation_need_return()
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 04 Mar 2015 13:21:48 +0000
Message-ID: <16835.1425475308@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> Could you please retest using the patches that are currently in my
> 'devel' git branch?
> 
> git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git devel
> 
> They fix up a number of minor issues with the delegation code,
> specifically ones that might cause a delegation to be removed
> prematurely.

The bug still happens and the backtrace looks much the same.  It might be a
bit less likely, however, but it's hard to say.

David
