Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49737 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752144AbcFTTKX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 15:10:23 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v3 00/25] NFS/RDMA client patches proposed for v4.8
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <030501d1cb25$19b759d0$4d260d70$@opengridcomputing.com>
Date: Mon, 20 Jun 2016 15:07:52 -0400
Cc: linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <9381D020-519F-4204-9708-107668E8A395@oracle.com>
References: <20160620155751.10809.22262.stgit@manet.1015granger.net> <030501d1cb25$19b759d0$4d260d70$@opengridcomputing.com>
To: Steve Wise <swise@opengridcomputing.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Jun 20, 2016, at 2:53 PM, Steve Wise <swise@opengridcomputing.com> wrote:
> 
>> Available in the "nfs-rdma-for-4.8" topic branch of this git repo:
>> 
>> git://git.linux-nfs.org/projects/cel/cel-2.6.git
>> 
>> Or for browsing:
>> 
>> http://git.linux-nfs.org/?p=cel/cel-2.6.git;a=log;h=refs/heads/nfs-rdma-for-4.8
> 
> Hey Chuck, I ran a quick regression of this code over iw_cxgb4.  Everything looks ok.
> 
> Tested-by: Steve Wise <swise@opengridcomputing.com>

Thanks, I'll add that for the next round.


--
Chuck Lever



