Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:44275 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879Ab3BNCCC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2013 21:02:02 -0500
Date: Thu, 14 Feb 2013 02:01:54 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Ram Pai <linuxram@us.ibm.com>
Cc: Guo Chao <yan@linux.vnet.ibm.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [RFC PATCH 05/13] vfs: take i_mutex on renamed file
Message-ID: <20130214020154.GA17947@ZenIV.linux.org.uk>
References: <1346878524-10585-1-git-send-email-bfields@redhat.com>
 <1346878524-10585-6-git-send-email-bfields@redhat.com>
 <20120906030526.GB6679@yanx>
 <20120906175118.GC21736@fieldses.org>
 <20120907022705.GA20453@yanx>
 <20120907213901.GA5927@fieldses.org>
 <20120910024051.GA10405@yanx>
 <20120910051037.GA2466@ram-ThinkPad-T61>
 <20120910063724.GA6272@yanx>
 <20120910072732.GL2387@ram-ThinkPad-T61>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120910072732.GL2387@ram-ThinkPad-T61>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 10, 2012 at 03:27:32PM +0800, Ram Pai wrote:

> > This seems still conform to the statement in the manual, in a weird way 
> > though.
> 
> I think the code that checks if the new dentry or the old dentry is a
> mount point can be safely removed. It does not serve any purpose AFAICT.

Yes, it does.  It's a _very_ traditional behaviour, on a lot of Unices,
and changing it can screw all kinds of scripts.  Worse yet, screw them
in rarely hit cases.

BTW, what do you expect to happen when the target is a mountpoint?  Suppose
the mountpoint is a directory that happens to be empty; you are asking to
rename another directory over it...

Anyway, userland API stability considerations are sufficient to NAK any
such change.  Sorry.
