Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42290 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753887Ab2AQSrn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jan 2012 13:47:43 -0500
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1RnE4N-000445-9U
	for linux-nfs@vger.kernel.org; Tue, 17 Jan 2012 13:47:43 -0500
Date: Tue, 17 Jan 2012 13:47:43 -0500
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20120117184743.GB15460@fieldses.org>
References: <20111113145400.6c7a9be3@notabene.brown>
 <CAGue13r5BhjWOUF3L8Jd4_T0RmOwL7D=ktwHT_7paug5qEvKmA@mail.gmail.com>
 <20111113163632.GA28574@fieldses.org>
 <20111114080745.57083bfe@notabene.brown>
 <1321338825.8267.2.camel@lade.trondhjem.org>
 <20120113170914.GA31414@us.ibm.com>
 <20120114013834.GA20464@fieldses.org>
 <20120116165228.GA4990@us.ibm.com>
 <20120117151826.GB12274@fieldses.org>
 <20120117172231.GA21603@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120117172231.GA21603@us.ibm.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 17, 2012 at 11:22:31AM -0600, Malahal Naineni wrote:
> J. Bruce Fields [bfields@fieldses.org] wrote:
> > > Only answers can be dumb! Bruce, we have ext3/ext4 file systems on two
> > > separate servers. The file systems are mirrored using rsync as and when
> > > needed. We would like to use the servers as replicas.
> > 
> > And why aren't you rsync'ing the underlying filesystem image instead?
> > Is that too slow?
> 
> The file system image is too big to do entire image level rsync'ing.

Is there any way you could get hints from the filesystem about which
blocks are actually used, that could make this as efficient?

> > > Since the file systems are mirrored using "rsync", the NFS file handles
> > > each server exports would be different. We would like to use volatile
> > > file handles feature of NFSv4 for this.
> > 
> > In theory the hidden directory for reverse lookups would work, but it
> > seems like it would be complicated to get right:
> > 	- How do you generate the directory and keep it up to date?
> > 	- What happens if somebody breaks the rules and updates the
> > 	  filesystem while it's being exported?
> 
> I think so too. We think Volatile file handle support on the client side
> is simpler for our use case (read only NFS file systems)

Won't it be confusing to applications if inode numbers change on
migration?

--b.
