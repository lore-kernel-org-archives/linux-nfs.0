Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39277 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753289AbbIKQ1U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 12:27:20 -0400
Date: Fri, 11 Sep 2015 09:27:15 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Oleg Drokin <green@linuxhacker.ru>, Doug Ledford <dledford@redhat.com>
Subject: Re: [GIT PULL] Please pull NFS client changes
Message-ID: <20150911162715.GA21393@infradead.org>
References: <1441659544.3163.4.camel@primarydata.com>
 <20150908115900.4182d55a@canb.auug.org.au>
 <20150908060136.GA6220@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150908060136.GA6220@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 07, 2015 at 11:01:36PM -0700, Christoph Hellwig wrote:
> On Tue, Sep 08, 2015 at 11:59:00AM +1000, Stephen Rothwell wrote:
> > This contains about 12 commits new since Sept 1 and the last 6 are only
> > appearing in linux-next today (though I did not do Friday and Monday's
> > linux-next).  Not judging, just noting.
> 
> And one of tese recent commits causes a regression for block layouts
> in xfstests generic/075.  Still need to check which one.

"NFSv4.1/pNFS: Don't request a minimal read layout beyond the end of file"

is the culprit, posted to the list for the first time and committed on
Aug 31.
