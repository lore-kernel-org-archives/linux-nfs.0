From: Steve Dickson <SteveD@redhat.com>
Subject: RFC: Is SM_SIMU_CRASH (in rpc.statd) needed?
Date: Tue, 22 Jun 2010 06:03:53 -0400
Message-ID: <4C208A89.4010301@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38876 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755259Ab0FVKDy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jun 2010 06:03:54 -0400
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o5MA3sjk020907
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 22 Jun 2010 06:03:54 -0400
Received: from badhat.bos.devel.redhat.com (vpn-225-247.phx2.redhat.com [10.3.225.247])
	by int-mx01.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o5MA3rBE017950
	for <linux-nfs@vger.kernel.org>; Tue, 22 Jun 2010 06:03:53 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

Does anybody know who uses SM_SIMU_CRASH and is it
still needed? I'm getting some push back from our
security folks to plug this DoS hole up...

steved.
 
