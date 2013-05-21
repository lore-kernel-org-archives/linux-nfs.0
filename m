Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:12229 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752116Ab3EUVOV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 May 2013 17:14:21 -0400
Received: from [10.63.225.143] (davros.vpn.netapp.com [10.63.225.143])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id r4LLEJVH006282
	for <linux-nfs@vger.kernel.org>; Tue, 21 May 2013 14:14:20 -0700 (PDT)
Message-ID: <519BE3AB.1020104@netapp.com>
Date: Tue, 21 May 2013 17:14:19 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Announcing nfs-ordeal
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi everybody!

I've pushed out my Jenkins work to git://git.linux-nfs.org/projects/bjschuma/nfs-ordeal.git under the new name "nfs-ordeal".  This git repo includes both the Jenkins xml jobs and various helper scripts that they call to do testing (you'll have to download Jenkins and some plugins on your own - see the install.sh script).  If you just want a tarball, you can find one at www.linux-nfs.org/~bjschuma/nfs-ordeal-v1.0.tar.gz.

Let me know what you think!

~ Bryan
