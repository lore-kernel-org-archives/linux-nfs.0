Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:27904 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833Ab3KKQuG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 11:50:06 -0500
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.1/Sentrion-MTA-4.3.1) with ESMTP id rABGo4Tp018545
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 11 Nov 2013 16:50:04 GMT
Received: from userz7021.oracle.com (userz7021.oracle.com [156.151.31.85])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id rABGo36P018217
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 11 Nov 2013 16:50:04 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userz7021.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id rABGo32V021816
	for <linux-nfs@vger.kernel.org>; Mon, 11 Nov 2013 16:50:03 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: NFS atime behavior is not documented
Message-Id: <E4BE40FF-9F81-4688-BD39-1E583DDCEA4A@oracle.com>
Date: Mon, 11 Nov 2013 11:50:01 -0500
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

It was recently pointed out to me that the behavior of atime on NFS mount points is pretty dodgy, yet this is not documented anywhere, not even in the venerable and unmaintained Linux NFS FAQ.

A good place to cover this topic might be nfs(5).  It could discuss how the Linux NFS client deals with the various *atime mount options (mostly be collapsing them into relatime, all the time).  And it could discuss how file timestamps are updated when the physical backing store is on another system.

Thoughts?  Comments?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




