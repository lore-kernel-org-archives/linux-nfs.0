Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:35848 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754542Ab1FMB1V convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Jun 2011 21:27:21 -0400
Received: by gxk21 with SMTP id 21so2673924gxk.19
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jun 2011 18:27:20 -0700 (PDT)
Date: Mon, 13 Jun 2011 09:27:19 +0800
Message-ID: <BANLkTinHJm4be+gRrCeYdJg_B3ptt+A0qw@mail.gmail.com>
Subject: [Patch 1/1]: fixed a bug that EXCHGID4_FLAG_CONFIRMED_R is cleared in
 EXCHANGE_ID reply if incarnation is a confirmed client
From: Sid Moore <learnmost@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Jun 12, 2011 at 7:59 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Sat, Jun 11, 2011 at 03:54:56PM +0800, Sid Moore wrote:
>> Hi
>>
>> on Linux NFSv4.1 server, nfsd4_exchange_id() is used for creating a
>> new client incarnation or updating a confirmed client incarnation. if
>> try to update a confirmed incarnation, EXCHGID4_FLAG_CONFIRMED_R
>> should be set in eir_flags according to section 18.35.3, RFC5661.
>>
>> but I found EXCHGID4_FLAG_CONFIRMED_R is cleared by "clid->flags =
>> new->cl_exchange_flags;", which is in nfsd4_set_ex_flags() called by
>> nfsd4_exchange_id().
>>
>> so the sematics of RFC5661 is broken? am I correct?
>
> On a quick glance.... I think you're correct.  Patch welcomed.
>
> --b.
>

Hi, Bruce

I think the patch below might be able to fix this issue. I am not sure
what impact would be produced if EXCHGID4_FLAG_CONFIRMED_R directly
set on confirmed clients. So, I take a conservative way. Please review
it. Thanks.

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6fb7283..4bd9281 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1394,6 +1394,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	char			addr_str[INET6_ADDRSTRLEN];
 	nfs4_verifier		verf = exid->verifier;
 	struct sockaddr		*sa = svc_addr(rqstp);
+	int 			confirmed_clnt = 0;

 	rpc_ntop(sa, addr_str, sizeof(addr_str));
 	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
@@ -1455,7 +1456,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 		 * Set bit when the owner id and verifier map to an already
 		 * confirmed client id (18.35.3).
 		 */
-		exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
+		confirmed_clnt = 1;

 		/*
 		 * Falling into 18.35.4 case 2, possible router replay.
@@ -1498,6 +1499,9 @@ out_copy:

 	exid->seqid = 1;
 	nfsd4_set_ex_flags(new, exid);
+	if (confirmed_clnt)
+		exid->flags |= EXCHGID4_FLAG_CONFIRMED_R;
+

 	dprintk("nfsd4_exchange_id seqid %d flags %x\n",
 		new->cl_cs_slot.sl_seqid, new->cl_exchange_flags);

--
Sid
