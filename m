Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from os.inf.tu-dresden.de ([141.76.48.99]:33568 "EHLO
	os.inf.tu-dresden.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932831Ab1CXW2M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Mar 2011 18:28:12 -0400
Date: Thu, 24 Mar 2011 23:28:07 +0100
From: Adam Lackorzynski <adam@os.inf.tu-dresden.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        xfs@oss.sgi.com
Subject: Re: 2.6.38: Quota over NFS4
Message-ID: <20110324222807.GC10821@os.inf.tu-dresden.de>
References: <20110320214316.GB26036@fieldses.org>
 <20110321184043.GC4992@os.inf.tu-dresden.de>
 <20110321222301.GB472@fieldses.org>
 <20110322221305.GA5857@os.inf.tu-dresden.de>
 <20110323150328.GD23418@fieldses.org>
 <20110323174052.GE5005@os.inf.tu-dresden.de>
 <20110323190632.GA26306@fieldses.org>
 <20110323223017.GA5177@os.inf.tu-dresden.de>
 <20110324171704.GA1784@infradead.org>
 <20110324175106.GB1886@fieldses.org>
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <20110324175106.GB1886@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Thu Mar 24, 2011 at 13:51:06 -0400, J. Bruce Fields wrote:
> On Thu, Mar 24, 2011 at 01:17:05PM -0400, Christoph Hellwig wrote:
> > On Wed, Mar 23, 2011 at 11:30:17PM +0100, Adam Lackorzynski wrote:
> > > I probably mistyped something and thus bisected again:
> > 
> > maybe this is just a symptom.  When was the nfs4 code converted
> > to just use a single open struct file, and what are the lifetime
> > rules for it?  It would easily be that a long alive file might
> > make XFS keep persistent preallocations longer or similar issues.
> 
> Definitely, the commit he's bisect to there seems much more likely to be
> a culprit.  I'll take a closer look....
> 
> > Adam, can you create a loop filesystem with ext3 or something else
> > on it and see if the problem is XFS-specific?
> 
> Originally it sounded like he was able to reproduce this only on one
> specific filesystem so I wondered whether there was something particular
> to that filesystem.

I just found out it happens also with a newly created xfs and also with
ext3 and ext4. The reason that I did not see that initially is that the
script I'm using needs to be on the same fs which wasn't the case when I
initially tried it with a new fs. The sequence I'm using is:

# mount x.x.x:/home /tmp/st
# su - foo
$ cd /tmp/st/foo/x
$ ../test-script
foo@host:/tmp/st/foo/x$ ../test-script 
Filesystem            Inodes   IUsed   IFree IUse% Mounted on
x.x.x:/home    39321600      15 39321585    1% /tmp/st
Filesystem            Inodes   IUsed   IFree IUse% Mounted on
x.x.x:/home    39321600      16 39321584    1% /tmp/st
Filesystem            Inodes   IUsed   IFree IUse% Mounted on
x.x.x:/home    39321600      16 39321584    1% /tmp/st



test-script:
#! /bin/sh

df -i .
cp /bin/ls x1
df -i .
cat x1 > /dev/null
rm x1
df -i .






Adam
-- 
Adam                 adam@os.inf.tu-dresden.de
  Lackorzynski         http://os.inf.tu-dresden.de/~adam/
