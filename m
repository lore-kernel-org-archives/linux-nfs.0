Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47804 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165AbbIHGBl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Sep 2015 02:01:41 -0400
Date: Mon, 7 Sep 2015 23:01:36 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Oleg Drokin <green@linuxhacker.ru>, Doug Ledford <dledford@redhat.com>
Subject: Re: [GIT PULL] Please pull NFS client changes
Message-ID: <20150908060136.GA6220@infradead.org>
References: <1441659544.3163.4.camel@primarydata.com>
 <20150908115900.4182d55a@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150908115900.4182d55a@canb.auug.org.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 08, 2015 at 11:59:00AM +1000, Stephen Rothwell wrote:
> This contains about 12 commits new since Sept 1 and the last 6 are only
> appearing in linux-next today (though I did not do Friday and Monday's
> linux-next).  Not judging, just noting.

And one of tese recent commits causes a regression for block layouts
in xfstests generic/075.  Still need to check which one.

Trond, I think it's really time the NFS client gets regular automated
tests at least against the Linux server for v3/4/4.1/pNFS - I'm finding
regressions pretty much every time I kick off a simple xfstests run.
