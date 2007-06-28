From: Stuart Anderson <anderson@ligo.caltech.edu>
Subject: Re: NFSv4 uninitialized mtime
Date: Wed, 27 Jun 2007 20:23:56 -0700
Message-ID: <20070628032356.GB18337@ligo.caltech.edu>
References: <20070627233114.GA14508@ligo.caltech.edu>
	<1182987805.5311.77.camel@heimdal.trondhjem.org>
	<20070628004904.GK9806@ligo.caltech.edu>
	<20070628005957.GA16461@ligo.caltech.edu>
	<20070627211559.e9fc68dd.jlayton@redhat.com>
	<20070628025327.GA18337@ligo.caltech.edu>
	<7FEBE408-60C8-41F3-99A3-9ABF1A381D44@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Spencer Shepler <Spencer.Shepler@Sun.COM>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3kc3-0006bw-P4
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:24:07 -0700
Received: from acrux.ligo.caltech.edu ([131.215.115.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3kc4-0007Ro-Vi
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:24:11 -0700
In-Reply-To: <7FEBE408-60C8-41F3-99A3-9ABF1A381D44@sun.com>
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

On Wed, Jun 27, 2007 at 10:09:23PM -0500, Spencer Shepler wrote:
> >Somewhat related is the reason that we are tring NFSV4 on Linux  
> >clients is
> >that with NFSV3 ACL's do not work between Linux and Solaris if the  
> >filesystem
> >on the Solaris server is ZFS, e.g., cp -p will generate interesting  
> >error
> >messages. While I would rather stay with NFSV4 if possible, has anyone
> >gotten this configuration to work with V3?
> 
> It will not.  ZFS does not support the "old" ACL definition; only  
> NFSv4 support.
> 

Understood, so this is probably not a bug and just a feature, but why
does a Linux client try and then generate application level errors?
A Solaris client is willing to NFS mount vers=3 a ZFS filesystem and then
run GNU cp -rp, for example, without complaint. Perhaps there is a simple
method determine if ACL's are available/supported on a particular NFS
mount?

Thanks.

-- 
Stuart Anderson  anderson@ligo.caltech.edu
http://www.ligo.caltech.edu/~anderson

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
