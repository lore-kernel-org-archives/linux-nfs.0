From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [NFS] [PATCH 2/7] NFS: if ATTR_KILL_S*ID
 bits are set, then skip mode change
Date: Fri, 14 Sep 2007 07:02:58 -0400
Message-ID: <20070914070258.8fccb40e.jlayton@redhat.com>
References: <200709041437.l84Eb4lw010007@dantu.rdu.redhat.com>
	<20070914102545.GF21965@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: reiserfs-devel@vger.kernel.org, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org, unionfs@filesystems.org,
	linux-cifs-client@lists.samba.org, linux-kernel@vger.kernel.org,
	ecryptfs-devel@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org>
In-Reply-To: <20070914102545.GF21965@sgi.com>
List-Unsubscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/archive/linux-cifs-client>
List-Post: <mailto:linux-cifs-client@lists.samba.org>
List-Help: <mailto:linux-cifs-client-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=subscribe>
Sender: linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org
Errors-To: linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, 14 Sep 2007 20:25:45 +1000
Greg Banks <gnb@sgi.com> wrote:

> On Tue, Sep 04, 2007 at 10:37:04AM -0400, Jeff Layton wrote:
> > If the ATTR_KILL_S*ID bits are set then any mode change is only for
> > clearing the setuid/setgid bits. For NFS skip the mode change and
> > let the server handle it.
> 
> You're assuming the server will remove setuid and setgid bits on WRITE?
> I don't see that behaviour specified in the RFC, at least for v3.
> The RFC specifies a behaviour for the mtime attribute as a side
> effect of WRITE, but says nothing about mode.  This means server
> implementations are free to clobber setuid or not.  A quick experiment
> shows that at least the Irix server will *NOT* clobber those bits.
> So with an Irix server you've now lost this Linux-specific "security
> feature".
> 
> I'm curious about the reasons behind this change.  You mention
> credential issues; how exactly is it that you have the correct creds
> to perform a WRITE rpc but not a SETATTR rpc?
> 

Consider this case. user1 and user2 are both members of group
"allusers":

user1$ echo foo > foo
user1$ chgrp allusers foo
user1$ chmod 04770 foo
user2$ echo bar >> foo

On most local filesystems, this would work correctly. The end result
would be a file with mode 0770 and the expected contents. On NFS
though, the write by user2 fails. When the write is attempted, the
kernel tries to squash the setuid bit using the credentials of user2,
who's not allowed to change the mode. The write then fails because the
setattr fails.

There are other situations that are similar, but the bottom line is
that the linux-specific security feature doesn't work in all cases, and
in some situations it means that operations fail where they shouldn't.

-- 
Jeff Layton <jlayton@redhat.com>
