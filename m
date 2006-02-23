From: Neil Horman <nhorman@redhat.com>
Subject: Should fcntl operations check attributes with the server when NFS shares are mounted noac?
Date: Thu, 23 Feb 2006 07:42:55 -0500
Message-ID: <20060223124255.GA29177@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FCFoL-0003U5-Ur
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 04:43:09 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FCFoJ-000347-IC
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 04:43:09 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id k1NCgt1V002867
	for <nfs@lists.sourceforge.net>; Thu, 23 Feb 2006 07:42:55 -0500
Received: from hmsendeavour.rdu.redhat.com (hmsendeavour.rdu.redhat.com [172.16.57.156])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id k1NCgt119403
	for <nfs@lists.sourceforge.net>; Thu, 23 Feb 2006 07:42:55 -0500
Received: from hmsendeavour.rdu.redhat.com (localhost.localdomain [127.0.0.1])
	by hmsendeavour.rdu.redhat.com (8.13.1/8.13.1) with ESMTP id k1NCgtaI031644
	for <nfs@lists.sourceforge.net>; Thu, 23 Feb 2006 07:42:55 -0500
Received: (from nhorman@localhost)
	by hmsendeavour.rdu.redhat.com (8.13.1/8.13.1/Submit) id k1NCgtVs031643
	for nfs@lists.sourceforge.net; Thu, 23 Feb 2006 07:42:55 -0500
To: nfs@lists.sourceforge.net
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

Hey all-
	I've got a dillema and I'm not sure how to anwser it.  I recently had
someone mention to me that some of the operations executed via fcntl
(specifically F_SETLEASE was demonstrated to me) don't check the file attributes
on the server before executing their operations.  This can lead to erroneous
behavior in which, if someone updates file permissions or ownership from another
node mounting an NFS share, a node attempting to do something like a F_SETLEASE
operation will fail when it should succede, or vice versa.

	I can see who this could be interpreted as a bug, but I can also see how
we might not want to change the behavior, given that the fcntl code currently
does not call down to the underlying filesystem for most operations (as it
doesn't nominally need to), and the problem can easily be avoided by the use of
a file lock and a stat operation.  Is there consensus on this issue, as to how
it should operate, or how we would like it to operate?

Thanks & Regards
Neil

-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
