Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:35811 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932535AbcEQMTq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 May 2016 08:19:46 -0400
Received: by mail-qg0-f67.google.com with SMTP id b14so1124440qge.2
        for <linux-nfs@vger.kernel.org>; Tue, 17 May 2016 05:19:45 -0700 (PDT)
Message-ID: <1463487579.13041.2.camel@poochiereds.net>
Subject: Re: [PATCH v3 12/13] pnfs: rework LAYOUTGET retry handling
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "hch@infradead.org" <hch@infradead.org>
Date: Tue, 17 May 2016 08:19:39 -0400
In-Reply-To: <1463480217.5816.2.camel@poochiereds.net>
References: <1463274402-17746-1-git-send-email-jeff.layton@primarydata.com>
	 <1463274402-17746-13-git-send-email-jeff.layton@primarydata.com>
	 <0C253EE4-3780-4948-97EC-7056E33D35AA@primarydata.com>
	 <1463480217.5816.2.camel@poochiereds.net>
Content-Type: multipart/mixed; boundary="=-WH5ZbdNo77f9jyG503v2"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-WH5ZbdNo77f9jyG503v2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit

On Tue, 2016-05-17 at 06:16 -0400, Jeff Layton wrote:
> On Tue, 2016-05-17 at 02:07 +0000, Trond Myklebust wrote:
> > 
> > 
> > On 5/14/16, 21:06, "Jeff Layton" <jlayton@poochiereds.net> wrote:
> > 
> > > There are several problems in the way a stateid is selected for a
> > > LAYOUTGET operation:
> > > 
> > > We pick a stateid to use in the RPC prepare op, but that makes
> > > it difficult to serialize LAYOUTGETs that use the open stateid. That
> > > serialization is done in pnfs_update_layout, which occurs well before
> > > the rpc_prepare operation.
> > > 
> > > Between those two events, the i_lock is dropped and reacquired.
> > > pnfs_update_layout can find that the list has lsegs in it and not do any
> > > serialization, but then later pnfs_choose_layoutget_stateid ends up
> > > choosing the open stateid.
> > > 
> > > This patch changes the client to select the stateid to use in the
> > > LAYOUTGET earlier, when we're searching for a usable layout segment.
> > > This way we can do it all while holding the i_lock the first time, and
> > > ensure that we serialize any LAYOUTGET call that uses a non-layout
> > > stateid.
> > > 
> > > This also means a rework of how LAYOUTGET replies are handled, as we
> > > must now get the latest stateid if we want to retransmit in response
> > > to a retryable error.
> > > 
> > > Most of those errors boil down to the fact that the layout state has
> > > changed in some fashion. Thus, what we really want to do is to re-search
> > > for a layout when it fails with a retryable error, so that we can avoid
> > > reissuing the RPC at all if possible.
> > > 
> > > While the LAYOUTGET RPC is async, the initiating thread always waits for
> > > it to complete, so it's effectively synchronous anyway. Currently, when
> > > we need to retry a LAYOUTGET because of an error, we drive that retry
> > > via the rpc state machine.
> > > 
> > > This means that once the call has been submitted, it runs until it
> > > completes. So, we must move the error handling for this RPC out of the
> > > rpc_call_done operation and into the caller.
> > > 
> > > In order to handle errors like NFS4ERR_DELAY properly, we must also
> > > pass a pointer to the sliding timeout, which is now moved to the stack
> > > in pnfs_update_layout.
> > > 
> > > The complicating errors are -NFS4ERR_RECALLCONFLICT and
> > > -NFS4ERR_LAYOUTTRYLATER, as those involve a timeout after which we give
> > > up and return NULL back to the caller. So, there is some special
> > > handling for those errors to ensure that the layers driving the retries
> > > can handle that appropriately.
> > > 
> > > Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> > > ---
> > > fs/nfs/nfs4proc.c | 111 +++++++++++++++----------------------
> > > fs/nfs/nfs4trace.h | 10 +++-
> > > fs/nfs/pnfs.c | 142 +++++++++++++++++++++++++-----------------------
> > > fs/nfs/pnfs.h | 6 +-
> > > include/linux/nfs4.h | 2 +
> > > include/linux/nfs_xdr.h | 2 -
> > > 6 files changed, 131 insertions(+), 142 deletions(-)
> > > 
> > > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > > index c0d75be8cb69..1254ed84c760 100644
> > > --- a/fs/nfs/nfs4proc.c
> > > +++ b/fs/nfs/nfs4proc.c
> > > @@ -416,6 +416,7 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
> > > case -NFS4ERR_DELAY:
> > > nfs_inc_server_stats(server, NFSIOS_DELAY);
> > > case -NFS4ERR_GRACE:
> > > +	 case -NFS4ERR_RECALLCONFLICT:
> > > exception->delay = 1;
> > > return 0;
> > >  
> > > @@ -7824,40 +7825,34 @@ nfs4_layoutget_prepare(struct rpc_task *task, void *calldata)
> > > struct nfs4_layoutget *lgp = calldata;
> > > struct nfs_server *server = NFS_SERVER(lgp->args.inode);
> > > struct nfs4_session *session = nfs4_get_session(server);
> > > -	int ret;
> > >  
> > > dprintk("--> %s\n", __func__);
> > > -	/* Note the is a race here, where a CB_LAYOUTRECALL can come in
> > > -	 * right now covering the LAYOUTGET we are about to send.
> > > -	 * However, that is not so catastrophic, and there seems
> > > -	 * to be no way to prevent it completely.
> > > -	 */
> > > -	if (nfs41_setup_sequence(session, &lgp->args.seq_args,
> > > -	 &lgp->res.seq_res, task))
> > > -	 return;
> > > -	ret = pnfs_choose_layoutget_stateid(&lgp->args.stateid,
> > > -	 NFS_I(lgp->args.inode)->layout,
> > > -	 &lgp->args.range,
> > > -	 lgp->args.ctx->state);
> > > -	if (ret < 0)
> > > -	 rpc_exit(task, ret);
> > > +	nfs41_setup_sequence(session, &lgp->args.seq_args,
> > > +	 &lgp->res.seq_res, task);
> > > +	dprintk("<-- %s\n", __func__);
> > > }
> > >  
> > > static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
> > > {
> > > struct nfs4_layoutget *lgp = calldata;
> > > +
> > > +	dprintk("--> %s\n", __func__);
> > > +	nfs41_sequence_done(task, &lgp->res.seq_res);
> > > +	dprintk("<-- %s\n", __func__);
> > > +}
> > > +
> > > +static int
> > > +nfs4_layoutget_handle_exception(struct rpc_task *task,
> > > +	 struct nfs4_layoutget *lgp, struct nfs4_exception *exception)
> > > +{
> > > struct inode *inode = lgp->args.inode;
> > > struct nfs_server *server = NFS_SERVER(inode);
> > > struct pnfs_layout_hdr *lo;
> > > -	struct nfs4_state *state = NULL;
> > > -	unsigned long timeo, now, giveup;
> > > +	int status = task->tk_status;
> > >  
> > > dprintk("--> %s tk_status => %d\n", __func__, -task->tk_status);
> > >  
> > > -	if (!nfs41_sequence_done(task, &lgp->res.seq_res))
> > > -	 goto out;
> > > -
> > > -	switch (task->tk_status) {
> > > +	switch (status) {
> > > case 0:
> > > goto out;
> > >  
> > > @@ -7867,57 +7862,39 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
> > > * retry go inband.
> > > */
> > > case -NFS4ERR_LAYOUTUNAVAILABLE:
> > > -	 task->tk_status = -ENODATA;
> > > +	 status = -ENODATA;
> > > goto out;
> > > /*
> > > * NFS4ERR_BADLAYOUT means the MDS cannot return a layout of
> > > * length lgp->args.minlength != 0 (see RFC5661 section 18.43.3).
> > > */
> > > case -NFS4ERR_BADLAYOUT:
> > > -	 goto out_overflow;
> > > +	 status = -EOVERFLOW;
> > > +	 goto out;
> > > /*
> > > * NFS4ERR_LAYOUTTRYLATER is a conflict with another client
> > > * (or clients) writing to the same RAID stripe except when
> > > * the minlength argument is 0 (see RFC5661 section 18.43.3).
> > > +	 *
> > > +	 * Treat it like we would RECALLCONFLICT -- we retry for a little
> > > +	 * while, and then eventually give up.
> > > */
> > > case -NFS4ERR_LAYOUTTRYLATER:
> > > -	 if (lgp->args.minlength == 0)
> > > -	 goto out_overflow;
> > > -	/*
> > > -	 * NFS4ERR_RECALLCONFLICT is when conflict with self (must recall
> > > -	 * existing layout before getting a new one).
> > > -	 */
> > > -	case -NFS4ERR_RECALLCONFLICT:
> > > -	 timeo = rpc_get_timeout(task->tk_client);
> > > -	 giveup = lgp->args.timestamp + timeo;
> > > -	 now = jiffies;
> > > -	 if (time_after(giveup, now)) {
> > > -	 unsigned long delay;
> > > -
> > > -	 /* Delay for:
> > > -	 * - Not less then NFS4_POLL_RETRY_MIN.
> > > -	 * - One last time a jiffie before we give up
> > > -	 * - exponential backoff (time_now minus start_attempt)
> > > -	 */
> > > -	 delay = max_t(unsigned long, NFS4_POLL_RETRY_MIN,
> > > -	 min((giveup - now - 1),
> > > -	 now - lgp->args.timestamp));
> > > -
> > > -	 dprintk("%s: NFS4ERR_RECALLCONFLICT waiting %lu\n",
> > > -	 __func__, delay);
> > > -	 rpc_delay(task, delay);
> > > -	 /* Do not call nfs4_async_handle_error() */
> > > -	 goto out_restart;
> > > +	 if (lgp->args.minlength == 0) {
> > > +	 status = -EOVERFLOW;
> > > +	 goto out;
> > > }
> > > +	 status = -NFS4ERR_RECALLCONFLICT;
> > > break;
> > > case -NFS4ERR_EXPIRED:
> > > case -NFS4ERR_BAD_STATEID:
> > > +	 exception->timeout = 0;
> > > spin_lock(&inode->i_lock);
> > > if (nfs4_stateid_match(&lgp->args.stateid,
> > > &lgp->args.ctx->state->stateid)) {
> > > spin_unlock(&inode->i_lock);
> > > /* If the open stateid was bad, then recover it. */
> > > -	 state = lgp->args.ctx->state;
> > > +	 exception->state = lgp->args.ctx->state;
> > > break;
> > > }
> > > lo = NFS_I(inode)->layout;
> > > @@ -7935,20 +7912,18 @@ static void nfs4_layoutget_done(struct rpc_task *task, void *calldata)
> > > pnfs_free_lseg_list(&head);
> > > } else
> > > spin_unlock(&inode->i_lock);
> > > -	 goto out_restart;
> > > +	 status = -EAGAIN;
> > > +	 goto out;
> > > }
> > > -	if (nfs4_async_handle_error(task, server, state, &lgp->timeout) == -EAGAIN)
> > > -	 goto out_restart;
> > > +
> > > +	status = nfs4_handle_exception(server, status, exception);
> > > +	if (status == 0)
> > > +	 status = task->tk_status;
> > > +	if (exception->retry && status != -NFS4ERR_RECALLCONFLICT)
> > > +	 status = -EAGAIN;
> > > out:
> > > dprintk("<-- %s\n", __func__);
> > > -	return;
> > > -out_restart:
> > > -	task->tk_status = 0;
> > > -	rpc_restart_call_prepare(task);
> > > -	return;
> > > -out_overflow:
> > > -	task->tk_status = -EOVERFLOW;
> > > -	goto out;
> > > +	return status;
> > > }
> > >  
> > > static size_t max_response_pages(struct nfs_server *server)
> > > @@ -8017,7 +7992,7 @@ static const struct rpc_call_ops nfs4_layoutget_call_ops = {
> > > };
> > >  
> > > struct pnfs_layout_segment *
> > > -nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
> > > +nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout, gfp_t gfp_flags)
> > > {
> > > struct inode *inode = lgp->args.inode;
> > > struct nfs_server *server = NFS_SERVER(inode);
> > > @@ -8037,6 +8012,7 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
> > > .flags = RPC_TASK_ASYNC,
> > > };
> > > struct pnfs_layout_segment *lseg = NULL;
> > > +	struct nfs4_exception exception = { .timeout = *timeout };
> > > int status = 0;
> > >  
> > > dprintk("--> %s\n", __func__);
> > > @@ -8050,7 +8026,6 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
> > > return ERR_PTR(-ENOMEM);
> > > }
> > > lgp->args.layout.pglen = max_pages * PAGE_SIZE;
> > > -	lgp->args.timestamp = jiffies;
> > >  
> > > lgp->res.layoutp = &lgp->args.layout;
> > > lgp->res.seq_res.sr_slot = NULL;
> > > @@ -8060,13 +8035,17 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, gfp_t gfp_flags)
> > > if (IS_ERR(task))
> > > return ERR_CAST(task);
> > > status = nfs4_wait_for_completion_rpc_task(task);
> > > -	if (status == 0)
> > > -	 status = task->tk_status;
> > > +	if (status == 0) {
> > > +	 status = nfs4_layoutget_handle_exception(task, lgp, &exception);
> > 
> > This is borked… You’re now returning an NFSv4 status as an ERR_PTR(), which is a big no-no!
> > MAX_ERRNO is 4095, while NFS4ERR_RECALLCONFLICT takes the value 10061.
> > 
> 
> Ahh good catch!
> 
> Ok, I think the right fix there is probably to just declare the
> nfs4_exception in pnfs_update_layout, and then just pass a pointer to
> it down to this function. Then it can do the interpretation of the result at the point where we decide to retry.
> 
> I'll respin...
> 
> Thanks,
> Jeff
> 

Ok, incremental patch on top of the series is attached. I ended up not
dealing with the exception at higher layers, but rather just declaring
a new "ERECALLCONFLICT" error code and using that to indicate the
special behavior that those errors require. I'll plan to fold this into
the patch that broke this before I resend.

-- 
Jeff Layton <jlayton@poochiereds.net>

--=-WH5ZbdNo77f9jyG503v2
Content-Disposition: attachment; filename="0001-pnfs-rework-LAYOUTGET-error-handling.patch"
Content-Type: text/x-patch; name="0001-pnfs-rework-LAYOUTGET-error-handling.patch";
	charset="UTF-8"
Content-Transfer-Encoding: base64

RnJvbSBmZDJjYmRlYWJhMWZiYzU2ZGJkMzk0YzBiMjMyMzk5ZDI1NmYxNTRlIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKZWZmIExheXRvbiA8amVmZi5sYXl0b25AcHJpbWFyeWRhdGEu
Y29tPgpEYXRlOiBUdWUsIDE3IE1heSAyMDE2IDA3OjA1OjIxIC0wNDAwClN1YmplY3Q6IFtQQVRD
SF0gcG5mczogcmV3b3JrIExBWU9VVEdFVCBlcnJvciBoYW5kbGluZwoKSVNfRVJSIGNhbid0IGhh
bmRsZSBlcnJvcnMgaW4gdGhlIHJhbmdlIG9mIC1ORlM0RVJSXyogZXJyb3IgY29kZXMuCgpTaWdu
ZWQtb2ZmLWJ5OiBKZWZmIExheXRvbiA8amVmZi5sYXl0b25AcHJpbWFyeWRhdGEuY29tPgotLS0K
IGZzL25mcy9uZnM0cHJvYy5jICAgICB8IDEyICsrKysrKystLS0tLQogZnMvbmZzL3BuZnMuYyAg
ICAgICAgIHwgIDQgKystLQogaW5jbHVkZS9saW51eC9lcnJuby5oIHwgIDEgKwogMyBmaWxlcyBj
aGFuZ2VkLCAxMCBpbnNlcnRpb25zKCspLCA3IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2Zz
L25mcy9uZnM0cHJvYy5jIGIvZnMvbmZzL25mczRwcm9jLmMKaW5kZXggMTI1NGVkODRjNzYwLi5j
MjU4M2NhNmM4YjYgMTAwNjQ0Ci0tLSBhL2ZzL25mcy9uZnM0cHJvYy5jCisrKyBiL2ZzL25mcy9u
ZnM0cHJvYy5jCkBAIC03ODg0LDggKzc4ODQsMTIgQEAgbmZzNF9sYXlvdXRnZXRfaGFuZGxlX2V4
Y2VwdGlvbihzdHJ1Y3QgcnBjX3Rhc2sgKnRhc2ssCiAJCQlzdGF0dXMgPSAtRU9WRVJGTE9XOwog
CQkJZ290byBvdXQ7CiAJCX0KLQkJc3RhdHVzID0gLU5GUzRFUlJfUkVDQUxMQ09ORkxJQ1Q7Ci0J
CWJyZWFrOworCQkvKiBGYWxsdGhyb3VnaCAqLworCWNhc2UgLU5GUzRFUlJfUkVDQUxMQ09ORkxJ
Q1Q6CisJCW5mczRfaGFuZGxlX2V4Y2VwdGlvbihzZXJ2ZXIsIC1ORlM0RVJSX1JFQ0FMTENPTkZM
SUNULAorCQkJCQlleGNlcHRpb24pOworCQlzdGF0dXMgPSAtRVJFQ0FMTENPTkZMSUNUOworCQln
b3RvIG91dDsKIAljYXNlIC1ORlM0RVJSX0VYUElSRUQ6CiAJY2FzZSAtTkZTNEVSUl9CQURfU1RB
VEVJRDoKIAkJZXhjZXB0aW9uLT50aW1lb3V0ID0gMDsKQEAgLTc5MTcsOSArNzkyMSw3IEBAIG5m
czRfbGF5b3V0Z2V0X2hhbmRsZV9leGNlcHRpb24oc3RydWN0IHJwY190YXNrICp0YXNrLAogCX0K
IAogCXN0YXR1cyA9IG5mczRfaGFuZGxlX2V4Y2VwdGlvbihzZXJ2ZXIsIHN0YXR1cywgZXhjZXB0
aW9uKTsKLQlpZiAoc3RhdHVzID09IDApCi0JCXN0YXR1cyA9IHRhc2stPnRrX3N0YXR1czsKLQlp
ZiAoZXhjZXB0aW9uLT5yZXRyeSAmJiBzdGF0dXMgIT0gLU5GUzRFUlJfUkVDQUxMQ09ORkxJQ1Qp
CisJaWYgKGV4Y2VwdGlvbi0+cmV0cnkpCiAJCXN0YXR1cyA9IC1FQUdBSU47CiBvdXQ6CiAJZHBy
aW50aygiPC0tICVzXG4iLCBfX2Z1bmNfXyk7CmRpZmYgLS1naXQgYS9mcy9uZnMvcG5mcy5jIGIv
ZnMvbmZzL3BuZnMuYwppbmRleCAxM2UxYjU3YjIyYmYuLmRlYjYwOWM5Y2Q4YSAxMDA2NDQKLS0t
IGEvZnMvbmZzL3BuZnMuYworKysgYi9mcy9uZnMvcG5mcy5jCkBAIC0xNjMzLDkgKzE2MzMsOSBA
QCBsb29rdXBfYWdhaW46CiAJbHNlZyA9IHNlbmRfbGF5b3V0Z2V0KGxvLCBjdHgsICZzdGF0ZWlk
LCAmYXJnLCAmdGltZW91dCwgZ2ZwX2ZsYWdzKTsKIAl0cmFjZV9wbmZzX3VwZGF0ZV9sYXlvdXQo
aW5vLCBwb3MsIGNvdW50LCBpb21vZGUsIGxvLCBsc2VnLAogCQkJCSBQTkZTX1VQREFURV9MQVlP
VVRfU0VORF9MQVlPVVRHRVQpOwotCWlmIChJU19FUlJfT1JfTlVMTChsc2VnKSkgeworCWlmIChJ
U19FUlIobHNlZykpIHsKIAkJc3dpdGNoKFBUUl9FUlIobHNlZykpIHsKLQkJY2FzZSAtTkZTNEVS
Ul9SRUNBTExDT05GTElDVDoKKwkJY2FzZSAtRVJFQ0FMTENPTkZMSUNUOgogCQkJaWYgKHRpbWVf
YWZ0ZXIoamlmZmllcywgZ2l2ZXVwKSkKIAkJCQlsc2VnID0gTlVMTDsKIAkJCS8qIEZhbGx0aHJv
dWdoICovCmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L2Vycm5vLmggYi9pbmNsdWRlL2xpbnV4
L2Vycm5vLmgKaW5kZXggODk2MjdiOTE4N2Y5Li43Y2U5ZmIxYjdkMjggMTAwNjQ0Ci0tLSBhL2lu
Y2x1ZGUvbGludXgvZXJybm8uaAorKysgYi9pbmNsdWRlL2xpbnV4L2Vycm5vLmgKQEAgLTI4LDUg
KzI4LDYgQEAKICNkZWZpbmUgRUJBRFRZUEUJNTI3CS8qIFR5cGUgbm90IHN1cHBvcnRlZCBieSBz
ZXJ2ZXIgKi8KICNkZWZpbmUgRUpVS0VCT1gJNTI4CS8qIFJlcXVlc3QgaW5pdGlhdGVkLCBidXQg
d2lsbCBub3QgY29tcGxldGUgYmVmb3JlIHRpbWVvdXQgKi8KICNkZWZpbmUgRUlPQ0JRVUVVRUQJ
NTI5CS8qIGlvY2IgcXVldWVkLCB3aWxsIGdldCBjb21wbGV0aW9uIGV2ZW50ICovCisjZGVmaW5l
IEVSRUNBTExDT05GTElDVAk1MzAJLyogY29uZmxpY3Qgd2l0aCByZWNhbGxlZCBzdGF0ZSAqLwog
CiAjZW5kaWYKLS0gCjIuNS41Cgo=


--=-WH5ZbdNo77f9jyG503v2--

