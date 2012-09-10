Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e6.ny.us.ibm.com ([32.97.182.146]:54851 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751200Ab2IJH2P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Sep 2012 03:28:15 -0400
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <linuxram@us.ibm.com>;
	Mon, 10 Sep 2012 03:28:14 -0400
Date: Mon, 10 Sep 2012 15:27:32 +0800
From: Ram Pai <linuxram@us.ibm.com>
To: Guo Chao <yan@linux.vnet.ibm.com>
Cc: Ram Pai <linuxram@us.ibm.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [RFC PATCH 05/13] vfs: take i_mutex on renamed file
Message-ID: <20120910072732.GL2387@ram-ThinkPad-T61>
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
 <1346878524-10585-6-git-send-email-bfields@redhat.com>
 <20120906030526.GB6679@yanx>
 <20120906175118.GC21736@fieldses.org>
 <20120907022705.GA20453@yanx>
 <20120907213901.GA5927@fieldses.org>
 <20120910024051.GA10405@yanx>
 <20120910051037.GA2466@ram-ThinkPad-T61>
 <20120910063724.GA6272@yanx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120910063724.GA6272@yanx>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 10, 2012 at 02:37:24PM +0800, Guo Chao wrote:
> On Mon, Sep 10, 2012 at 01:10:37PM +0800, Ram Pai wrote:
> > On Mon, Sep 10, 2012 at 10:40:51AM +0800, Guo Chao wrote:
> > > 
> > > Hard to say whether it's a bug or what's problems of being able to rename 
> > > mountpoint.
> > 
> > 'man 2 rename' says it is ok to rename a directory that is already
> > mounted.
> > 
> > EBUSY The rename fails because oldpath or newpath is a directory that is
> > in use by some process (perhaps as current working directory, or as root
> > directory, or beacuse it was open for reading) or is in use by the
> > system (for example as mount point), while the system considers this an
> > error. (Note that there is no requirement to return EBUSY in such
> > cases-- there is nothing wrong with doing the rename anyway -- but is
> > 	^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > allowed to return EBUSY if the system cannot otherwise handle such
> > situations)
> > 
> > RP
> 
> Erhh, good point. 
> 
> However, current implementation seems to return EBUSY unconditionally, 
> instead of considering whether it can handle this situation. It can be 
> descripted as 'it may return EBUSY or not, depends on whether you are 
> luck enough to rush into the race'.
> 
> This seems still conform to the statement in the manual, in a weird way 
> though.

I think the code that checks if the new dentry or the old dentry is a
mount point can be safely removed. It does not serve any purpose AFAICT.

RP

