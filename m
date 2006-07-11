From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [nfsv4] Re: NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Tue, 11 Jul 2006 10:55:55 +0200
Message-ID: <200607111055.56001.agruen@suse.de>
References: <200607032310.15252.agruen@suse.de>
	<200607091822.44656.agruen@suse.de>
	<A15E619E-E88C-420C-AEC4-4E7409F187F3@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Sam Falkner <Sam.Falkner@sun.com>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@sun.com>,
	Brian Pawlowski <beepy@netapp.com>, Lisa Week <Lisa.Week@sun.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G0E4o-0006ZF-Jw
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 01:58:42 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G0E4o-0001PO-GA
	for nfs@lists.sourceforge.net; Tue, 11 Jul 2006 01:58:43 -0700
To: nfsv4@ietf.org
In-Reply-To: <A15E619E-E88C-420C-AEC4-4E7409F187F3@Sun.COM>
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

On Tuesday, 11. July 2006 08:50, Lisa Week wrote:
> On Jul 9, 2006, at 10:22 AM, Andreas Gruenbacher wrote:
> > Note that in traditional POSIX, permissions from multiple file
> > classes will never accumulate: each user always is either granted the
> > File Owner permission bits, the File Group permission bits, or the File
> > Other permission bits. (Additional file access control mechanisms may
> > further limit the permissions granted, and alternative file access
> > control mechanisms may further limit or extend the permissions granted.)
> > Permissions from multiple acl entries accumulate in the NFSv4 ACL model
> > though, and so unless an acl is "well structured" in the above sense,
> > permissions from multiple classes may accumulate.
>
> Yes, permissions may accumulate, but in the design in the minor
> version doc, after a chmod, any permissions that go beyond the mode
> bits being set will be disabled.  This is done via the algorithm in
> section 3.16.6.3 -  "Applying a Mode to an Existing ACL".  This makes
> sure that the permissions (ACE4_READ_DATA/ACE4_LIST_DIRECTORY,
> ACE4_WRITE_DATA/ACE4_WRITE_DATA, ACE4_APPEND_DATA/
> ACE4_ADD_SUBDIRECTORY and ACE4_EXECUTE... which is what the mode
> defines) that accumulate will NOT go beyond the mode bits being set.

Ack.

Andreas


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
