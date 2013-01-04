Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:46358 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753631Ab3ADSwP convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2013 13:52:15 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Bruce Fields <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] NFS: Ensure that we free the rpc_task after read
 and write cleanups are done
Date: Fri, 4 Jan 2013 18:52:12 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91198C253@SACEXCMBX04-PRD.hq.netapp.com>
References: <0EC8763B847DB24D9ADF5EBD9CD7B419125A16A9@SACEXCMBX02-PRD.hq.netapp.com>
	 <1357323302-12944-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1357323302-12944-2-git-send-email-Trond.Myklebust@netapp.com>
	 <20130104182958.GA13471@fieldses.org>
In-Reply-To: <20130104182958.GA13471@fieldses.org>
Content-Type: text/plain; charset="utf-7"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2013-01-04 at 13:29 -0500, Bruce Fields wrote:
+AD4- On Fri, Jan 04, 2013 at 01:15:01PM -0500, Trond Myklebust wrote:
+AD4- +AD4- This patch ensures that we free the rpc+AF8-task after the cleanup callbacks
+AD4- +AD4- are done in order to avoid a deadlock problem that can be triggered if
+AD4- +AD4- the callback needs to wait for another workqueue item to complete.
+AD4- 
+AD4- Makes sense to me+ACE-
+AD4- 
+AD4- (Dumb question: so read and write data are the only two cases where the
+AD4- calldata embeds an rpc task?  Why is that?)

nfs+AF8-commit+AF8-data and nfs+AF8-layoutcommit+AF8-data do too. The idea is to improve
reliability when writing back dirty data in low memory conditions. The
struct nfs+AF8-write+AF8-data and nfs+AF8-commit+AF8-data have their own mempool in
order to guarantee a minimum number of available slots. By embedding the
rpc+AF8-task, we can extend that guarantee to cover (part of) the RPC call
too.

The only reason why nfs+AF8-read+AF8-data has the same embedding is for symmetry
with nfs+AF8-write+AF8-data.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust+AEA-netapp.com
www.netapp.com
