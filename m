From: Andreas Gruenbacher <agruen@suse.de>
Subject: Problems with POSIX ACL <=> NFSv4 ACL mapping in mainline
Date: Fri, 23 Jun 2006 17:45:22 +0200
Message-ID: <200606231745.23344.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ftno7-0008L8-GY
	for nfs@lists.sourceforge.net; Fri, 23 Jun 2006 08:42:55 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ftno5-0002s2-37
	for nfs@lists.sourceforge.net; Fri, 23 Jun 2006 08:42:55 -0700
To: Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>, J.Bruce Fields <bfields@umich.edu>
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

Hello,

we have a problem with the POSIX ACL <=> NFSv4 ACL mapping as currently 
implemented in NFSv4 in mainline: it is implemented on the server side only, 
which leads to interesting problems. I'll try to explain.

POSIX ACLs [1] and NFSv4 ACLs [2] are based on very different concepts, and so 
they don't map onto each other very well. Marius and others are proposing a 
mapping between the two formats [3], and an implementation of that mapping 
seems to have found its way into the mainline nfsv4 implementation. (Note 
that I didn't actually verify the implemented mapping actually reflects draft 
[3].)

The mapping from POSIX ACLs to NFSv4 ACLs and back is implemented only on the 
server side only right now: POSIX ACLs on the server are presented as NFSv4 
ACLs over the network, and as "system.nfs4_acl" extended attributes to 
user-space on the client. This is no problem when moving or copying files 
between NFSv4 mounts, but other filesystems on the client don't know how to 
deal with "system.nfs4_acl" attributes, and so preserving those attributes 
will inevitably fail. What's really bad is that this will even fail for 
filesystems that support POSIX ACLs. 

The CITI has patches that try to work around this in libacl by trying both 
POSIX ACLs and "system.nfs4_acl" attributes, and converting between the two 
if necessary. This approach has a number of disadvantages: (1) applications 
that don't use libacl will still fail, (2) always trying both formats without 
knowing the properties of the underlying filesystem will always be slow, (3) 
it exposes a deficiency of NFSv4 instead of trying to hide it.

In addition, I could imagine that we'll optionally support local NFSv4-style 
ACLs on specific file systems somewhen in the future. (Samba would benefit 
greatly from that for example; Solaris already can do that.) Not being able 
to tell the one kind of ACLs from the other in a world where we may have both 
sounds like a recipe for disaster to me.

I could imagine the following solutions to this problem:

* Don't map between POSIX ACLs and NFSv4 ACLs at all, and use a different
  protocol for POSIX ACLs and for NFSv4 ACLs instead (e.g., version 4 of the
  NFSACL protocol extension). The protocol extension is not currently
  implemented in Solaris because current Solaris supports NFSv4 ACLs natively
  instead of POSIX ACLs, and so they don't seem to have as strong a motivation
  to keep POSIX ACLs working well as we currently do. The NFSACL protocol has
  the huge advantage of supporting POSIX ACLs pretty well, and so a lot of the
  overhead and complexity of doing the NFSv4 mapping would go away though.

* Map back from NFSv4 ACLs to POSIX ACLs on the client side, so that
  POSIX ACLs on the server will appear as POSIX ACLs on the client. This
  would take away all the mess we currently have in user-space and limit the
  mapping problems to the NFSv4 protocol, where it really occurs. We could
  define an additional NFsv4 attribute that the server could use to declare
  if it supports POSIX ACLs only, so that the client won't have to try to
  convert from NFSv4 to POSIX ACLs for servers that have native NFSv4 ACLs.

* Go with the user-space solution, and implement the mapping in libacl. This
  solution is ugly, slow, and adds complexity to an unrelated piece of
  software. Some applications will break, and there is no hope that we'll ever
  get rid of this complex hack in the future, for as long as libacl will still
  exist. Yuck!

* Don't support POSIX ACLs over NFSv4 at all.

What do you think?

Thanks,
Andreas


[1] POSIX 1003.1e/2c draft 17, withdrawn, 
http://wt.xpilot.org/publications/posix.1e/download.html

[2] Spencer Shepler et al.: Network File System (NFS) version 4 Protocol, 
section 5.11. Access Control Lists, http://www.ietf.org/rfc/rfc3530.txt

[3] Marius Aamodt Eriksen et al.: Mapping Between NFSv4 and Posix Draft ACLs,
http://www.ietf.org/internet-drafts/draft-ietf-nfsv4-acl-mapping-04.txt

-- 
Andreas Gruenbacher <agruen@suse.de>
Novell / SUSE Labs

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
