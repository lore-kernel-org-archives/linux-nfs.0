Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:44030 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730288AbeGRMty (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 18 Jul 2018 08:49:54 -0400
Date: Wed, 18 Jul 2018 08:12:16 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: add minor version to nfs_server_key for fscache
Message-ID: <20180718121216.GK10135@coeurl.usersys.redhat.com>
References: <20180711122219.20808-1-smayhew@redhat.com>
 <9138.1531475067@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <9138.1531475067@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 13 Jul 2018, David Howells wrote:

> Scott Mayhew <smayhew@redhat.com> wrote:
> 
> > kernel BUG at fs/cachefiles/namei.c:194!
> 
> Note that the cachefiles dumps a load of info immediately prior to this BUG()
> which should be included in the description.
> 
> Can you also try the four patches at the top of this branch from Kiran Kumar
> Modukuri?
> 
> 	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=fscache-fixes
> 
> The topmost patch removes the BUG() and lets it fall through to the wait.  The
> "Fix missing clear of the CACHEFILES_OBJECT_ACTIVE flag" patch fixes one of
> the causes of the BUG.

With v4.18-rc5 plus those four patches, I no longer get the "Unexpected
object collision" message when running cthon (and no oops either,
obviously).

-Scott
> 
> David
