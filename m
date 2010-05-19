From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] pnfsblock: Lookup list entry of layouts and tags in
	reverse order
Date: Wed, 19 May 2010 17:38:49 -0400
Message-ID: <20100519213849.GR9720@fieldses.org>
References: <4BEA4ED3.3010702@panasas.com> <20100512202811.GA9296@fieldses.org> <20100517135341.GA30737@fieldses.org> <4BF151A7.1070003@panasas.com> <20100517145311.GJ30737@fieldses.org> <20100517165302.GL30737@fieldses.org> <AANLkTilUpAHrtHH8pauvYrAuD3rWgj7aDmrTOzrmU-h5@mail.gmail.com> <20100518162005.GI17823@fieldses.org> <AANLkTik9L15tqpSboBpb9cSTy3hVPLEK487w94pEbLrS@mail.gmail.com> <20100519163632.GL4581@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhang Jingwang <yyalone@gmail.com>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Benny Halevy <bhalevy@panasas.com>,
	Zhang Jingwang <zhangjingwang-U4AKAne5IzAR5TUyvShJeg@public.gmane.org>,
	linux-nfs@vger.kernel.org, iisaman@netapp.com
To: Tao Guo <glorioustao@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36116 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085Ab0ESViw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 May 2010 17:38:52 -0400
In-Reply-To: <20100519163632.GL4581@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 19, 2010 at 12:36:32PM -0400, J. Bruce Fields wrote:
> On Wed, May 19, 2010 at 12:56:42PM +0800, Tao Guo wrote:
> > I think the warning just indicate a possible bug:
> > nfs_inode_set_delegation():
> >                                         clp->cl_lock
> >                                             --> inode->i_lock
> > get_lock_alloc_layout():
> >                                    nfsi->lo_lock
> >                                       --> clp->cl_lock
> > nfs_try_to_update_request()->pnfs_do_flush()->_pnfs_do_flush()->
> > pnfs_find_get_lseg()->get_lock_current_layout():
> > 
> > inode->i_lock
> > 
> > -->nfsi->lo_lock
> > In nfs_inode_set_delegation(), maybe we should unlock clp->cl_lock before
> > taking inode->i_lock spinlock?
> > 
> > PS: I just use the latest pnfsblock code(pnfs-all-2.6.34-2010-05-17) doing some
> > basic r/w tests and it works fine.
> 
> Could you try running the connectathon general test?
> 
> > Can you find out which code path
> > lead to IO errror?
> 
> I'll try to narrow down the test case.

I haven't gotten the chance to narrow it down any more.  So all I can
say is that:

	~/cthon04# NFSTESTDIR=/mnt/TMP ./runtests -g

	GENERAL TESTS: directory /mnt/TMP
	if test ! -x runtests; then chmod a+x runtests; fi
	cd /mnt/TMP; rm -f Makefile runtests runtests.wrk *.sh *.c
	mkdummy rmdummy nroff.in makefile.tst
	cp Makefile runtests runtests.wrk *.sh *.c mkdummy rmdummy
	nroff.in makefile.tst /mnt/TMP

	Small Compile
	runtests.wrk: 63: ./stat: Input/output error
	general tests failed

is a consistent result for me.  (Using the tests from
http://www.connectathon.org/nfstests.html.)

--b.
