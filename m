Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:48913 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755799AbbJASiW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Oct 2015 14:38:22 -0400
Date: Thu, 1 Oct 2015 12:38:18 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Devesh Sharma <devesh.sharma@avagotech.com>,
        Sagi Grimberg <sagig@dev.mellanox.co.il>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 03/18] xprtrdma: Remove completion polling budgets
Message-ID: <20151001183818.GA9477@obsidianresearch.com>
References: <A3B1A836-81AF-40E6-B551-587B7173B72D@oracle.com>
 <55FE8C0F.1050706@dev.mellanox.co.il>
 <CANjDDBjcRXsPFt2Bd+9oL2wTBTxpDsAvN5PZN669dhTC7xSyqw@mail.gmail.com>
 <0804C887-9E32-4257-96D2-6C1FBC9CB271@oracle.com>
 <CANjDDBgB_T9BN7ATTWEJcJScs2JH9bGv5zikUpu_2JJaRYS-Ug@mail.gmail.com>
 <A5EE402A-82CE-49DC-8AB9-63EC340CE8DA@oracle.com>
 <20151001171310.GA8428@obsidianresearch.com>
 <CDDBC387-9135-405E-B535-EE89F952386E@oracle.com>
 <20151001181548.GA8670@obsidianresearch.com>
 <E543F197-56F6-43FC-A2FE-4273695405E9@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E543F197-56F6-43FC-A2FE-4273695405E9@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 01, 2015 at 02:31:41PM -0400, Chuck Lever wrote:

> Does a ULP want to continue polling if ib_poll_cq{_and_arm)
> returns a negative RC?

No. We should try and figure out if that can even happen, if not get
rid of the possibility.

If it can happen, it can only mean the CQ is busted, and needs to be
destroyed. Ie the whole ULP probably needs to restart.

Jason
