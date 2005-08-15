From: Roger Zimmermann <Roger.Zimmermann@arcor.de>
Subject: Is this possible using NFS ?
Date: Mon, 15 Aug 2005 23:13:06 +0200
Message-ID: <1124140386.11051.22.camel@rudi>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E4mGl-0002IJ-Nf
	for nfs@lists.sourceforge.net; Mon, 15 Aug 2005 14:13:19 -0700
Received: from mail-in-02.arcor-online.net ([151.189.21.42])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E4mGk-0002O5-JK
	for nfs@lists.sourceforge.net; Mon, 15 Aug 2005 14:13:19 -0700
Received: from mail-in-03-z2.arcor-online.net (mail-in-03-z2.arcor-online.net [151.189.8.15])
	by mail-in-02.arcor-online.net (Postfix) with ESMTP id 80EE22E511
	for <nfs@lists.sourceforge.net>; Mon, 15 Aug 2005 23:13:09 +0200 (CEST)
Received: from mail-in-07.arcor-online.net (mail-in-07.arcor-online.net [151.189.21.47])
	by mail-in-03-z2.arcor-online.net (Postfix) with ESMTP id 70EAC17D582
	for <nfs@lists.sourceforge.net>; Mon, 15 Aug 2005 23:13:09 +0200 (CEST)
Received: from [192.168.2.191] (dsl-084-059-209-228.arcor-ip.net [84.59.209.228])
	by mail-in-07.arcor-online.net (Postfix) with ESMTP id 1D00234BF6
	for <nfs@lists.sourceforge.net>; Mon, 15 Aug 2005 23:13:09 +0200 (CEST)
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

Hi,

I've got a server, where a varying number of disks is connected.
The layout:

/exampledir/onedisk/sometimes-mounted/etc
/exampledir/onotherdisk/sometimes-mounted/etc
/exampledir/harddisk/always-mounted
/exampledir/otherdata

can I simply export /exampledir from the server
and mount it via NFS by clients without having each client to inform
when e.g 'onedisk' is connected or removed ?

THNX, Roger



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
