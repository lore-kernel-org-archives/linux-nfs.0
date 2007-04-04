From: "Greg Bradner" <greg.bradner@gmail.com>
Subject: Re: lockd and statd
Date: Wed, 4 Apr 2007 09:09:08 -0700
Message-ID: <57bc13580704040909o386259f1q84367459ce555671@mail.gmail.com>
References: <57bc13580704040011u3058e6d9wd0d4fc0de63d4d93@mail.gmail.com>
	<1175690426.6118.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HZ82l-0005t3-V0
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 09:09:08 -0700
Received: from wr-out-0506.google.com ([64.233.184.230])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HZ82o-0006WL-3W
	for nfs@lists.sourceforge.net; Wed, 04 Apr 2007 09:09:10 -0700
Received: by wr-out-0506.google.com with SMTP id i20so350178wra
	for <nfs@lists.sourceforge.net>; Wed, 04 Apr 2007 09:09:09 -0700 (PDT)
In-Reply-To: <1175690426.6118.6.camel@heimdal.trondhjem.org>
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

On 4/4/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> On Wed, 2007-04-04 at 00:11 -0700, Greg Bradner wrote:
> > I'm getting these errors in the syslog:
> > Apr  4 00:08:53 fbs2 kernel: statd: server localhost not responding, timed out
> > Apr  4 00:08:53 fbs2 kernel: lockd: cannot monitor fnas2
> > Apr  4 00:08:53 fbs2 kernel: lockd: failed to monitor fnas2
> >
> >
> > I'm using the 2.6.20.4 kernel.
> >
> > I don't see any statd.c in the src tree.
> >
> > Did I miss something Ideas?
>
> statd lives in userland, and is part of the nfs-utils package. It should
> be pretty standard in all distributions that claim to support nfs.
>

That's what I thought.  But it doesn't seem to be the case with SUSE 9.3:

> rpm -ql nfs-utils-1.0.7-3
/etc/init.d/nfsserver
/sbin/rpc.lockd
/usr/sbin/exportfs
/usr/sbin/nfsstat
/usr/sbin/nhfsgraph
/usr/sbin/nhfsnums
/usr/sbin/nhfsrun
/usr/sbin/nhfsstone
/usr/sbin/rcnfsserver
/usr/sbin/rpc.mountd
/usr/sbin/rpc.nfsd
/usr/sbin/showmount
/usr/share/doc/packages/nfs-utils
/usr/share/doc/packages/nfs-utils/ChangeLog
/usr/share/doc/packages/nfs-utils/INSTALL
/usr/share/doc/packages/nfs-utils/KNOWNBUGS
/usr/share/doc/packages/nfs-utils/NEW
/usr/share/doc/packages/nfs-utils/README
/usr/share/doc/packages/nfs-utils/THANKS
/usr/share/doc/packages/nfs-utils/TODO
/usr/share/doc/packages/nfs-utils/index.html
/usr/share/doc/packages/nfs-utils/nfs.html
/usr/share/doc/packages/nfs-utils/nfs.ps
/usr/share/doc/packages/nfs-utils/node1.html
/usr/share/doc/packages/nfs-utils/node10.html
/usr/share/doc/packages/nfs-utils/node11.html
/usr/share/doc/packages/nfs-utils/node12.html
/usr/share/doc/packages/nfs-utils/node13.html
/usr/share/doc/packages/nfs-utils/node14.html
/usr/share/doc/packages/nfs-utils/node15.html
/usr/share/doc/packages/nfs-utils/node16.html
/usr/share/doc/packages/nfs-utils/node17.html
/usr/share/doc/packages/nfs-utils/node18.html
/usr/share/doc/packages/nfs-utils/node19.html
/usr/share/doc/packages/nfs-utils/node2.html
/usr/share/doc/packages/nfs-utils/node20.html
/usr/share/doc/packages/nfs-utils/node21.html
/usr/share/doc/packages/nfs-utils/node22.html
/usr/share/doc/packages/nfs-utils/node23.html
/usr/share/doc/packages/nfs-utils/node24.html
/usr/share/doc/packages/nfs-utils/node25.html
/usr/share/doc/packages/nfs-utils/node26.html
/usr/share/doc/packages/nfs-utils/node27.html
/usr/share/doc/packages/nfs-utils/node3.html
/usr/share/doc/packages/nfs-utils/node4.html
/usr/share/doc/packages/nfs-utils/node5.html
/usr/share/doc/packages/nfs-utils/node6.html
/usr/share/doc/packages/nfs-utils/node7.html
/usr/share/doc/packages/nfs-utils/node8.html
/usr/share/doc/packages/nfs-utils/node9.html
/usr/share/man/man5/exports.5.gz
/usr/share/man/man7/nfsd.7.gz
/usr/share/man/man8/exportfs.8.gz
/usr/share/man/man8/lockd.8.gz
/usr/share/man/man8/mountd.8.gz
/usr/share/man/man8/nfsd.8.gz
/usr/share/man/man8/nfsstat.8.gz
/usr/share/man/man8/nhfsgraph.8.gz
/usr/share/man/man8/nhfsnums.8.gz
/usr/share/man/man8/nhfsrun.8.gz
/usr/share/man/man8/nhfsstone.8.gz
/usr/share/man/man8/rpc.mountd.8.gz
/usr/share/man/man8/rpc.nfsd.8.gz
/usr/share/man/man8/showmount.8.gz
/var/adm/fillup-templates/sysconfig.nfs-nfs-utils
/var/lib/nfs
/var/lib/nfs/etab
/var/lib/nfs/rmtab
/var/lib/nfs/xtab

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
