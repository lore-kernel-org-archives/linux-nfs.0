Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59636 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754013Ab3ADTM4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2013 14:12:56 -0500
Date: Fri, 4 Jan 2013 14:12:55 -0500
From: Bruce Fields <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Adamson, Dros" <Weston.Adamson@netapp.com>, Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] NFS: Ensure that we free the rpc_task after read and
 write cleanups are done
Message-ID: <20130104191255.GA13828@fieldses.org>
References: <0EC8763B847DB24D9ADF5EBD9CD7B419125A16A9@SACEXCMBX02-PRD.hq.netapp.com>
 <1357323302-12944-1-git-send-email-Trond.Myklebust@netapp.com>
 <1357323302-12944-2-git-send-email-Trond.Myklebust@netapp.com>
 <20130104182958.GA13471@fieldses.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91198C253@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91198C253@SACEXCMBX04-PRD.hq.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 04, 2013 at 06:52:12PM +0000, Myklebust, Trond wrote:
> On Fri, 2013-01-04 at 13:29 -0500, Bruce Fields wrote:
> > On Fri, Jan 04, 2013 at 01:15:01PM -0500, Trond Myklebust wrote:
> > > This patch ensures that we free the rpc_task after the cleanup callbacks
> > > are done in order to avoid a deadlock problem that can be triggered if
> > > the callback needs to wait for another workqueue item to complete.
> > 
> > Makes sense to me!
> > 
> > (Dumb question: so read and write data are the only two cases where the
> > calldata embeds an rpc task?  Why is that?)
> 
> nfs_commit_data and nfs_layoutcommit_data do too. The idea is to improve
> reliability when writing back dirty data in low memory conditions. The
> struct nfs_write_data and nfs_commit_data have their own mempool in
> order to guarantee a minimum number of available slots. By embedding the
> rpc_task, we can extend that guarantee to cover (part of) the RPC call
> too.
> 
> The only reason why nfs_read_data has the same embedding is for symmetry
> with nfs_write_data.

OK, thanks for the explanation.

--b.
