Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21167 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934306AbcJXNwF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2016 09:52:05 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: upstream server crash
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1477315868.2625.37.camel@redhat.com>
Date: Mon, 24 Oct 2016 09:51:58 -0400
Cc: Eryu Guan <guaneryu@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7B3F94BF-CAA1-4001-BEBC-C93965A81DE4@oracle.com>
References: <20161023182115.GA14481@fieldses.org> <20161024031519.GN2462@eguan.usersys.redhat.com> <1477315868.2625.37.camel@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Oct 24, 2016, at 9:31 AM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> On Mon, 2016-10-24 at 11:15 +0800, Eryu Guan wrote:
>> On Sun, Oct 23, 2016 at 02:21:15PM -0400, J. Bruce Fields wrote:
>>> 
>>> I'm getting an intermittent crash in the nfs server as of
>>> 68778945e46f143ed7974b427a8065f69a4ce944 "SUNRPC: Separate buffer
>>> pointers for RPC Call and Reply messages".
>>> 
>>> I haven't tried to understand that commit or why it would be a problem yet, I
>>> don't see an obvious connection--I can take a closer look Monday.
>>> 
>>> Could even be that I just landed on this commit by chance, the problem is a
>>> little hard to reproduce so I don't completely trust my testing.
>> 
>> I've hit the same crash on 4.9-rc1 kernel, and it's reproduced for me
>> reliably by running xfstests generic/013 case, on a loopback mounted
>> NFSv4.1 (or NFSv4.2), XFS is the underlying exported fs. More details
>> please see
>> 
>> http://marc.info/?l=linux-nfs&m=147714320129362&w=2
>> 
> 
> Looks like you landed at the same commit as Bruce, so that's probably
> legit. That commit is very small though. The only real change that
> doesn't affect the new field is this:
> 
> 
> @@ -1766,7 +1766,7 @@ rpc_xdr_encode(struct rpc_task *task)
>                      req->rq_buffer,
>                      req->rq_callsize);
>         xdr_buf_init(&req->rq_rcv_buf,
> -                    (char *)req->rq_buffer + req->rq_callsize,
> +                    req->rq_rbuffer,
>                      req->rq_rcvsize);
> 
> 
> So I'm guessing this is breaking the callback channel somehow?

Could be the TCP backchannel code is using rq_buffer in a different
way than RDMA backchannel or the forward channel code.


--
Chuck Lever



