Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53041 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751089AbaKKOju (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Nov 2014 09:39:50 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sABEdoPW002468
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 11 Nov 2014 09:39:50 -0500
Received: from sh-el6.eng.rdu2.redhat.com (sh-el6.eng.rdu2.redhat.com [10.10.160.69])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sABEdnQh024351
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 11 Nov 2014 09:39:50 -0500
Date: Tue, 11 Nov 2014 09:39:49 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: mount default minor version behavior
Message-ID: <alpine.LRH.2.11.1411110930190.20279@sh-el6.eng.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I will update mount.nfs so the default version is 4.1.  I have two quick
questions on desired behavior:

  o  Should mounts that do not specify a minor version be upgraded to the 
default minor version?

For example, should 'mount -overs=4' turn into 'mount -overs4.1', if the
current default is 4.1?


  o If 'yes' to the above, should mount auto-retry decrementing minor
versions if EPROTONOSUPPORT?

For example, 'mount -overs=4' with a default of 4.2 would attempt: 4.2,
then 4.1, then 4.0.

Ben
