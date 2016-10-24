Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:35762 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751492AbcJXTRj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Oct 2016 15:17:39 -0400
Received: by mail-qk0-f176.google.com with SMTP id z190so245611500qkc.2
        for <linux-nfs@vger.kernel.org>; Mon, 24 Oct 2016 12:17:38 -0700 (PDT)
Message-ID: <1477336654.21854.9.camel@redhat.com>
Subject: Re: upstream server crash
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, Eryu Guan <guaneryu@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Mon, 24 Oct 2016 15:17:34 -0400
In-Reply-To: <20161024180858.GA27359@fieldses.org>
References: <20161023182115.GA14481@fieldses.org>
         <20161024031519.GN2462@eguan.usersys.redhat.com>
         <1477315868.2625.37.camel@redhat.com>
         <7B3F94BF-CAA1-4001-BEBC-C93965A81DE4@oracle.com>
         <1477322377.14828.4.camel@redhat.com> <1477322680.14828.6.camel@redhat.com>
         <20161024180858.GA27359@fieldses.org>
Content-Type: multipart/mixed; boundary="=-Kon5Xi8JP9Fx10PBAUeV"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-Kon5Xi8JP9Fx10PBAUeV
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Mon, 2016-10-24 at 14:08 -0400, J. Bruce Fields wrote:
> On Mon, Oct 24, 2016 at 11:24:40AM -0400, Jeff Layton wrote:
> > 
> > On Mon, 2016-10-24 at 11:19 -0400, Jeff Layton wrote:
> > > 
> > > On Mon, 2016-10-24 at 09:51 -0400, Chuck Lever wrote:
> > > > 
> > > > 
> > > > > 
> > > > > 
> > > > > 
> > > > > On Oct 24, 2016, at 9:31 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > > > > 
> > > > > On Mon, 2016-10-24 at 11:15 +0800, Eryu Guan wrote:
> > > > > > 
> > > > > > 
> > > > > > 
> > > > > > On Sun, Oct 23, 2016 at 02:21:15PM -0400, J. Bruce Fields wrote:
> > > > > > > 
> > > > > > > 
> > > > > > > 
> > > > > > > 
> > > > > > > I'm getting an intermittent crash in the nfs server as of
> > > > > > > 68778945e46f143ed7974b427a8065f69a4ce944 "SUNRPC: Separate buffer
> > > > > > > pointers for RPC Call and Reply messages".
> > > > > > > 
> > > > > > > I haven't tried to understand that commit or why it would be a problem yet, I
> > > > > > > don't see an obvious connection--I can take a closer look Monday.
> > > > > > > 
> > > > > > > Could even be that I just landed on this commit by chance, the problem is a
> > > > > > > little hard to reproduce so I don't completely trust my testing.
> > > > > > 
> > > > > > I've hit the same crash on 4.9-rc1 kernel, and it's reproduced for me
> > > > > > reliably by running xfstests generic/013 case, on a loopback mounted
> > > > > > NFSv4.1 (or NFSv4.2), XFS is the underlying exported fs. More details
> > > > > > please see
> > > > > > 
> > > > > > http://marc.info/?l=linux-nfs&m=147714320129362&w=2
> > > > > > 
> > > > > 
> > > > > Looks like you landed at the same commit as Bruce, so that's probably
> > > > > legit. That commit is very small though. The only real change that
> > > > > doesn't affect the new field is this:
> > > > > 
> > > > > 
> > > > > @@ -1766,7 +1766,7 @@ rpc_xdr_encode(struct rpc_task *task)
> > > > >                      req->rq_buffer,
> > > > >                      req->rq_callsize);
> > > > >         xdr_buf_init(&req->rq_rcv_buf,
> > > > > -                    (char *)req->rq_buffer + req->rq_callsize,
> > > > > +                    req->rq_rbuffer,
> > > > >                      req->rq_rcvsize);
> > > > > 
> > > > > 
> > > > > So I'm guessing this is breaking the callback channel somehow?
> > > > 
> > > > Could be the TCP backchannel code is using rq_buffer in a different
> > > > way than RDMA backchannel or the forward channel code.
> > > > 
> > > 
> > > Well, it basically allocates a page per rpc_rqst and then maps that.
> > > 
> > > One thing I notice is that this patch ensures that rq_rbuffer gets set
> > > up in rpc_malloc and xprt_rdma_allocate, but it looks like
> > > xprt_alloc_bc_req didn't get the same treatment.
> > > 
> > > I suspect that that may be the problem...
> > > 
> > In fact, maybe we just need this here? (untested and probably
> > whitespace damaged):
> 
> No change in results for me.
> 
> --b.
> > 
> > 
> > diff --git a/net/sunrpc/backchannel_rqst.c b/net/sunrpc/backchannel_rqst.c
> > index ac701c28f44f..c561aa8ce05b 100644
> > --- a/net/sunrpc/backchannel_rqst.c
> > +++ b/net/sunrpc/backchannel_rqst.c
> > @@ -100,6 +100,7 @@ struct rpc_rqst *xprt_alloc_bc_req(struct rpc_xprt *xprt, gfp_t gfp_flags)
> >                 goto out_free;
> >         }
> >         req->rq_rcv_buf.len = PAGE_SIZE;
> > +       req->rq_rbuffer = req->rq_rcv_buf.head[0].iov_base;
> >  
> >         /* Preallocate one XDR send buffer */
> >         if (xprt_alloc_xdr_buf(&req->rq_snd_buf, gfp_flags) < 0) {

Ahh ok, I think I see.

We probably also need to set rq_rbuffer in bc_malloc and and
xprt_rdma_bc_allocate.

My guess is that we're ending up in rpc_xdr_encode with a NULL
rq_rbuffer pointer, so the right fix would seem to be to ensure that it
is properly set whenever rq_buffer is set.

So I think this may be what we want, actually. I'll plan to test it out
but may not get to it before tomorrow.

-- 
Jeff Layton <jlayton@redhat.com>
--=-Kon5Xi8JP9Fx10PBAUeV
Content-Disposition: attachment;
	filename="0001-sunrpc-fix-some-missing-rq_rbuffer-assignments.patch"
Content-Type: text/x-patch;
	name="0001-sunrpc-fix-some-missing-rq_rbuffer-assignments.patch";
	charset="UTF-8"
Content-Transfer-Encoding: base64

RnJvbSBlZjJhMzkxYmM0ZDhmNmI3MjlhYWNlZTdjZGU4ZDliYWY4Njc2N2MzIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKZWZmIExheXRvbiA8amxheXRvbkByZWRoYXQuY29tPgpEYXRl
OiBNb24sIDI0IE9jdCAyMDE2IDE1OjEzOjQwIC0wNDAwClN1YmplY3Q6IFtQQVRDSF0gc3VucnBj
OiBmaXggc29tZSBtaXNzaW5nIHJxX3JidWZmZXIgYXNzaWdubWVudHMKCkkgdGhpbmsgd2UgYmFz
aWNhbGx5IG5lZWQgdG8gc2V0IHJxX3JidWZmZXIgd2hlbmV2ZXIgcnFfYnVmZmVyIGlzIHNldC4K
ClNpZ25lZC1vZmYtYnk6IEplZmYgTGF5dG9uIDxqbGF5dG9uQHJlZGhhdC5jb20+Ci0tLQogbmV0
L3N1bnJwYy94cHJ0cmRtYS9zdmNfcmRtYV9iYWNrY2hhbm5lbC5jIHwgMSArCiBuZXQvc3VucnBj
L3hwcnRzb2NrLmMgICAgICAgICAgICAgICAgICAgICAgfCAxICsKIDIgZmlsZXMgY2hhbmdlZCwg
MiBpbnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEvbmV0L3N1bnJwYy94cHJ0cmRtYS9zdmNfcmRt
YV9iYWNrY2hhbm5lbC5jIGIvbmV0L3N1bnJwYy94cHJ0cmRtYS9zdmNfcmRtYV9iYWNrY2hhbm5l
bC5jCmluZGV4IDJkODU0NWMzNDA5NS4uZmM0NTM1ZWFkN2MyIDEwMDY0NAotLS0gYS9uZXQvc3Vu
cnBjL3hwcnRyZG1hL3N2Y19yZG1hX2JhY2tjaGFubmVsLmMKKysrIGIvbmV0L3N1bnJwYy94cHJ0
cmRtYS9zdmNfcmRtYV9iYWNrY2hhbm5lbC5jCkBAIC0xODIsNiArMTgyLDcgQEAgeHBydF9yZG1h
X2JjX2FsbG9jYXRlKHN0cnVjdCBycGNfdGFzayAqdGFzaykKIAkJcmV0dXJuIC1FTk9NRU07CiAK
IAlycXN0LT5ycV9idWZmZXIgPSBwYWdlX2FkZHJlc3MocGFnZSk7CisJcnFzdC0+cnFfcmJ1ZmZl
ciA9IChjaGFyICopcnFzdC0+cnFfYnVmZmVyICsgcnFzdC0+cnFfY2FsbHNpemU7CiAJcmV0dXJu
IDA7CiB9CiAKZGlmZiAtLWdpdCBhL25ldC9zdW5ycGMveHBydHNvY2suYyBiL25ldC9zdW5ycGMv
eHBydHNvY2suYwppbmRleCAwMTM3YWYxYzA5MTYuLmUwMWM4MjViYzY4MyAxMDA2NDQKLS0tIGEv
bmV0L3N1bnJwYy94cHJ0c29jay5jCisrKyBiL25ldC9zdW5ycGMveHBydHNvY2suYwpAQCAtMjU2
Myw2ICsyNTYzLDcgQEAgc3RhdGljIGludCBiY19tYWxsb2Moc3RydWN0IHJwY190YXNrICp0YXNr
KQogCWJ1Zi0+bGVuID0gUEFHRV9TSVpFOwogCiAJcnFzdC0+cnFfYnVmZmVyID0gYnVmLT5kYXRh
OworCXJxc3QtPnJxX3JidWZmZXIgPSAoY2hhciAqKXJxc3QtPnJxX2J1ZmZlciArIHJxc3QtPnJx
X2NhbGxzaXplOwogCXJldHVybiAwOwogfQogCi0tIAoyLjcuNAoK


--=-Kon5Xi8JP9Fx10PBAUeV--

