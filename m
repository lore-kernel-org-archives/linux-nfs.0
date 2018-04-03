Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42126 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751333AbeDCQC7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Apr 2018 12:02:59 -0400
Date: Tue, 3 Apr 2018 12:02:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH - v2] NFSv4: handle EINVAL from EXCHANGE_ID better.
Message-ID: <20180403160258.GC20297@fieldses.org>
References: <87bmfoc3yi.fsf@notabene.neil.brown.name>
 <878tasc3ag.fsf@notabene.neil.brown.name>
 <20180320214821.GF4288@fieldses.org>
 <87bmf115pn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87bmf115pn.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 03, 2018 at 10:41:56AM +1000, NeilBrown wrote:
> On Tue, Mar 20 2018, J. Bruce Fields wrote:
> 
> > On Fri, Mar 16, 2018 at 10:44:23AM +1100, NeilBrown wrote:
> >> 
> >> nfs4_proc_exchange_id() can return -EINVAL if the server
> >> reported NFS4INVAL (which I have seen in a packet trace),
> >
> > Can you say which server this was?  (One we can fix?)
> 
> It was Linux 2.6.32 (on armv5), and presumably anything before
> Commit: 357f54d6b382 ("NFS fix the setting of exchange id flag")
> which landed in 2.6.38.

The kernel defaulted to keeping 4.1 off at that point, probably for good
reason--that default didn't change for another 4 or 5 years.  I suspect
this is only the first of multiple 4.1 bugs you'd run into in a server
of that vintage.  So the solution is probably just to keep 4.1 off.

--b.

> 
> These servers return NFS4ERR_INVAL when EXCHGID4_FLAG_BIND_PRINC_STATEID
> is set in the exchange_id flags, which Linux has done since
> Commit: 4f0b429df104 ("NFSv4.1: Enable state protection")
> in 3.11.
> 
> Maybe NFS should retry without that flag if it gets EINVAL??  Or it could
> just say that NFSv4.1 isn't supported.  I still don't think EIO is justified.
> 
> Thanks,
> NeilBrown


