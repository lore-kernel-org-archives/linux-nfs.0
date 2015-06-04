Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36033 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752184AbbFDUlz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 16:41:55 -0400
Date: Thu, 4 Jun 2015 16:41:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 1/2] nfsd: Reset cb_status in nfsd4_cb_prepare() at
 retrying
Message-ID: <20150604204153.GF5209@fieldses.org>
References: <556D8C87.2000507@gmail.com>
 <20150603150311.GA7574@fieldses.org>
 <556F96A1.20301@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <556F96A1.20301@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 04, 2015 at 08:06:57AM +0800, Kinglong Mee wrote:
> On 6/3/2015 11:03 PM, J. Bruce Fields wrote:
> > On Tue, Jun 02, 2015 at 06:59:19PM +0800, Kinglong Mee wrote:
> >> nfsd enters a infinite loop and print message per 10 seconds,
> >>
> >> May 31 18:33:52 test-server kernel: Error sending entire callback!
> >> May 31 18:34:01 test-server kernel: Error sending entire callback!
> >>
> >> It is caused by a cb_layoutreturn got error -10008 (NFS4ERR_DELAY),
> >> and then, the client crash, nfsd enter the infinite loop.
> >>
> >> bc_sendto --> call_timeout --> nfsd4_cb_done --> nfsd4_cb_layout_done
> >>  with error -10008 --> rpc_delay(task, HZ/100) --> bc_sendto ...
> > 
> > How are you reproducing this?
> 
> Yes, 
> 
> I test it by xfstests 074 with nfs client's kdump is on,
> set CONFIG_DEFAULT_HUNG_TASK_TIMEOUT, and client's blkmapd is down.
> 
> 1. nfs client's write operation will get the layout of file, 
>    and then the getdeviceinfo,
> 2. but layout segment is not record by client for blkmapd is down, 
> 3. client write data by sending WRITE to server, 
> 4. nfs server will recall the layout of the file before WRITE,
> 5. network error cause the client reset the session and return NFS4ERR_DELAY,
> 6. so client's WRITE operation is waiting the reply,
>    if the task hang 120s, client will crash.
> 7. so that, the next bc_sendto will fail with TIMEOUT,
>    and cb_status is NFS4ERR_DELAY.

OK, that's complicated.  Sounds like you're giving this code a
workout--thanks.  I'll add the reproducer to the changelog....

--b.

> 
> thanks,
> Kinglong Mee
> 
> > 
> > --b.
> > 
> >>
> >> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> >> ---
> >>  fs/nfsd/nfs4callback.c | 1 +
> >>  1 file changed, 1 insertion(+)
> >>
> >> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> >> index 5694cfb..8b1ac8d 100644
> >> --- a/fs/nfsd/nfs4callback.c
> >> +++ b/fs/nfsd/nfs4callback.c
> >> @@ -875,6 +875,7 @@ static void nfsd4_cb_prepare(struct rpc_task *task, void *calldata)
> >>  	u32 minorversion = clp->cl_minorversion;
> >>  
> >>  	cb->cb_minorversion = minorversion;
> >> +	cb->cb_status = 0;
> >>  	if (minorversion) {
> >>  		if (!nfsd41_cb_get_slot(clp, task))
> >>  			return;
> >> -- 
> >> 2.4.2
> > 
