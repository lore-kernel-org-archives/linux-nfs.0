Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:19431 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbbABVRB convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Jan 2015 16:17:01 -0500
Received: from acsinet21.oracle.com (acsinet21.oracle.com [141.146.126.237])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t02LH03R022197
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 2 Jan 2015 21:17:01 GMT
Received: from userz7021.oracle.com (userz7021.oracle.com [156.151.31.85])
	by acsinet21.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id t02LGx59016058
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Fri, 2 Jan 2015 21:17:00 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by userz7021.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id t02LGxTQ017084
	for <linux-nfs@vger.kernel.org>; Fri, 2 Jan 2015 21:16:59 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=windows-1252
Subject: Upstream nfs-utils not building on EL6 again
Message-Id: <E046B731-3611-4E1D-8C88-42134819B123@oracle.com>
Date: Fri, 2 Jan 2015 16:16:55 -0500
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

checking pkg-config is at least version 0.9.0... yes
checking for TIRPC... no
configure: error: libtirpc not found.
make: *** No rule to make target `all'.  Stop.
[cel@manet nfs-utils]$ sudo yum install libtirpc-devel
Loaded plugins: security
Setting up Install Process
Package libtirpc-devel-0.2.1-10.el6.x86_64 already installed and latest version
Nothing to do
[cel@manet nfs-utils]$ 

After the following patch is reverted, the build is successful:

commit 853406302d7a506605ce64592e77fd722b5e23d5
Author:     Yann E. MORIN <yann.morin.1998@free.fr>
Date: Sat Dec 13 10:16:38 2014 -0500

    configure: use pkg-config to find libtirpc

Perhaps the new "[libtirpc >= 0.2.4]” check is too aggressive.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



