Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mails1n1-route0.email.arizona.edu ([128.196.130.51]:62963 "EHLO
        mails1n1-route0.email.arizona.edu" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752445AbeGCXlQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jul 2018 19:41:16 -0400
Subject: Re: RDMA connection closed and not re-opened
References: <f1e596cf-0e70-39af-99e9-a0a7e912bad3@genome.arizona.edu>
 <4A72535B-E6D2-4E8A-B6DB-BF09856A41EB@gmail.com>
 <19cd3809-669b-2d63-d453-ed553c9e01a9@genome.arizona.edu>
 <E7AAFE10-FBFE-41E9-9731-D9C50DD2F654@oracle.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: admin@genome.arizona.edu
Message-ID: <57cf42c5-d12d-fff3-fd77-0d191d32111e@genome.arizona.edu>
Date: Tue, 3 Jul 2018 16:41:15 -0700
MIME-Version: 1.0
In-Reply-To: <E7AAFE10-FBFE-41E9-9731-D9C50DD2F654@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote on 07/02/2018 07:44 PM:
> Please review all of my last email. I concluded the likely culprit is a software bug, not server overload.
> If CentOS 6 is required, CentOS / Red Hat really does need to be involved as you troubleshoot. Any code changes will necessitate a new kernel build that only they can provide.

Thanks we will see how it goes with the latest kernel and if there are 
still problems I'll look into filing bug report with CentOS or something.
