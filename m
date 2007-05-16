From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/2] NFS: Add the mount option nosharedcache
Date: Wed, 16 May 2007 09:22:37 -0400
Message-ID: <1179321757.6521.26.camel@heimdal.trondhjem.org>
References: <17992.63372.522494.519874@notabene.brown>
	<20070516013656.26323.55568.stgit@heimdal.trondhjem.org>
	<17994.32412.173039.15055@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Paul Krizak <paul.krizak@amd.com>, nfs@lists.sourceforge.net,
	Ian Kent <raven@themaw.net>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HoJSl-0000c9-EA
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 06:22:43 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HoJSo-0000Jf-5o
	for nfs@lists.sourceforge.net; Wed, 16 May 2007 06:22:46 -0700
In-Reply-To: <17994.32412.173039.15055@notabene.brown>
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

On Wed, 2007-05-16 at 13:46 +1000, Neil Brown wrote:
> On Tuesday May 15, Trond.Myklebust@netapp.com wrote:
> > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > 
> > Add a flag to allow users to elect not to share the NFS super block with
> > another mount point, even if the fsids are the same. This will allow
> > users to set different mount options for the two different super blocks,
> > and is safe as long as they do not have inodes in common.
> 
> Thanks.
> Just to clarify:  By "is safe" you mean won't cause cache-coherence
> strangeness", or is there some other safety issue that I'm missing.

cache coherency is what I'm referring to. I'll attempt to clarify that.

> > 
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > ---
> > 
> >  fs/nfs/super.c             |   34 +++++++++++++++++++++++++++++-----
> >  include/linux/nfs4_mount.h |    1 +
> >  include/linux/nfs_mount.h  |    1 +
> >  3 files changed, 31 insertions(+), 5 deletions(-)
> > 
> > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > index ca20d3c..c03120a 100644
> > --- a/fs/nfs/super.c
> > +++ b/fs/nfs/super.c
> > @@ -291,6 +291,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
> >  		{ NFS_MOUNT_NONLM, ",nolock", "" },
> >  		{ NFS_MOUNT_NOACL, ",noacl", "" },
> >  		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
> > +		{ NFS_MOUNT_UNSHARED, ",nosharecache", ""},
>                                         ^^^^^^^^^^^^
> 
> This is different to the spelling used in the subject line.  Was that
> intentional, or a typo?

No. This was the correct spelling, and the title line is wrong. I'll fix
it up...

Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
