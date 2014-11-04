Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33168 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754005AbaKDPrE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Nov 2014 10:47:04 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sA4Fl20E025030
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Tue, 4 Nov 2014 10:47:03 -0500
Received: from sh-el6.eng.rdu2.redhat.com (sh-el6.eng.rdu2.redhat.com [10.10.160.69])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id sA4Fl1HD000826
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 4 Nov 2014 10:47:02 -0500
Date: Tue, 4 Nov 2014 10:47:01 -0500 (EST)
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: Client never uses DATA_SYNC
Message-ID: <alpine.LRH.2.11.1411041036320.20279@sh-el6.eng.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have a customer that would like the client to use DATA_SYNC instead of 
FILE_SYNC when writing a file with O_DSYNC.  It looks like the client will 
only use FILE_SYNC since:

87ed5eb44ad9338b1617 NFS: Don't use DATA_SYNC writes
http://marc.info/?l=git-commits-head&m=131180398113265&w=2

I've been unable to dig up any other discussion on this, so I think it
has just been an overlooked point until now.  I'm only starting to
figure out what would need to change for this, and I thought that while
I do that I'd ask the list if anyone thinks that serious implementation
issues might emerge if this were attempted.

Ben
