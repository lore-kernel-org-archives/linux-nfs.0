From: Neil Horman <nhorman@redhat.com>
Subject: should NLM locks send notifications after nfsd crash
Date: Thu, 31 Mar 2005 08:13:27 -0500
Message-ID: <20050331131327.GB1328@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DGzUJ-0006JQ-5Q
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 05:13:31 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DGzUH-0005ci-9w
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 05:13:31 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j2VDDSZA014760
	for <nfs@lists.sourceforge.net>; Thu, 31 Mar 2005 08:13:28 -0500
Received: from hmsendeavour.rdu.redhat.com (hmsendeavour.rdu.redhat.com [172.16.57.156])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j2VDDRO19779
	for <nfs@lists.sourceforge.net>; Thu, 31 Mar 2005 08:13:27 -0500
Received: from hmsendeavour.rdu.redhat.com (localhost.localdomain [127.0.0.1])
	by hmsendeavour.rdu.redhat.com (8.13.1/8.13.1) with ESMTP id j2VDDRHf001361
	for <nfs@lists.sourceforge.net>; Thu, 31 Mar 2005 08:13:27 -0500
Received: (from nhorman@localhost)
	by hmsendeavour.rdu.redhat.com (8.13.1/8.13.1/Submit) id j2VDDRJS001360
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 08:13:27 -0500
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
	I can't quite get my head around something.  I've ben asked a question
regarding the behavior of NLM locks, and I'm not sure of what the right behavior
is. If there are NFS clients which have issued monitor requests for various NLM
locks to a server (rpc.statd), and the NFS server (rpc.nfsd) which serves the
files for which the client is monitoring locks on, is stopped and started (some
arbitrary time later), should notifications be sent to the monitoring
clients?  I've been reading the opengourp definition for NLM and NSM, and
section regarding the entrance of grace periods when the "server crashes" is
just unclear to me.

Thanks!
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
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
