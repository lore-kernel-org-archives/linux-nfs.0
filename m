From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [PATCH 0 / 1] Move NFS mount code from util-linux to
	nfs-utils - take2
Date: Thu, 15 Jun 2006 14:10:30 -0400
Message-ID: <76bd70e30606151110m419e7b7audedfe11f12573a6@mail.gmail.com>
References: <448DF279.8090005@redhat.com> <44918BDD.2C84.006B.0@novell.com>
	<1150393298.3565.2.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FqwIl-0002tn-T4
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 11:10:43 -0700
Received: from wr-out-0506.google.com ([64.233.184.237])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FqwIh-0007Zs-KZ
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 11:10:41 -0700
Received: by wr-out-0506.google.com with SMTP id 68so446915wra
	for <nfs@lists.sourceforge.net>; Thu, 15 Jun 2006 11:10:32 -0700 (PDT)
To: "Frank Filz" <ffilzlnx@us.ibm.com>
In-Reply-To: <1150393298.3565.2.camel@dyn9047022153>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On 6/15/06, Frank Filz <ffilzlnx@us.ibm.com> wrote:
> On Thu, 2006-06-15 at 05:10 -0600, Chakravarthi P wrote:
> > +                     break;
> > +             case 't':
> > +                     nfs_mount_vers = (strncmp(optarg, "nfs4", 4)) ?
> > 0 : 4;
> > +                     break;
> >
> > 2.  i dont think a -t option makes sense for mount.nfs
> >      mount.nfs itself says it is a nfs file system
> >      you can pick up the version from -o nfsvers=4  to cater to nfs
> > version
> >      -t is by legacy meant for specifying the filesystem type.
>
> -t nfs4 is required for compatibility with existing scripts
> and /etc/fstab entries.

As far as I understand this, the mount command chooses which
subcommand to execute based on the "-t" option.  So the subcommands
(such as mount.nfs) shouldn't have a "-t" option.

Instead, use two subcommands for NFS:  mount.nfs and mount.nfs4.

-- 
"We who cut mere stones must always be envisioning cathedrals"
   -- Quarry worker's creed


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
