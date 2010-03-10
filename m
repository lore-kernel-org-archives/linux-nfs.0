Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27941 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932814Ab0CJXI1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Mar 2010 18:08:27 -0500
Subject: Re: [git pull] vfs part 3 (write_inode mess)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: Al Viro <viro@ZenIV.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <4B955C8D.6030907@RedHat.com>
References: <1267802800.5174.6.camel@localhost.localdomain>
	 <20100305154823.GV30031@ZenIV.linux.org.uk>
	 <20100305174017.GX30031@ZenIV.linux.org.uk>  <4B955C8D.6030907@RedHat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 10 Mar 2010 18:07:29 -0500
Message-ID: <1268262449.3096.214.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-03-08 at 15:22 -0500, Steve Dickson wrote: 
> On 03/05/2010 12:40 PM, Al Viro wrote:
> > On Fri, Mar 05, 2010 at 03:48:23PM +0000, Al Viro wrote:
> >> I'm going to push the next VFS pile in about half an hour and get to the
> >> write_inode situation.  I'm not sure what's the best course here.  Note
> >> that since you've pulled it, you also have conflicts with what's in the
> >> mainline.  I can do *another* backmerge (already had one due to gfs2 trivial
> >> conflicts) and push the result.  Which will suck, since XFS conflicts
> >> are not entirely trivial and we'll get a really ugly merge node, with
> >> conflict resolution both hidden and not quite obvious.
> > 
> > OK, a backmerge it is.  Linus, could you please pull
> > git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git/ write_inode
> > or suggest a saner way to do that?
> > 
> > I've done backmerges of two points in mainline (trees that got merged
> > into mainline, actually) that created conflicts.  So at that point it's
> > (a) descendent of what's been pulled into NFS tree and (b) merges clean
> > with mainline.  All for two patches (at commit 716c28c..) ;-/
> > 
> > It's independent from the previous VFS pull; there's more stuff, hopefully
> > for later today, but the worst of the mess should be gone with that one.
> Has there been any kind of testing that show this approach does indeed
> improve performance? Any hardcore number? 
> 
> Just curious....

The main improvement I'm seeing is in number of over the wire COMMIT
operations. With a standard 2.6.32/33 kernel without these changes, if I
do something like

   iozone -t 8 -s 512m -r 128k -i0 -i1

on my old 2GB test machines then I end up seeing 1 COMMIT going on the
wire for every 4 WRITE requests. IOW: I force the server to fsync for
every 4x256K I send it.

With the new code, I'm seeing 1 COMMIT being sent for every 50 WRITE
requests.

Writeback throughput is slightly, but not hugely improved on my test
rig. Furthermore, the maximum number of unstable writes recorded
in /proc/meminfo doesn't appear to change much. All this points to the
fact that most of those extra COMMIT calls were going out for just 1 or
2 writes, probably as a result of looping in balance_dirty_pages() while
the server was busy dealing with the first COMMIT.

It is definitely worth getting rid of that extra spam to the server,
though. Furthermore, I believe that others reported larger performance
improvements when the number of commits went down.

Cheers
  Trond
