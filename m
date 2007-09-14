From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] [PATCH 2/7] NFS: if ATTR_KILL_S*ID bits are set, then
 skip mode change
Date: Fri, 14 Sep 2007 10:58:38 -0400
Message-ID: <20070914105838.efbfc45e.jlayton@redhat.com>
References: <200709041437.l84Eb4lw010007@dantu.rdu.redhat.com>
	<20070914102545.GF21965@sgi.com>
	<20070914070258.8fccb40e.jlayton@redhat.com>
	<20070914130924.GG21965@sgi.com>
	<20070914093846.7cdd89da.jlayton@redhat.com>
	<20070914144033.GD25610@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: reiserfs-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	ecryptfs-devel@lists.sourceforge.net, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org, unionfs@filesystems.org,
	linux-cifs-client@lists.samba.org
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070914144033.GD25610@sgi.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sat, 15 Sep 2007 00:40:33 +1000
Greg Banks <gnb@sgi.com> wrote:

> On Fri, Sep 14, 2007 at 09:38:46AM -0400, Jeff Layton wrote:
> > On Fri, 14 Sep 2007 23:09:24 +1000
> > Greg Banks <gnb@sgi.com> wrote:
> > 
> > > On Fri, Sep 14, 2007 at 07:02:58AM -0400, Jeff Layton wrote:
> > > > On Fri, 14 Sep 2007 20:25:45 +1000
> > > > Greg Banks <gnb@sgi.com> wrote:
> > > > 
> > > > > I'm curious about the reasons behind this change.  You mention
> > > > > credential issues; how exactly is it that you have the correct creds
> > > > > to perform a WRITE rpc but not a SETATTR rpc?
> > > > > 
> > > > 
> > > > Consider this case. user1 and user2 are both members of group
> > > > "allusers":
> > > > 
> > > > user1$ echo foo > foo
> > > > user1$ chgrp allusers foo
> > > > user1$ chmod 04770 foo
> > > > user2$ echo bar >> foo
> > > > 
> > > > On most local filesystems, this would work correctly. The end result
> > > > would be a file with mode 0770 and the expected contents. On NFS
> > > > though, the write by user2 fails. When the write is attempted, the
> > > > kernel tries to squash the setuid bit using the credentials of user2,
> > > > who's not allowed to change the mode. The write then fails because the
> > > > setattr fails.
> > > 
> > > Ok, I ran an experiment and I see this failure mode.
> > > 
> > > So the SETATTR rpc is really a side effect of the client kernel's
> > > behaviour and not an operation directly requested by the user process
> > > on the client.  Is there any reason why that rpc needs to have user2's
> > > creds?  Why not do the rpc with a fake set of creds with uid and gid
> > > set to the uid and gid of the file, in this case user1/allusers ?
> > > That way the rpc will most likely pass the server's permission check.
> > > 
> > 
> > That might work in some cases, but there are many where it wouldn't...
> > 
> > Suppose user1 here is root and all of the user1 operations are being
> > done on the server. If the server has root squashing enabled, then
> > user2's operation would still fail.
> 
> In that case, user1's operations would also fail, which is even more
> serious a problem.  Also arguably you actually *want* writes by a
> nonroot user to a setuid root executable to fail ;-)
> 

Well, user1's operations would fail if done from the client, which is
why I mentioned that they would have to be done on the server.

The second point is a good one, but POSIX says that it should be allowed
if the permissions allow for it. The whole situation is somewhat
contrived anyway, I can't think of a place where this is something
you'd really want to do, but I think we need to try to follow the spec
as best as possible...

> > Another problem:
> > 
> > Suppose we're using gssapi. There's no guarantee that the client will
> > have the proper credentials to fake up a call as user1 (you might need
> > user1 krb5 tickets, etc).
> 
> Yes, good point.  You could use the root creds, except for root squashing.
> Ok, you convinced me.
> 

Right. When I was first looking at this, I considered some similar
approaches, but hit roadblocks with all of them. The only real option
seems to be to leave this to the server, but that does assume that the
server handles this properly.

Servers that don't are broken, IMO. If Irix isn't clearing these bits
on a write then it might be good to see if they can fix that...

-- 
Jeff Layton <jlayton@redhat.com>
