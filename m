From: James Yarbrough <jmy@lolita.engr.sgi.com>
Subject: Re: [RFC] NLM lock failover admin interface
Date: Tue, 13 Jun 2006 08:23:44 -0700 (PDT)
Message-ID: <200606131523.k5DFNila1061570@lolita.engr.sgi.com>
References: <1150089943.26019.18.camel@localhost.localdomain>
Content-Type: multipart/mixed; boundary="===============1271479519=="
Cc: linux-cluster@redhat.com, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FqAkD-0006hh-Fb
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 08:23:53 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FqAkC-0006BB-Cc
	for nfs@lists.sourceforge.net; Tue, 13 Jun 2006 08:23:53 -0700
To: Wendy Cheng <wcheng@redhat.com>, Neil Brown <neilb@suse.de>
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

--===============1271479519==

> There seems to be an unstated assumption here that there is one
> virtual IP per exported filesystem.  Is that true?

This is the normal case for such HA services.  There may actually be
a single IP address covering multiple filesystems and/or NFS exports.

> I think that maybe the right thing to do is *not* drop the locks on a
> particular filesystem, but to drop the locks made to a particular
> virtual IP.

For filesystems such as ext2 or xfs, you unmount the filesystem on the
current server and mount it on the new server when doing a failover.
In this case, you have to be able to get rid of all the locks first and
you do that for the entire filesystem.  For a cluster filesystem such as
cxfs, you don't actually unmount the filesystem, so you really need the
per-IP address approach.

> If I want to force-unmount a filesystem, I need to unexport it, and I
> need to kill all the locks.  Currently you can only remove locks from
> all filesystems, which might not be ideal.

This is definitely less than ideal.  This will force notification and
reclaim for all exported filesystems.  This can be a significant problem.

jmy@sgi.com
650 933 3124

Why is there a snake in my Coke?


--===============1271479519==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1271479519==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1271479519==--
