From: Andreas Dilger <adilger@clusterfs.com>
Subject: Re: Problems with POSIX ACL <=> NFSv4 ACL mapping in mainline
Date: Mon, 26 Jun 2006 11:52:13 -0600
Message-ID: <20060626175213.GU5817@schatzie.adilger.int>
References: <200606231745.23344.agruen@suse.de>
	<20060623160652.GK21357@fieldses.org>
	<200606261730.09827.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-fsdevel@vger.kernel.org, Jeff Sedlak <jsedlak@umich.edu>,
	nfs@lists.sourceforge.net, Marius Aamodt Eriksen <marius@umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FuvG0-0005Jt-Kv
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 10:52:20 -0700
Received: from mail.clusterfs.com ([206.168.112.78])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1FuvFz-0007bR-Nx
	for nfs@lists.sourceforge.net; Mon, 26 Jun 2006 10:52:20 -0700
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: <200606261730.09827.agruen@suse.de>
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

On Jun 26, 2006  17:30 +0200, Andreas Gruenbacher wrote:
> The result were errors when copying files with cp -p (which preserves xattrs).

Is that true of "cp" in general, or only SuSE "cp"?  We get problems with
Lustre when root is copying files, because SuSE cp is incorrectly trying to
copy all of the EAs by default.  If I have an EA that is specific to a
file I don't necessarily want it to be copied.

It would probably be preferrable that cp only copy EAs that it understands.

Cheers, Andreas
--
Andreas Dilger
Principal Software Engineer
Cluster File Systems, Inc.


Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
