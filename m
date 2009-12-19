From: Steve Dickson <SteveD@redhat.com>
Subject: 2.6.33 NFS server header reorg breaks existing systemtap scripts.
Date: Sat, 19 Dec 2009 10:47:55 -0500
Message-ID: <4B2CF5AB.9040000@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: SystemTAP <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751860AbZLSPr5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 19 Dec 2009 10:47:57 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nBJFlvCa025986
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Sat, 19 Dec 2009 10:47:57 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

In the upcoming 2.6.33 kernel release the following
NFS server header files have been moved out of the 
'include/linux/nfsd' include directory and into the 
'fs/nfsd' source directory:
     linux/nfsd/nfsd.h
     linux/nfsd/cache.h
     linux/nfsd/xdr.h
     linux/nfsd/xdr3.h
     linux/nfsd/xdr4.h

This reorg will break any and all existing systemtap scripts 
including the nfsd.stp in the current systemtap release. Plus 
it appears the header files that live in source directories 
are not include in the kernel-devel package which seems to 
mean there will be no access to the NFS server code using
systemtap scripts from here on out... which is not good... 

Any suggestions on how to alleviate this problem?

Have header file been moved in to source directories
in the past? If so, how was that dealt with? 

steved.


 
