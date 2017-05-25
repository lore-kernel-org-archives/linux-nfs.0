Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51002 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966118AbdEYN0d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 May 2017 09:26:33 -0400
Date: Thu, 25 May 2017 09:26:25 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Eryu Guan <eguan@redhat.com>
Cc: fstests@vger.kernel.org,
        Weston Andros Adamson <dros@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC PATCH] nfs: test nfs4_getfacl near page size ACL from server
Message-ID: <20170525132625.GA6658@parsley.fieldses.org>
References: <20170516120909.827-1-eguan@redhat.com>
 <20170516150745.GB21704@parsley.fieldses.org>
 <20170517033854.GA7250@eguan.usersys.redhat.com>
 <20170517172035.GD5011@parsley.fieldses.org>
 <20170525040119.GB23805@eguan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170525040119.GB23805@eguan.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 25, 2017 at 12:01:19PM +0800, Eryu Guan wrote:
> Yes, that's a problem, it's been 'xfstests' for at least 14 years and
> 'fstests' is only there for 3 years, sometimes (or most of the times) we
> still call it 'xfstests' for a better understanding.

Just to troll slightly: I actually don't believe you when you say it's
been renamed.  I don't see any evidence of that.

The repository still seems to be called xfstests-dev, the README calls
it "the FSQA suite" or "xfstests", with only a brief mention of the
fstest mailing list at the end.  In fact that's the only use of the term
"fstests" in the entire repository:

	$ git grep '\<xfstests'|wc -l
	36
	$ git grep '\<fstests'|wc -l
	1

And I'm not turning up any references to fstests from google except for
references to the mailing list name.  Your email here is the only
reference I can find to the project being renamed at all.  (I do see one
mail announcing the mailist name change.)

> > Anyway, thanks for adding this.  I do a partial fstests run as part of
> 
> Can I take it as a "Reviewed-by" tag? :)

Sure.

> For a quick smoke test
> 
> './check -nfs -g quick'
> 
> (run tests in 'quick' group) will do, it only takes around 10 minutes for me to complete.
> 
> And for something more thoroughly, you can do
> 
> './check -nfs -g auto'

Thanks!

I've got my own handpicked list of tests, partly because I didn't notice
the existance of "quick", partly because there were some failures I
didn't have the time to triage.

> (run tests in 'auto' group), which will take longer time but runs many
> more tests.
> 
> I test every RC release with local-mounted NFS, with NFSv3,
> NFSv4.0/4.1/4.2. Here're the 'known issues' I have for 4.11 kernel (I
> think some failures are false alert, the tests need updates, some
> failures may long standing & low priority bugs on NFS? But I'm not sure
> which is which)
> 
> Failures for all NFS versions:
...

Thanks again!  I'll try to set aside some time to reconcile this with my
own list and see if I can figure out some of the failures.

--b.
