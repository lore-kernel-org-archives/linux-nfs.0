Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793019951;
	b=NIESc2M2S41Q+SYdeelxnZyKVWAsOaK+wN028Rt7Jik38xChGD7vjASnz6JeKWkHK7GI
	 /NwWJmx0c72RSypzPC6iWkL1U1ciQ7fwnp0K0Fcq+jVl0/UbsLU8SNLsh4wOTKq4A7Fjl
	 X821P6wclgyZ2CKXwzHe1nVJKIxjeUxEG8z03bqGnvDBhaRgYAx3xj4+TcjHbFJjjTG1v
	 fky4FEs3KC0xhq65M49CTLO56QdwevZh/mdWAeoZK58qFEaQ5rSh89FH8+akATi4Xy2Er
	 /cnGTqxEx9B9yspoDkYwqbx6ucvcPHD64wUy/JZlTOZCaqgmcs9wVBfm6Oq8I0LTR4A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793019951;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=7bIXycg1930DGsJkQQqAMUTlMI+4pLpviwqhOKTpG2s=;
	b=SIYe/2X3x6dD3ugpYlgi1qi+rJb7fa1qK1kQnt9zQgHXkGGnc/YYPFtV8RihUyjJH5F8
	 rbXndlBi47fVvYCKf14BuH+SQLAvK74KsYCIKQuh0RLpCQ61hbTr6YifFKw4VMhhOiGRF
	 k97mKS9xeVDgroy+atX7ebSgXGteVcuqTHLIl3TZLpwJuzGPd2CsBN9/V2QFdwud0Rwz3
	 stGTWVsB7Iwz2j07ppRL7vhyrmTeA24DLx9M90ewr6sF2Ej4SyeC2cq4s0l/Rb50KhInv
	 8Qth608I5pIaaBP2Orh4D10UxmD54GHGWMGYeFYx2YISZRQmBnNJ8FQNVf+OBXZ55LA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dETIsSYU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C9A0606A31A
	for <linux-nfs@vger.kernel.org>; Mon, 26 Oct 2026 13:05:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dETIsSYU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 27F261F01825;
	Mon, 26 Oct 2026 13:05:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793019951;
	bh=7bIXycg1930DGsJkQQqAMUTlMI+4pLpviwqhOKTpG2s=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=dETIsSYUtGOz1njPdVVOkJbKmjp84JQWASDQ+Tclh/INWQ07JLB+tLggN7pgA8qpO
	 nySWhIu4iDV0yAvBhXVNu52cv2E9u77tCI+fsxlEujk7dmUaMRrm1lklter8nSDyJf
	 1qSz8pvEZI70nLF4DaHIc7J011GwHFJEdpcgSfJgBqGFstPWWB1Vbq6nEzfPeBHF9F
	 tTdMR2sG4NT9yZKxlbyL88V/nm9RjHBftQ05ROQY82aEA9w71izM+eVECEaaeCkTHP
	 OFgg+Cgq/FGwsFdJSEBH6+MRKDFndN+O5qT85eBMZJTZVMq4/EJdkIwVnUIRKOvIWc
	 KzFb7db/C6a6g==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 86C51F40069;
	Mon, 26 Oct 2026 09:05:50 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 26 Oct 2026 09:05:50 -0400
X-ME-Sender: <xms:LlDfatNL1kDOTa2wVrQ8UjsPkCOH2Iv7Tkz7Ztkcj6isR9SANaoOqA>
    <xme:LlDfaqyucN-Vl3r_hwQt7pODdLDgujTfEKxoftnt41BJK0AieNy6olfA1jQ6Nl_VF
    jPWQATzCOLOz6VpTN-2H1IOAUh-YEK-umuzQD5lNn8CPNq1skAoxfM3>
X-ME-Proxy-Cause: dmFkZTGwesdRiz/51pG2zzQsImFZJq1bNAtohem6TtzeT8RQbwfkHkAxrG4HkV1T9xUfoR
    nuauFLJd0HVupc9/T80LNPlMs5gV2u7l8sHbqW6q4AraVBddKjhwKe6DwF5/HY/9Q51AXC
    5akWbrHrmnLYhruhgX3ho13k0eAC5DfNUbj2tQCLQESXST5oulojhIJgFTUv8LJhDaXnQE
    uCaqt+fnshfQ4rTUxYTS8Th4F+22zpRGd8vtrUvJDIJFPjVPAdNrQ7iPyRgQg+mOj+izB3
    8eQBOFJQXAdczbMPdVcy5ok6qyPYAek3A1jaSaIzro9nhh9lyiGMn9yeXiQWvrY7umh6j5
    R88+r3VNiYb8P38r6bBK49gAoZcaOo0Tt5BjLv3oKSQncpqJ5QybDDDizZbjlgTAgY8cae
    8Acd+xzfNrgyACdNCiGXwTQtbGaZYZePZ2yJ7FXNnivPkilR+vsdf82LSAPDdOBOBVgToe
    i3eGVAmiEryC8ALXNLkmtEZR57z0HKUC/yYsriIIVwOtOVgywA3x/bO9d5hfMgLGJrphUX
    9pwueqG+OitrFQa5naUj3glg+Gq2FGW7OYMymSGttILwla2L+wo5e0HRQrdb/O+ifR41mc
    89D7JukRzUuigwk+ObHicHsDmAa81nZKmYEN6zkhKJKgmA/+WqGQlBXaYPUQ
X-ME-Proxy: <xmx:LlDfaql1MUSL5sPaUaKhGdM1l0RD5UUE941VI64yCve7n2t053rvfQ>
    <xmx:LlDfaihdQA1hDVK7K3fjoTf6pEtO8IaKMJCPqmbc4RGgIZEyPhbx2g>
    <xmx:LlDfam1urlDB_K7KPWrLyJSRS7xl3yIOmbUEzqo_6TNWMTrTh5so4Q>
    <xmx:LlDfajJSRLbDtYUpvL4bUmf3j3Go-cjw3-43uEQVRZQM5kmERfFpDw>
    <xmx:LlDfauxG4pKR7JITXhaB2elJPbrTrm1n8C7Ze9Mty-Y5yHeWLTGwqz2n>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 60B4F782738; Mon, 26 Oct 2026 09:05:50 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: A9m_2S3J7uFJ
Date: Mon, 26 Oct 2026 09:05:30 -0400
From: "Chuck Lever" <cel@kernel.org>
To: Mohammed <mohammed.saad.alquraini@gmail.com>
Cc: NeilBrown <neilb@ownmail.net>, "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Message-Id: <68c4df1e-385f-47f7-a387-7176855ab24e@app.fastmail.com>
In-Reply-To: 
 <CAD37_9jTO0jvrroWzbNWOk0eOj8Otw6rCWE7Ap1kb13OsP+0Wg@mail.gmail.com>
References: <20261022205357.3239985-1-cel@kernel.org>
 <CAD37_9jTO0jvrroWzbNWOk0eOj8Otw6rCWE7Ap1kb13OsP+0Wg@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: Fix use-after-free in svc_age_temp_xprts_now()
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Mon, Oct 26, 2026, at 6:30 AM, Mohammed wrote:
> Hi Chuck,
>
> This patch fixes the issue.
>
> Thanks for the quick response and fix!

May I add:

Tested-by: Mohammed <mohammed.saad.alquraini@gmail.com>

?

> Best,
> Mohammed
>
> On Thu, Oct 22, 2026 at 11:54=E2=80=AFPM Chuck Lever <cel@kernel.org> =
wrote:
>>
>> svc_age_temp_xprts_now() moves each matching temporary transport
>> onto a local list under sv_lock, then drops the lock and walks the
>> local list without holding a reference on any of them. In the
>> meantime svc_delete_xprt() can take sv_lock, unlink the same
>> xpt_list node, and drop the transport's last reference. An idle
>> temporary transport holds only that one reference, so a peer FIN
>> that arrives between the two loops frees the svc_sock out from under
>> the second loop. The notifier then sets XPT_CLOSE in freed memory,
>> and svc_xprt_enqueue() reads xpt_flags and xpt_server from the freed
>> object and queues that object on a pool for an nfsd thread. KASAN
>> reports a slab-use-after-free in svc_xprt_enqueue() under
>> nfsd_inetaddr_event(), with the object freed by svc_sock_free() on
>> an nfsd thread.
>>
>> The two-phase walk dates from when the second loop called into the
>> socket layer and could sleep. Commit 546125d16142 ("sunrpc: don't
>> call sleeping functions from the notifier block callbacks") moved
>> that work to the nfsd threads, so nothing left in the second loop
>> needs sv_lock dropped. Mark and enqueue each matching transport
>> under sv_lock in a single pass, as svc_age_temp_xprts() already
>> does, so that svc_delete_xprt() cannot unlink and free a transport
>> the notifier is still touching.
>>
>> Fixes: c3d4879e01be ("sunrpc: Add a function to close temporary trans=
ports immediately")
>> Reported-by: Mohammed Alquraini <mohammed.saad.alquraini@gmail.com>
>> Signed-off-by: Chuck Lever <cel@kernel.org>
>> ---
>>  net/sunrpc/svc_xprt.c | 16 ++++------------
>>  1 file changed, 4 insertions(+), 12 deletions(-)
>>
>> Mohammed, thanks for the report. Please test and report your results.
>>
>> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
>> index 5db42e53be62..076c624fe675 100644
>> --- a/net/sunrpc/svc_xprt.c
>> +++ b/net/sunrpc/svc_xprt.c
>> @@ -1075,29 +1075,21 @@ void svc_age_temp_xprts_now(struct svc_serv *=
serv, struct sockaddr *server_addr)
>>  {
>>         struct svc_xprt *xprt;
>>         struct list_head *le, *next;
>> -       LIST_HEAD(to_be_closed);
>>
>>         spin_lock_bh(&serv->sv_lock);
>>         list_for_each_safe(le, next, &serv->sv_tempsocks) {
>>                 xprt =3D list_entry(le, struct svc_xprt, xpt_list);
>> -               if (rpc_cmp_addr(server_addr, (struct sockaddr *)
>> -                               &xprt->xpt_local)) {
>> -                       dprintk("svc_age_temp_xprts_now: found %p\n",=
 xprt);
>> -                       list_move(le, &to_be_closed);
>> -               }
>> -       }
>> -       spin_unlock_bh(&serv->sv_lock);
>> -
>> -       while (!list_empty(&to_be_closed)) {
>> -               le =3D to_be_closed.next;
>> +               if (!rpc_cmp_addr(server_addr, (struct sockaddr *)
>> +                               &xprt->xpt_local))
>> +                       continue;
>>                 list_del_init(le);
>> -               xprt =3D list_entry(le, struct svc_xprt, xpt_list);
>>                 set_bit(XPT_CLOSE, &xprt->xpt_flags);
>>                 set_bit(XPT_KILL_TEMP, &xprt->xpt_flags);
>>                 dprintk("svc_age_temp_xprts_now: queuing xprt %p for =
closing\n",
>>                                 xprt);
>>                 svc_xprt_enqueue(xprt);
>>         }
>> +       spin_unlock_bh(&serv->sv_lock);
>>  }
>>  EXPORT_SYMBOL_GPL(svc_age_temp_xprts_now);
>>
>> --
>> 2.54.0
>>

--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
