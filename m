From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH 0/5] NFS private namespace patchset
Date: Wed, 24 Jun 2009 00:22:58 +0100
Message-ID: <20090623232258.GL8633@ZenIV.linux.org.uk>
References: <20090622190913.27923.31665.stgit@heimdal.trondhjem.org> <alpine.LFD.2.01.0906221238370.3240@localhost.localdomain> <20090623213309.GK8633@ZenIV.linux.org.uk> <alpine.LFD.2.01.0906231438390.3240@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <alpine.LFD.2.01.0906231438390.3240@localhost.localdomain>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 23, 2009 at 02:40:10PM -0700, Linus Torvalds wrote:
> 
> 
> On Tue, 23 Jun 2009, Al Viro wrote:
> > On Mon, Jun 22, 2009 at 12:40:33PM -0700, Linus Torvalds wrote:
> > > 
> > > 
> > > Al? Where are you?
> > 
> > Back, digging through the mailbox.
> 
> Ok, I applied Trond's private namespace patchset, since I was planning on 
> doing -rc1 today (now reconsidering due to the bulk of stuff I've done 
> today, it might be tomorrow).
> 
> But I'm still interested in fixes and particularly in the path ref leak 
> issue.
> 
> Oh, and Trond just sent out a cleanup patch that looked fine too.

OK, I've finally crawled through the pile of mail.  Will have the trees
(VFS and audit) out later tonight...
