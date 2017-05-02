Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41654 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751741AbdEBWR1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 May 2017 18:17:27 -0400
Date: Tue, 2 May 2017 15:16:49 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Anna Schumaker <Anna.Schumaker@Netapp.com>
Cc: Eryu Guan <eguan@redhat.com>, fstests@vger.kernel.org,
        linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH v5 0/5] Add copy_file_range() tests
Message-ID: <20170502221649.GA5970@birch.djwong.org>
References: <20170317195233.4042-1-Anna.Schumaker@Netapp.com>
 <20170317220246.GA12585@birch.djwong.org>
 <20170320052457.GH14226@eguan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170320052457.GH14226@eguan.usersys.redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 20, 2017 at 01:24:57PM +0800, Eryu Guan wrote:
> On Fri, Mar 17, 2017 at 03:02:46PM -0700, Darrick J. Wong wrote:
> > On Fri, Mar 17, 2017 at 03:52:28PM -0400, Anna Schumaker wrote:
> > > These tests exercise the copy_file_range() system call, and check copying
> > > data to both a new file and overwriting data inside an existing file.
> > > 
> > > Sorry it took so long to get this version out.  I forgot about these patches
> > > after the last submission.
> > 
> > Hooray, tests finally!
> > 
> > I had to bump the numbers up due to conflicts (it's usually best to pick
> > a really high number and let Eryu mvtest them to their real numbers),
> > but these mostly look ok.
> 
> Usually the test numbers are not a problem, as long as the patchset is
> based on latest master and there's no test number conflicts :)
> 
> Overall the tests look fine to me too.
> 
> > 
> > However, I do see that something isn't triggering an EINVAL return code:
> 
> Same results here, tested with xfs/ext4/btrfs on 4.11-rc2 kernel.
> 
> And another nitpick is the year in copyright, s/2016/2017/ ?

Another month, another kernel release... can we please get these tests
fixed and integrated?

--D

> 
> Thanks,
> Eryu
> --
> To unsubscribe from this list: send the line "unsubscribe fstests" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
