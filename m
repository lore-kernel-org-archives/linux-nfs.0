From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [git pull] vfs part 3 (write_inode mess)
Date: Mon, 08 Mar 2010 15:22:37 -0500
Message-ID: <4B955C8D.6030907@RedHat.com>
References: <1267802800.5174.6.camel@localhost.localdomain> <20100305154823.GV30031@ZenIV.linux.org.uk> <20100305174017.GX30031@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15171 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755684Ab0CHUWu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 15:22:50 -0500
In-Reply-To: <20100305174017.GX30031@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/05/2010 12:40 PM, Al Viro wrote:
> On Fri, Mar 05, 2010 at 03:48:23PM +0000, Al Viro wrote:
>> I'm going to push the next VFS pile in about half an hour and get to the
>> write_inode situation.  I'm not sure what's the best course here.  Note
>> that since you've pulled it, you also have conflicts with what's in the
>> mainline.  I can do *another* backmerge (already had one due to gfs2 trivial
>> conflicts) and push the result.  Which will suck, since XFS conflicts
>> are not entirely trivial and we'll get a really ugly merge node, with
>> conflict resolution both hidden and not quite obvious.
> 
> OK, a backmerge it is.  Linus, could you please pull
> git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git/ write_inode
> or suggest a saner way to do that?
> 
> I've done backmerges of two points in mainline (trees that got merged
> into mainline, actually) that created conflicts.  So at that point it's
> (a) descendent of what's been pulled into NFS tree and (b) merges clean
> with mainline.  All for two patches (at commit 716c28c..) ;-/
> 
> It's independent from the previous VFS pull; there's more stuff, hopefully
> for later today, but the worst of the mess should be gone with that one.
Has there been any kind of testing that show this approach does indeed
improve performance? Any hardcore number? 

Just curious....

steved.

