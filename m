From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: 2.6.24.3 kernel BUG at fs/nfs/pagelist.c:82
Date: Sat, 12 Apr 2008 11:42:06 +0200
Message-ID: <20080412094205.GA29211@janus>
References: <20080319094942.GA7627@janus> <1206017233.8465.7.camel@heimdal.trondhjem.org> <20080320125716.GA20071@janus> <20080410115433.GA29211@janus> <1207944436.14621.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:47181 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756457AbYDLJmI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Apr 2008 05:42:08 -0400
In-Reply-To: <1207944436.14621.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 11, 2008 at 04:07:16PM -0400, Trond Myklebust wrote:
> 
> On Thu, 2008-04-10 at 13:54 +0200, Frank van Maarseveen wrote:
> > FYI,
> > 
> > On Thu, Mar 20, 2008 at 01:57:16PM +0100, Frank van Maarseveen wrote:
> > > On Thu, Mar 20, 2008 at 08:47:13AM -0400, Trond Myklebust wrote:
> > > > 
> > > > On Wed, 2008-03-19 at 10:49 +0100, Frank van Maarseveen wrote:
> > > > > FYI,
> > > > > 
> > > > > 2.6.24.3 wrote:
> > > > > > kernel BUG at fs/nfs/pagelist.c:82!
> > > > > 
> > > > > BUG_ON(PagePrivate(page));
[...]
> > > > > The machine is a quad Xeon with 4GB ram with CONFIG_HIGHMEM64G=y
> > > > 
> > > > Would that be on a file that was open for read and write, or is it
> > > > possible that some other process was writing to the same file? If so,
> > > > then it might be a bug in nfs_wb_page().
> > > 
> > > Yes, I'm quite sure it was a "tail -f" on a logfile which gets
> > > continuously appended to by another process.. So, one process reads it
> > > while another one writes to it through different descriptors/struct file.
> > 
> > The problem occurred again on a different box under exactly the same
> > userland conditions yielding exactly the same stack trace. Kernels are
> > identical but no vmware modules this time.
> 
> Just a quick question: how does your > 16 groups patch behave when it is
> denied a write with an EACCES error? I've got a feeling that this may be
> due to the page getting redirtied and the RPC call retried. If so, then
> the following patch may help.

The >16 groups patch doesn't do anything special with file I/O
(credentials are determined at open time) and is not retrying
anywhere upon error.

It's just one process which writes a big logfile on NFS (also involving
small writes) and a tail -f trying to catch up. The machine is heavily
loaded at that time, probably both CPU and networking I/O (non-NFS).

-- 
Frank
