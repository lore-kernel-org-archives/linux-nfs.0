Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50280 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754971Ab1CQXDR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 19:03:17 -0400
Date: Thu, 17 Mar 2011 19:03:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Adam Lackorzynski <adam@os.inf.tu-dresden.de>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: 2.6.38: Quota over NFS4
Message-ID: <20110317230315.GG31845@fieldses.org>
References: <20110317133247.GB6424@os.inf.tu-dresden.de>
 <20110317173805.GB30180@fieldses.org>
 <20110317213302.GA2445@os.inf.tu-dresden.de>
 <20110317222732.GC31845@fieldses.org>
 <20110317225908.GB2445@os.inf.tu-dresden.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110317225908.GB2445@os.inf.tu-dresden.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Mar 17, 2011 at 11:59:08PM +0100, Adam Lackorzynski wrote:
> 
> On Thu Mar 17, 2011 at 18:27:32 -0400, J. Bruce Fields wrote:
> > On Thu, Mar 17, 2011 at 10:33:03PM +0100, Adam Lackorzynski wrote:
> > > 
> > > On Thu Mar 17, 2011 at 13:38:05 -0400, J. Bruce Fields wrote:
> > > > On Thu, Mar 17, 2011 at 02:32:47PM +0100, Adam Lackorzynski wrote:
> > > > > Hello,
> > > > > 
> > > > > I'm seeing a problem with quotas in a system where the server running
> > > > > 2.6.38 exports an XFS filesystem via NFS4 to a client. The client kernel
> > > > > version does not seem to play a role, checked with 2.6.38, 2.6.37 and
> > > > > 2.6.36. The following script and output show the problem:
> > > > > 
> > > > > #! /bin/sh
> > > > > 
> > > > > quota | grep home
> > > > > du
> > > > > cp /bin/ls x1
> > > > > du
> > > > > cat x1 > /dev/null
> > > > > rm x1
> > > > > du
> > > > > quota | grep home
> > > > > 
> > > > > Output:
> > > > > 
> > > > >    homes:/home/ 8194720  9072000 9174400          403670  500000  550000        
> > > > > 0       .
> > > > > 96      .
> > > > > 0       .
> > > > >    homes:/home/ 8194816  9072000 9174400          403671  500000  550000        
> > > > > 
> > > > > 
> > > > > As can be seen the 96 kb are still accounted on the quota of the user.
> > > > > Removing the 'cat' command from the script makes the quota be ok again
> > > > > (original value). Also mounting via nfs3 does not exhibit it, same for running
> > > > > the script on the nfs-server directly.
> > > > 
> > > > Does "df" show the same problem?
> > > 
> > > With '/bin/ls' it does not change at all, so I took a bigger binary
> > > which yields to:
> > > 
> > >    homes:/home/ 8203780  9072000 9174400          403688  500000  550000        
> > > 0       .
> > > Filesystem           1K-blocks      Used Available Use% Mounted on
> > >   homes:/home        513671168 335251456 178419712  66% /tmp/xx
> > > 4592    .
> > > Filesystem           1K-blocks      Used Available Use% Mounted on
> > >   homes:/home        513671168 335256576 178414592  66% /tmp/xx
> > > 0       .
> > > Filesystem           1K-blocks      Used Available Use% Mounted on
> > >   homes:/home        513671168 335256576 178414592  66% /tmp/xx
> > >    homes:/home/ 8208372  9072000 9174400          403689  500000  550000        
> > > 
> > > So yes, it seems to be there as well.
> > 
> > It might be easier to see with "df -i" (assuming we're leaking an
> > inode).
> 
> Result is as expected, inode goes one up and not down again.

Is this something special about binaries?  If you copy something other
than a binary, do you not see the bug?

--b.
