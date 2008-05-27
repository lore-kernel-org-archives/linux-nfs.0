From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: lost interrupt after a signal?
Date: Tue, 27 May 2008 11:35:31 -0600
Message-ID: <20080527173530.GM30894@parisc-linux.org>
References: <2A43EAAA-8AEC-4EA1-AAA6-1AE1C750DB4C@oracle.com> <20080523035004.GY2638@parisc-linux.org> <D56CE258-FB78-4449-A1D8-376BB3D93387@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:36284 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756693AbYE0Rfr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 May 2008 13:35:47 -0400
In-Reply-To: <D56CE258-FB78-4449-A1D8-376BB3D93387@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 27, 2008 at 11:59:00AM -0400, Chuck Lever wrote:
> >This isn't jumping out screaming that it's my fault (obviously it
> >probably is, but ...).  invalidate_inode_pages2_range calls  
> >lock_page()
> >... which uses TASK_UNINTERRUPTIBLE.  If it were calling
> >lock_page_killable(), I'd understand.
> 
> I don't think it's directly caused by your changes, but my concern is  
> that you may have exposed a latent bug, or exposed an underlying  
> design assumption in the NFS/RPC client stack that causes the hang in  
> this situation.

Certainly possible.

> >Maybe this isn't the problem task though.  Maybe this is just the
> >canary that dropped dead, and we should stop trying to autopsy it and
> >start running.  [ok, I'll stop with the bad analogies now]
> 
> This appears to be the only task that is in this state.  All the  
> others in the dump are waiting for this inode's mutex.  I don't know  
> if the dump is complete, though.

My thought is that the task which caused the problem has gone away and
left this page in a state where sync_page will never finish.

> I've passed your suggestions along to our testers.

Thanks!  I'm keen to get this fixed.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
