Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39444 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932256Ab1C2DWH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Mar 2011 23:22:07 -0400
Date: Mon, 28 Mar 2011 23:22:05 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond@netapp.com>,
        "William A.(Andy) Adamson" <andros@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs4.1 locking broken
Message-ID: <20110329032205.GE2695@fieldses.org>
References: <201103252328.p2PNSVRY013346@pop.test.fieldses.org>
 <20110326023403.GA16277@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110326023403.GA16277@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

And, yuck, I think this is why I let such a bad screwup get by in the
server lock code: my usual automated testing depends on booting the same
kernel to client and server, and when they saw the client failure they
gave up and as a result never hit the bad server case.  Doh.  Something
else to fix in my testing.

--b.

On Fri, Mar 25, 2011 at 10:34:03PM -0400, J. Bruce Fields wrote:
> Commit 114f64b5f24abac33a42f4f1856eb3a9766d497e "NFSv4: remove duplicate
> clientid in struct nfs_client" breaks locking over 4.1; from a cthon
> run:
> 
> On Fri, Mar 25, 2011 at 07:28:31PM -0400, J. Bruce Fields wrote:
> > Starting LOCKING tests: test directory /mnt/TMP (arg: -f)
> > 
> > Testing native post-LFS locking
> > 
> > Creating parent/child synchronization pipes.
> > 
> > Test #1 - Test regions of an unlocked file.
> > 	Parent: 1.1  - F_TEST  [               0,               1] FAILED!
> > 	Parent: **** Expected success, returned EINVAL...
> > 	Parent: **** Probably implementation error.
> > 
> > ** PARENT pass 1 results: 0/0 pass, 0/0 warn, 1/1 fail (pass/total).
> > 
> > **  CHILD pass 1 results: 0/0 pass, 0/0 warn, 0/0 fail (pass/total).
> > lock tests failed
> 
> I haven't figured out why.
> 
> Presumably the lock code assumed the clientid would be unset in the 4.1
> case?
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
