Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:61119 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639Ab3AGRyG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jan 2013 12:54:06 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Tejun Heo <tj@kernel.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>,
        Bruce Fields <bfields@fieldses.org>
Subject: Re: [PATCH 1/3] SUNRPC: Ensure that we free the rpc_task after
 cleanups are done
Date: Mon, 7 Jan 2013 17:54:03 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA911991561@SACEXCMBX04-PRD.hq.netapp.com>
References: <0EC8763B847DB24D9ADF5EBD9CD7B419125A16A9@SACEXCMBX02-PRD.hq.netapp.com>
	 <1357323302-12944-1-git-send-email-Trond.Myklebust@netapp.com>
	 <20130107174720.GN3926@htj.dyndns.org>
In-Reply-To: <20130107174720.GN3926@htj.dyndns.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-01-07 at 09:47 -0800, Tejun Heo wrote:
+AD4- On Fri, Jan 04, 2013 at 01:15:00PM -0500, Trond Myklebust wrote:
+AD4- +AD4- +- +ACo- Tejun Heo states:
+AD4- +AD4- +- +ACo- +ACI-Workqueue currently considers two work items to be the same if they're
+AD4- +AD4- +- +ACo- on the same address and won't execute them concurrently - ie. it
+AD4- +AD4- +- +ACo- makes a work item which is queued again while being executed wait
+AD4- +AD4- +- +ACo- for the previous execution to complete.
+AD4- +AD4- +- +ACo-
+AD4- +AD4- +- +ACo- If a work function frees the work item, and then waits for an event
+AD4- +AD4- +- +ACo- which should be performed by another work item and +ACo-that+ACo- work item
+AD4- +AD4- +- +ACo- recycles the freed work item, it can create a false dependency loop.
+AD4- +AD4- +- +ACo- There really is no reliable way to detect this short of verifying
+AD4- +AD4- +- +ACo- every memory free.+ACI-
+AD4- 
+AD4- I will document it in Documentation/workqueue.txt.

Thanks Tejun+ACE-

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
