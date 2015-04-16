Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37813 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753001AbbDPOFb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Apr 2015 10:05:31 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id t3GE5VLf020280
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Thu, 16 Apr 2015 10:05:31 -0400
Received: from localhost.localdomain (vpn1-4-174.ams2.redhat.com [10.36.4.174])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id t3GE5O9f013095
	for <linux-nfs@vger.kernel.org>; Thu, 16 Apr 2015 10:05:30 -0400
Message-ID: <552FC1A3.50509@redhat.com>
Date: Thu, 16 Apr 2015 15:05:23 +0100
From: Steven Whitehouse <swhiteho@redhat.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: NFS 6.7 blocker bugs
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

This is a list of blocker bugs for 6.7. Please check that they are 
really blockers - if so they'll need to be fixed as soon as possible, if 
not then they should be moved to the next release at this stage. Ignore 
the GFS2 one, I've already sorted that one out, all the rest are NFS 
related though:

https://bugzilla.redhat.com/buglist.cgi?quicksearch=1206720%201121451%201207483%201168138%201182830%201010631%201063088%201208339&list_id=3403675


Steve.

