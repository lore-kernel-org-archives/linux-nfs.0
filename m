From: Dmitry Monakhov <dmonakhov@openvz.org>
Subject: Re: [PATCH] nfs: clear_commit_release incorrectly handle truncated page
Date: Tue, 02 Feb 2010 18:17:07 +0300
Message-ID: <87eil3pszw.fsf@openvz.org>
References: <87hbpzhqlp.fsf@openvz.org> <1265123045.3177.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:23128 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739Ab0BBPRX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Feb 2010 10:17:23 -0500
In-Reply-To: <1265123045.3177.21.camel@localhost> (Trond Myklebust's message
	of "Tue, 02 Feb 2010 10:04:05 -0500")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust <trond.myklebust@fys.uio.no> writes:

> On Tue, 2010-02-02 at 13:36 +0300, Dmitry Monakhov wrote: 
>> After page was truncated it lost it's mapping, this result in null
>> pointer dereference on bdi_stat update. In fact we have to decrement
>> bdi_stat even for truncated pages, so let's pass correct mapping in
>> function arguments. Patch against linux-2.6
>> ##TEST_CASE
>> /*
>> Tast case for bug in nfs_clear_request_commit()
>> caused by null pointer dereference in case of truncated page.
>> It takes less than 10 minutes to reproduce the bug.
>
> Something is wrong here. nfs_release_page() returns '0' if the 
> page has an associated write request (i.e. PagePrivate is set), and so
> both invalidate_complete_page() and invalidate_complete_page2() will
> fail.
>
> So what is truncating the page?
truncate_inode_page()
  truncate_complete_page()
    if (page_has_private(page))
       do_invalidatepage()
         ->nfs_invalidate_page()
>
> Trond
