From: Greg Banks <gnb@sgi.com>
Subject: Re: [NFS] [PATCH 2/7] NFS: if ATTR_KILL_S*ID bits
	are set, then skip mode change
Date: Fri, 14 Sep 2007 23:09:24 +1000
Message-ID: <20070914130924.GG21965@sgi.com>
References: <200709041437.l84Eb4lw010007@dantu.rdu.redhat.com>
	<20070914102545.GF21965@sgi.com>
	<20070914070258.8fccb40e.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org, reiserfs-devel@vger.kernel.org,
	ecryptfs-devel@lists.sourceforge.net, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org, unionfs@filesystems.org,
	linux-cifs-client@lists.samba.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <ecryptfs-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070914070258.8fccb40e.jlayton@redhat.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ecryptfs-devel>,
	<mailto:ecryptfs-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=ecryptfs-devel>
List-Post: <mailto:ecryptfs-devel@lists.sourceforge.net>
List-Help: <mailto:ecryptfs-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ecryptfs-devel>,
	<mailto:ecryptfs-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: ecryptfs-devel-bounces@lists.sourceforge.net
Errors-To: ecryptfs-devel-bounces@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

On Fri, Sep 14, 2007 at 07:02:58AM -0400, Jeff Layton wrote:
> On Fri, 14 Sep 2007 20:25:45 +1000
> Greg Banks <gnb@sgi.com> wrote:
> 
> > I'm curious about the reasons behind this change.  You mention
> > credential issues; how exactly is it that you have the correct creds
> > to perform a WRITE rpc but not a SETATTR rpc?
> > 
> 
> Consider this case. user1 and user2 are both members of group
> "allusers":
> 
> user1$ echo foo > foo
> user1$ chgrp allusers foo
> user1$ chmod 04770 foo
> user2$ echo bar >> foo
> 
> On most local filesystems, this would work correctly. The end result
> would be a file with mode 0770 and the expected contents. On NFS
> though, the write by user2 fails. When the write is attempted, the
> kernel tries to squash the setuid bit using the credentials of user2,
> who's not allowed to change the mode. The write then fails because the
> setattr fails.

Ok, I ran an experiment and I see this failure mode.

So the SETATTR rpc is really a side effect of the client kernel's
behaviour and not an operation directly requested by the user process
on the client.  Is there any reason why that rpc needs to have user2's
creds?  Why not do the rpc with a fake set of creds with uid and gid
set to the uid and gid of the file, in this case user1/allusers ?
That way the rpc will most likely pass the server's permission check.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
