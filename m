Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:56972 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751869AbdK0WMu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 27 Nov 2017 17:12:50 -0500
Date: Mon, 27 Nov 2017 17:12:50 -0500
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PULL REQUEST] nfsd changes for 4.15
Message-ID: <20171127221250.GA28092@fieldses.org>
References: <20171118184020.GA22603@fieldses.org>
 <CA+55aFwPHpD0Ehq8_VawfLCTXgMkbWE3fvdNc__ELmirh1rPVQ@mail.gmail.com>
 <F9DD33F8-7362-4867-9073-356737866073@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F9DD33F8-7362-4867-9073-356737866073@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 19, 2017 at 12:03:45PM -0500, Chuck Lever wrote:
> 
> > On Nov 18, 2017, at 2:40 PM, Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > 
> > On Sat, Nov 18, 2017 at 10:40 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> Please pull nfsd changes for 4.15 from:
> > 
> > Hmm. This had a tracepoint conflict with the nfs client pull.
> 
> Guessing you mean:
> 
> commit a30ccf1a9eb8c01f37675758f6359a968193d96e
> Author:     Chuck Lever <chuck.lever@oracle.com>
> AuthorDate: Fri Oct 20 10:35:18 2017 -0400
> Commit:     Anna Schumaker <Anna.Schumaker@Netapp.com>
> CommitDate: Fri Nov 17 16:43:44 2017 -0500
> 
>     SUNRPC: Fix parsing failure in trace points with XIDs
>     
>     mount.nf-11159   8....   905.248380: xprt_transmit:        [FAILED TO PARSE] xid=351291440 status=0 addr=192.168.2.5 port=20049
>     mount.nf-11159   8....   905.248381: rpc_task_sleep:       task:6210@1 flags=0e80 state=0005 status=0 timeout=60000 queue=xprt_pending
>     kworker/-1591    1....   905.248419: xprt_lookup_rqst:     [FAILED TO PARSE] xid=351291440 status=0 addr=192.168.2.5 port=20049
>     kworker/-1591    1....   905.248423: xprt_complete_rqst:   [FAILED TO PARSE] xid=351291440 status=24 addr=192.168.2.5 port=20049
>     
>     Byte swapping is not available during trace-cmd report.
>     
>     Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>     Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> conflicted with
> 
> commit e9d4bf219c83d09579bc62512fea2ca10f025d93
> Author:     Trond Myklebust <trond.myklebust@primarydata.com>
> AuthorDate: Tue Oct 10 17:31:42 2017 -0400
> Commit:     J. Bruce Fields <bfields@redhat.com>
> CommitDate: Wed Oct 11 17:08:52 2017 -0400
> 
>     SUNRPC: Fix tracepoint storage issues with svc_recv and svc_rqst_status
>     
>     There is no guarantee that either the request or the svc_xprt exist
>     by the time we get round to printing the trace message.
>     
>     Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
>     Cc: stable@vger.kernel.org
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> and that you adjusted a30ccf1a9eb8c01f37675758f6359a968193d96e
> to eliminate the merge conflict.
> 
> At a glance I don't see a problem with the finished result.
> 
> I could have separated a30ccf1a9eb8c01f37675758f6359a968193d96e
> into a server-side and client-side change.

Thanks, Chuck!

I just noticed I made a separate mistake this time around.  For some
reason my pull request only included about the first half of the commits
I had queued up in linux-next.

I have some lame excuse having to do with holiday travel.

Anyway the remainder was just another 20-some bug fixes of various
levels of importance, so I think I'll just send another request for -rc2
tomorrow....

--b.
