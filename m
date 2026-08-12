Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2B2DC353A7C
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 14:02:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786543371; cv=none; b=D0IUdDyOdXd6TYSTkRgYMaDFIDh4bXhkAPwF+U9sEWxW0dyakQAOqYyzCRde9uMjiwWIDV7kGKhpPofn6gGGmBlmhURLU7F9XkFqA7KdP8DuGcilGkYTotZuESifu/zkijwjiz40mlnOm9prRm4fbfOBgvlJ7KnJQZknmiOt/GQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786543371; c=relaxed/simple;
	bh=lZoKBIAgZ4OUNPP0Lq6z5P71vtLWuojs24AydelwQDI=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=FJ4dJbp6wbwzkCA5VPmL6/HkQtWu1tCqRzP/29xWaNKpD+u8m2MJzQccFLQD95vmFxvSgHqoHwXfx1qXDTZwkS7I4Y+bAB36JVv7FCfHAzFrdebRMUfDZhx20mYa5Jw5aR/42+4y5pOHuXvpht0e/6QdjJqnDxTgF9/YIu6zz50=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NvwKJ+NH; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NvwKJ+NH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C75D51F00A3E;
	Wed, 12 Aug 2026 14:02:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786543370;
	bh=6Cie6K+XCHws/4nk7H9PXO1gOyQNAvycgu4+FYKfptg=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=NvwKJ+NH8b/0Hc5TfvqrtEXeCY4TgNOk6CYNqSHeEJQriYlYU6Gxruc4DmyNCmPI7
	 yoWUF0lU0Sc6KHwemvVydjtlpXdWYH4ZCrzvwEJxrt/bLlF7aUpvLLq0Vjvr/coyqW
	 m/TKEpl5iAB8NRtUb/XbsIm2lwZCYB+Hfz21Z537waFSwe5fXmTpqpvDz4icmyw1JE
	 Dz5oHJXyzBiq80sRknNOLZ8DjlbaMvWaFeYnniAuZOZnsMow0+q5jTvN6QB9X89eAq
	 lsayG/kj7q1gHUhtiOXJ/xPO06fI5YSAj+1aWBx+tm3lJbuZBrFFTabVfkpvR2w9wd
	 bWRzTnDlLzggQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E080FF40066;
	Wed, 12 Aug 2026 10:02:48 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 12 Aug 2026 10:02:48 -0400
X-ME-Sender: <xms:CH18atTI8VZaGs9cVKkhmJIlQUWuHis9e_W2moQxIrLLczZxTgLG_w>
    <xme:CH18ahnOXxYw_47WIF4_ytehESauAEnI2r2Psic2dUU_N1ecQgCW13kwuAWhd_HVW
    RB7iKHbFpaNhjJ8z6_v69ksjaO2GH16kVZg55RkMSTAIi_U1oC6ig>
X-ME-Proxy-Cause: dmFkZTE1XSumyrEeL5yxU5QgN4X3z6lwjlsfsp9XWfWmRSHnyE9RtHsJ5/8DqM5io2K1Aa
    W2nzaAjEDYlNMxoEWqp8pYL1/oiOWM+zzlCUl0pQnpV1RvWEtM8hm3nR2gXVRDcFlle3/8
    mR+vmj2S//sT+Lu6HDtV6pClfPvwI4qE79pS3KCJbHo+DRl9uYM/X2uwS6l3/PpX6zouqK
    cQkwvjYA5k+35z03fZR9ZrYTV5FlZTkXq1dzDnk5U41Q8e0sxAwrw+74HAgYo4Jf2P59/D
    w/aowIfXon2zl9Wprico6fKUrVnVUhTvSSCKDNwNlajT0erxLDHjsOEy0QijrZZSNuMMoY
    KajDFtwQX6u65GJAdWhUUlg5RqqAZ9I2ZN7gHhb9tSVQ1aMIzqR+qK+wXlhzsW9DOeBb31
    IvgXbgi8cfFec61KQzX1SmoOFTizzWmnD3blBXEnEW3JA8mMhDEZqvzkmEGzYoXJvF7wcK
    aSaA++yjmb0VSxEDCNILmxLbB1SI5OeyhQYPEiEzzWLh9IkWUk5xZ2eBARYI9j0vhlMYTB
    M3AxDmyOjT1r5SJhecTkSjxjBB0gsKvD2Nlcsoa0mgcw7oYrQG6r4nswy/zSXKp58Wsamt
    ZBljewBtNOYTFM3/v1xhLvxutJ5njeR+8BHS76HXz+3OETrf/DqWPbKCc1Yg
X-ME-Proxy: <xmx:CH18agTxdMbT_TE9O-wjJ_q2Yw6IrP358v5mDycl5jmyk8yF3JX3nQ>
    <xmx:CH18apw0vBgT2OvwyDcMFrrUj4n5GX3JEYbL6BnK8rIu4ySH749VSQ>
    <xmx:CH18agDf-em24-E4k8q_QO4TPBu2moPmb9nBDBK01KvIaZm7yzn2Og>
    <xmx:CH18alHTceTfc6PFaH5nWKiXAppkADA9Pyed4zMlVhaZqW7v8Tz_ig>
    <xmx:CH18anOUGxxdqtvXTdaR4FR2qNDG34X705VRqjEbW9KPRyd3DjuGO5eZ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id B8969780B78; Wed, 12 Aug 2026 10:02:48 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AGriQMNDMdvJ
Date: Wed, 12 Aug 2026 10:02:32 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Cedric Blancher" <cedric.blancher@gmail.com>,
 "ms-nfs41-client-devel@lists.sourceforge.net" <Ms-nfs41-client-devel@lists.sourceforge.net>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Message-Id: <2bee615c-0c9d-4e87-b64e-b190ce5b834e@app.fastmail.com>
In-Reply-To: 
 <CALXu0UeKoYPq0FOGe2vQP2p9txTzEkscc10hy4Lw_S6=wK1a3Q@mail.gmail.com>
References: <20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org>
 <20260811-recall-any-keep-count-v1-4-de9ca00493b7@kernel.org>
 <CALXu0UeKoYPq0FOGe2vQP2p9txTzEkscc10hy4Lw_S6=wK1a3Q@mail.gmail.com>
Subject: Re: [PATCH 4/4] NFSD: Send a meaningful CB_RECALL_ANY keep count
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Aug 12, 2026, at 2:17 AM, Cedric Blancher wrote:
> On Tue, 11 Aug 2026 at 21:57, Chuck Lever <cel@kernel.org> wrote:
>>
>> deleg_reaper() sets craa_objects_to_keep to zero on every
>> CB_RECALL_ANY. Per RFC 8881 Section 20.6.3, that asks the client to
>> retain no read or write delegation at all, whether or not the
>> delegation backs an open file.
>>
>> The field names a count the client may keep. The client picks which
>> objects to return, because the server cannot read lack of recent
>> use as lack of usefulness. Zero leaves nothing to choose among. A
>> client that complies returns the delegations backing its open files
>> and reopens each one with CLAIM_DELEGATE_CUR, so NFSD trades a
>> delegation for an open stateid and recovers nothing. A client that
>> reads the zero as "unspecified" does nothing instead, and
>> nfsd4_cb_recall_any_done() inspects only the reply status, so NFSD
>> cannot tell the two apart.
>>
>> Derive the keep count from cl_deleg_count and ask each client for a
>> single delegation. A larger request reaches delegations an
>> application still has open, and both callers re-arm while their
>> condition lasts. Skip a client holding one delegation rather than
>> send the zero again. That gate subsumes the list_empty() test above
>> it, and it belongs above the NFSD4_CALLBACK_RUNNING test_and_set. A
>> continue below that point latches the bit with no callback in
>> flight to clear it.
>>
>> The Linux client ignores craa_objs_to_keep and returns unused
>> delegations from the type mask alone, so the count changes nothing
>> for it. The gate does. The reaper goes quiet for a client walked
>> down to one delegation.
>>
>> Fixes: 44df6f439a17 ("NFSD: add delegation reaper to react to low memory condition")
>> Signed-off-by: Chuck Lever <cel@kernel.org>
>
> ms-nfs41-client hit that bug when implementing CB_RECALL_ANY
> (https://github.com/kofemann/ms-nfs41-client/commit/3abe73c8ab0d924450a1c1c480f0b14f963f9531)
> with Linux 7.0 nfsd.
> What should existing NFSv4.1 clients do if they encounter a
> objects_to_keep value of 0? Right now it recalls ALL delegations,
> which basically is a "reset" of all delegations.

After studying this issue for a few days... and sleeping on it a
bit...

RFC 8881 Section 20.6.3 does not normatively mandate any particular
client response to CB_RECALL_ANY other than returning NFS4ERR_INVAL
when the craa_type_mask bitmask is invalid. The client-facing verbs
in that section are "is to return", "chooses", and "it is the job
of". All descriptive language, no BCP14 keywords.

Thus, according to spec, there are no interoperability consequences
if a client ignores the value of the craa_objects_to_keep argument.
The spec gives client implementers considerable flexibility here.

A server has no visibility of which delegations are actively in use
on clients, since the point of delegation is to reduce client-to-
server traffic. That's why the client gets to choose which to
return.

A good quality client implementation, IMHO, should choose idle or
currently unused delegations, but protect state that is still in
active use. To return a DELEG stateid that is still in use, the
client would need to first ensure it has an OPEN stateid to
continue using. That would result in no real change in the server
memory footprint for that file, so there is no benefit.

AFAICS a craa_objects_to_keep value of zero is not a bug; it is
in fact a valid value for that argument. But NFSD shouldn't ask
clients to toss out their entire working set at the first sign of
memory pressure. The new behavior is a little more graceful.

(So I realize the patches don't actually say this much, but my
thinking is still evolving).

-- 
Chuck Lever
