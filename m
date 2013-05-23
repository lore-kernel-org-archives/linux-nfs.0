Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759458Ab3EWVxm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 May 2013 17:53:42 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r4NLrgZV009218
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 23 May 2013 17:53:42 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-64.rdu.redhat.com [10.13.145.64])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r4NLrfSQ006709
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 23 May 2013 17:53:42 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id r4NLrfU0020072
	for <linux-nfs@vger.kernel.org>; Thu, 23 May 2013 17:53:41 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id r4NLrfZS020071
	for linux-nfs@vger.kernel.org; Thu, 23 May 2013 17:53:41 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH RFC 0/1] Allow nfs_updatepage to extend a write to cover a full page when we have a lock that covers the entire file 
Date: Thu, 23 May 2013 17:53:40 -0400
Message-Id: <1369346021-20041-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We had a customer experience some performance issues after migrating their
MQseries servers from AIX to Linux.  Their performance benchmark basically puts
50000 messages in a message queue, and a tcpdump captured during these tests
would show a ton of very small writes that were sequential but not contiguous.
After doing some investigation with systemtap we determined that when we called
nfs_updatepage() we were not being allowed to extend the write because the
inode->i_flock was not NULL.  So then later when we'd arrive at
nfs_try_to_update_request() we would always wind up calling nfs_wb_page().

I gave the customer a test kernel using a patch similar to the one that follows
and the test results were favorable, with far fewer writes, the majority of
which were utilizing the full wsize.  For example, the top ten write sizes and
number of occurrences from a tcpdump captured while running the benchmark with
an unpatched kernel:

$ tshark -r before.pcap.gz -R "nfs.opcode==write && nfs.stateid4.hash==0xf09c"
-T fields -e nfs.write.data_length | sort | uniq -c | sort -nr | head
   5852 512
   5575 1024
   2262 1035
   2160 1121
   1661 1023
   1460 1074
   1413 1073
   1394 1152
   1244 1055
    933 1804

contrasted with a tcpdump captured while running the benchmark with the test
kernel:

$ tshark -r after.pcap.gz -R "nfs.opcode==write && nfs.stateid4.hash==0x9f87"
-T fields -e nfs.write.data_length | sort | uniq -c | sort -nr | head
    917 65536
     76 36864
     69 20480
     55 53248
     32 18432
     31 49152
     31 4096
     31 32768
     30 16384
     25 65536,4096

Scott Mayhew (1):
  NFS: Allow nfs_updatepage to extend a write to cover a full page when
    we     have a lock that covers the entire file

 fs/nfs/write.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

-- 
1.7.11.7

