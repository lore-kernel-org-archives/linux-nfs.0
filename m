From: Chuck Lever <chuck.lever@oracle.com>
Subject: rpcbind doesn't build on Fedora 12 ?
Date: Tue, 5 Jan 2010 12:12:31 -0500
Message-ID: <268D6516-A19A-4CC7-BF03-6FBFA7C79D0B@oracle.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=WINDOWS-1252;
	format=flowed	delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:60338 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754224Ab0AERNK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jan 2010 12:13:10 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

security.c:24:27: error: rpcsvc/rquota.h: No such file or directory
security.c: In function =91check_callit=92:
security.c:286: error: =91RQUOTAPROG=92 undeclared (first use in this =20
function)
security.c:286: error: (Each undeclared identifier is reported only onc=
e
security.c:286: error: for each function it appears in.)

I have libtirpc-devel installed, but a "find" on /usr/include turns up =
=20
no file named rquota.h.  Am I missing some other package?

--=20
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




