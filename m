Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:58592 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755832Ab1DGMWW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Apr 2011 08:22:22 -0400
Date: Thu, 7 Apr 2011 08:22:18 -0400
From: Jim Rees <rees@umich.edu>
To: Sean Finney <sean.finney@sonyericsson.com>
Cc: linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: Re: [PATCH v2 1/2] nfs-utils: mountd: Use a dynamic buffer for
 storing lists of gid's
Message-ID: <20110407122218.GA11897@merit.edu>
References: <20110405233552.GB27961@fieldses.org>
 <1302160948-5628-1-git-send-email-sean.finney@sonyericsson.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1302160948-5628-1-git-send-email-sean.finney@sonyericsson.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sean Finney wrote:

  Previously, in auth_unix_gid, group lists were stored in an array of
  hard-coded length 100, and in the situation that the group lists for a
  particular call were too large, the array was swapped with a dynamically
  allocated/freed buffer.  For environments where users are commonly in
  a large number of groups, this isn't an ideal approach.
  
  Instead, make the group list static scoped to the function, and
  use malloc/realloc to grow it on an as-needed basis.

I would re-word this.  The list isn't static, the list pointer is.  I don't
think you need to mention that, it's just confusing.  "Use malloc/realloc to
grow the list on an as-needed basis."

  +		groups = malloc(sizeof(gid_t)*INITIAL_MANAGED_GROUPS);

Style nit:  Put blanks around the "*".

I was going to suggest you first call getgrouplist with groups set to 0 so
you can always alloc() the correct size list, but then I found this in the
man page:

BUGS
       In  glibc  versions  before  2.3.3, the implementation of this function
       contains a buffer-overrun bug: it returns the complete list  of  groups
       for  user  in  the array groups, even when the number of groups exceeds
       *ngroups.
