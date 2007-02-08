From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 00/12] misc nfs-utils patches
Date: Thu, 08 Feb 2007 17:26:06 -0500
Message-ID: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk3-0006sK-CH
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:47 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HFHk4-0006lj-4o
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:49 -0800
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

Here are a few nfs-utils patches:

- Minor changes to the autotools stuff.
- Add AM_MAINTAINER_MODE (In case you decide to include it)
- Add fslocations (referrals) support to exportfs
- Sent gssapi error codes down to kernel as unsigned.
- Fix memory leak in idmapd.
- Some manpage changes from Steiner that appear to have been
  missed in the preious commit.
- When selecting a Kerberos credentials cache, compare owner
  rather than name.
- Use lucid context support in newer Heimdal release
- Factor out some code in mountd
- Add option to allow svcgssd to set libnfsidmap logging verbosity


K.C.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
