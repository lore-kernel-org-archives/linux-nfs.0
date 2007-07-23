From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [RFC:PATCH] How best to handle implicit clearing of
 setuid/setgid bits on NFS?
Date: Mon, 23 Jul 2007 15:05:48 -0400
Message-ID: <20070723150548.8f951bf6.jlayton@redhat.com>
References: <20070529124705.a1e70735.jlayton@redhat.com>
	<1182982555.5311.67.camel@heimdal.trondhjem.org>
	<20070627221354.02233c58.jlayton@redhat.com>
	<1183037902.6163.29.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, aviro@redhat.com,
	nfs@lists.sourceforge.net, nhorman@tuxdriver.com
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ID3EF-0003ab-Pk
	for nfs@lists.sourceforge.net; Mon, 23 Jul 2007 12:06:00 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ID3EI-000582-0d
	for nfs@lists.sourceforge.net; Mon, 23 Jul 2007 12:06:03 -0700
In-Reply-To: <1183037902.6163.29.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 28 Jun 2007 09:38:22 -0400
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Wed, 2007-06-27 at 22:13 -0400, Jeff Layton wrote:
> > Ok. This is a bit more complex now since we remove suid bits on
> > truncate, but don't set ATTR_FORCE.
> > 
> > Here's a patch that should do this. I know there's a general
> > aversion to adding new flags to vfs structures, but I couldn't think of
> > a way to cleanly do this without adding one.
> > 
> > Note that I've not tested this patch at all so this is just a RFC.
> > 
> > CC'ing Al here since he's expressed interest in this problem as well.
> > 
> > Thoughts?
> 
> We don't really need to do this with extra VFS flags. Here is my
> preferred approach for dealing with this problem.
> 
>         http://article.gmane.org/gmane.linux.nfs/8511/match=attr%5fkill%5fsuid
> 
> As you can see, that still allows the filesystem to determine how it
> should deal with the ATTR_KILL_SUID/ATTR_KILL_SGID flags. The default
> behaviour is provided by inode_setattr(), and is the same as today. Only
> filesystems that don't use inode_setattr() will need to be audited for
> whether or not they need a fix.
> 
> Cheers,
>   Trond


I had a look at this today, and I have some reservations about this
approach. Quite a few filesystems define a .setattr inode op, but don't
call inode_setattr. As a first pass through the current git tree, the
following setattr ops never seem to call inode_setattr:

adfs_notify_change
afs_setattr
coda_setattr
ecryptfs_setattr
fuse_setattr
jffs2_setattr
nfs_setattr (expected)
ntfs_setattr
smb_notify_change
xfs_vn_setattr

...some of these won't matter, but some will need to be fixed. There
may be other situations we'll need to fix as well.

My concern here is that we'll be moving from a "default safe" model for
filesystems that define a .setattr op to one where those filesystems
are expected to make sure that they clear setuid/gid bits. They can do
this with a simple call to inode_setattr, or on their own, but they
must do it. Is this really the right thing to do here?

It seems like an "opt-out" approach when clearing these bits might be
safer. i.e., make it so that filesystems have to explicitly disable
clearing of setuid/setgid bits.

Thoughts?

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
