From: Jeff Layton <jtlayton@poochiereds.net>
Subject: Re: Breaking locks on a lame server?
Date: Wed, 03 May 2006 10:33:00 -0400
Message-ID: <1146666780.5635.10.camel@tleilax.poochiereds.net>
References: <445820B0.8080107@temple-baptist.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FbIQb-0005S9-7u
	for nfs@lists.sourceforge.net; Wed, 03 May 2006 07:34:09 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FbIQb-0004Er-6o
	for nfs@lists.sourceforge.net; Wed, 03 May 2006 07:34:09 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FbIQW-0006fr-UV
	for nfs@lists.sourceforge.net; Wed, 03 May 2006 07:34:06 -0700
Received: from imf22aec.mail.bellsouth.net ([205.152.59.70])
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1FbIPz-0007SY-Kn
	for nfs@lists.sourceforge.net; Wed, 03 May 2006 07:33:32 -0700
Received: from ibm65aec.bellsouth.net ([72.148.41.34])
          by imf22aec.mail.bellsouth.net with ESMTP
          id <20060503143314.VCPO19017.imf22aec.mail.bellsouth.net@ibm65aec.bellsouth.net>
          for <nfs@lists.sourceforge.net>; Wed, 3 May 2006 10:33:14 -0400
To: Erik Walthinsen <omega@temple-baptist.com>
In-Reply-To: <445820B0.8080107@temple-baptist.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, 2006-05-02 at 20:17 -0700, Erik Walthinsen wrote:
> 1) am I to expect 2.6's NFS server implementation to somehow solve this?
> 2) if not, and in the meantime, are there any means by which I can inspect 
> (lslk does nothing) and hopefully kill these locks?

One thing you can do (ableit not a nice thing), is to send a SIGKILL to
lockd on the NFS server. This will make it drop all of its locks.
Restarting statd just afterward should cue the active clients to
reacquire them. This has races, but may be better than restarting your
NAS. This works with 2.4 and 2.6 kernels.

I also recently posted a patch to add a procfs interface that would
allow dropping of locks on just a single block device (mostly to help in
clustered situations), but I received no comment on it. Depending on
your setup, that may help you as well.

-- Jeff




-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
