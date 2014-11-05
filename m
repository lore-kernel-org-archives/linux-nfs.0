Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57637 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbaKEI3m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2014 03:29:42 -0500
Date: Wed, 5 Nov 2014 00:29:41 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, Eryu Guan <eguan@redhat.com>,
        fstests@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: nfs atime semantics, was: Re: [PATCH 3/4] common: skip atime
 related tests on NFS
Message-ID: <20141105082941.GA404@infradead.org>
References: <1414502171-10319-1-git-send-email-eguan@redhat.com>
 <1414502171-10319-4-git-send-email-eguan@redhat.com>
 <20141030090306.GA23917@infradead.org>
 <CAHQdGtRFMcJGNZvU_V22Xh-3LadD2bYc=TwrkmBVBK81RkWCvw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRFMcJGNZvU_V22Xh-3LadD2bYc=TwrkmBVBK81RkWCvw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 31, 2014 at 01:31:36PM +0200, Trond Myklebust wrote:
> If there is no read on the wire, then there is no way to update the
> atime without doing an explicit SETATTR. Courtesy of POSIX filesystem
> semantics on the server, that means we get a bonus change attribute
> and ctime update (no extra charge).
> 
> Unless there are new suggestions for how to solve the atime issue that
> do not involve introducing this or similar regressions, then the
> standing NACK applies.

I think various network filesystems are fairly lax on updating the atime
on the server.  What xfstests generic/192 tests is that we don't lose
an atime update after an unmount/remount.  I think we should be able
to expect local atime updates, and updates to the server on unmount.

Or at least claim that the filesystem is mounted by noatime if it is so
that users (including xfstests) notice, and can enable strict atime mode
if really needed, including the above mentioned drawbacks.
