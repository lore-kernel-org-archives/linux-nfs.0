Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:42620 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635Ab1DGPBX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2011 11:01:23 -0400
Date: Thu, 7 Apr 2011 11:01:20 -0400
From: Jim Rees <rees@umich.edu>
To: "Finney, Sean" <Sean.Finney@sonyericsson.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bfields@fieldses.org" <bfields@fieldses.org>
Subject: Re: [PATCH v2 1/2] nfs-utils: mountd: Use a dynamic buffer for
 storing lists of gid's
Message-ID: <20110407150120.GA12596@merit.edu>
References: <20110405233552.GB27961@fieldses.org>
 <1302160948-5628-1-git-send-email-sean.finney@sonyericsson.com>
 <20110407122218.GA11897@merit.edu>
 <A50602A820F61543B29992A418BB321B66E18F8A5E@seldmbx01.corpusers.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A50602A820F61543B29992A418BB321B66E18F8A5E@seldmbx01.corpusers.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Finney, Sean wrote:

  > I would re-word this.  The list isn't static, the list pointer is.  I don't
  > think you need to mention that, it's just confusing.  "Use malloc/realloc to
  > grow the list on an as-needed basis."
  
  Okay.  I was trying to just put a hint that there was a persistant
  buffer that would hang around through multiple invocations, though
  perhaps that's a little too much 'implementation details'.  Totally fine
  with modifying the description either way :)

If it were me, I would alloc and free the list each time rather than keeping
it around.  It's not like malloc is super expensive.  But that's a matter of
taste.

  > BUGS
  >        In  glibc  versions  before  2.3.3, the implementation of this function
  >        contains a buffer-overrun bug: it returns the complete list  of  groups
  >        for  user  in  the array groups, even when the number of groups exceeds
  >        *ngroups.
  
  Yuck.  The function is also not in POSIX or any other standards, so
  maybe it's worth discussing at a later point whether getgroups(2) would
  be a better interface to use, even if it means an extra step or two.

There's no sense in making nfs-utils portable to non-linux, so depending on
glibc is probably ok.  2.3.3 was released in December 2003 so I would argue
we don't care about the buffer-overrun bug.

  Anyway, I will re-spin this patch with the two changes that you've
  suggested and submit it tomorrow.   Care to take a look at patch
  2/2?  :)

It looked fine to me.
