Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 92AFB469842
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 18:23:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791829435; cv=none; b=YuZC7zIOFclstPcgYfZo65fJp4h/UzfUILHpztDyYVUiVr+hqMShdgAALJ0lvFGjVX3HFNv0P2r0ns1SjLj8Vf39zYgMt9InTM7BJOfqsYKdCR+ir+tPrjUSbecvuef2Oo24BEQNvmasUCxrpHjqgS0q7f+QkDxLQxg8ffgEoSI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791829435; c=relaxed/simple;
	bh=n4dSnkwuEDZZ5daUBNZ76MEu9+u2f0loJXwS8d8meCQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=I/HHo+pInanJcCVpY+eZg0C9Tmkn04B5ixVEY5abHgpk2akRP7WTIStK5AbRIMp5qoNLLoAjHv5bhE3sUBdZjmIv8ZpN7UFJgB274ztgqlZZM9NmIAFo7kcmxgx1kXVAymnEkupcD20yWweIPTD6QZLNHSPZ/Lxf0Ad1M462+4o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hIgaVG3h; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hIgaVG3h"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2DEA31F008A3;
	Mon, 12 Oct 2026 18:23:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791829434;
	bh=Lmo8N99soMQbzuuJvl1m7AuZHlNK1WR2LxmmjhycY4o=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=hIgaVG3hMBkvfNNnioS4+QJ5MExfPGqatHLv+EGiGSN9h0Vno7SBiC8TaQh8Fcc7+
	 d9uZccWLLDokjTcTFWp9fuSQufsqc2sWJzAdXw6JSq7sFzUYI9qEhaLIyJA5zhzlWc
	 lNKFqSHhYvgLa1EAmk9xqO/2MvaVf+H7XSovYqbb7kMmnKWIo7MPgSOFfiVvC1ru2u
	 /vwPXIqMz1gaBlNQwnOD+4MphBuY7PSNwRiB6uuwCdCjx31JDacNnXWxaTB8+AdwKi
	 bFuPToMPTWoDb2NrqGw42okDymD1ESCMK7i77S9/PDdmhCuA94w33npVsoko2wkAn3
	 +luTqzJFrHpTA==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 637F1F40066;
	Mon, 12 Oct 2026 14:23:53 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Mon, 12 Oct 2026 14:23:53 -0400
X-ME-Sender: <xms:uSXNalIofRQoW9ddsTPHmLUlOdvlVBwOKsb5lsgABc7wsY559bS77A>
    <xme:uSXNar-qqk4cVV_Ky-MjEd42dbOX87dwGkov2mAKbS7D0rHDE3kI2TOZYz2JAHVSR
    x2YndravUcGvNMwmAG4hwPnR7b2nI5jE09iDM3FL4Way2ljIaT3tOjI>
X-ME-Proxy-Cause: dmFkZTGePMjlNj4NI6Qa7hzcO2GobSVZXrEzUowRJUp0GOOX///NtlA5gsebg6RCiJyqr5
    hq+539TCVtJ2Q9RRb8b0OxRe7pADyw0fEmELaaCIvs8sqtuYm3g/H+7W3Ud40f11WXsep1
    2R8mYmSu1In2x1uxkkR5uXGWES+XDKNtCXNO4BxSq7n66sOJwqKCZb6BCFM7U1EQmaX2uI
    A+HPXwQ3oRSpY7+GINt7uKkq/nMnJSMoqeowgGc6Ylznh/lJp3/NZIsnmJdbZ4ZyTuRVmt
    JjFV3faRYwZT3ZXDH9/cfTuKCT8y5gCx2W59d4TLjz1IELj0IiBgtUYs9usD4T4Wm+2XmN
    XtBsxDaU+htGJT1LUoK+Rw+77BKVAnjOWtJylSHAtErlLb+2I7pKKahzRdvDcccgUgl1Ec
    +pQ3LYWnG8BgTNr1uGCfU+SBOF+18QUUStihgZVGO/ckgA0FfdJOrhBW8h5uVB9K3/8ypD
    7bUwNfqalgoc/fN7U5TmXlwFY8E4su53PlM5wfYnpT4zf+EUIWu/nBuzLGkYT6YXirio2q
    1hYjZVNgZ1vHqLhNn+U02lP8293r2jdDKZ7na+cmtrzFrHzhr4KQCpmpvOn/N/ugSQoho7
    BAWyWAO67mJf3Qh3Ua9CEgRMOxt6JpkpFNdMJK3QMwaP+erCEgKimKLAxd4Q
X-ME-Proxy: <xmx:uSXNagruyD8xWTt25OoOLHlcmUV-xfjCdn__vDQlrqFsNt-C4d8bwA>
    <xmx:uSXNaptXF_yhzo3j2HTQadf5Z78kBtYWjXdrbkHfl4GU8DdBTYywLQ>
    <xmx:uSXNav1mp9f3MdcWRNpVtE1OrrSgLQ8HSM2rZakAodeVA5rIhTDOIQ>
    <xmx:uSXNakGfDGkn0OVrSDI4SxAbEhuUdJaRP15B-SYsqX9644u8cL7GsQ>
    <xmx:uSXNaqudINPjN2l-mnCjSwfzJGQ5ORcYAXXFZkh8NQlnK3KGMNocBjcU>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 444F4B6006E; Mon, 12 Oct 2026 14:23:53 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AqK0L564hkaB
Date: Mon, 12 Oct 2026 14:23:32 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Chuck Lever" <cel@kernel.org>, "Jinpyo Lee" <bint4b13@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, BoB_Tobabz <bobtobabz@gmail.com>,
 linux-nfs@vger.kernel.org
Message-Id: <4a3cfec7-dc3f-4010-a84d-9c39f8347d2b@app.fastmail.com>
In-Reply-To: <a87481d1-1246-49e7-8f3d-196b65301e5c@app.fastmail.com>
References: <031205cd-1099-47a0-889f-ae203fd6c8c5@slotpi15m67>
 <20261012112710.773-1-bint4b13@gmail.com>
 <a87481d1-1246-49e7-8f3d-196b65301e5c@app.fastmail.com>
Subject: Re: [PATCH v3] nfs/localio: pin UUIDs during global invalidation
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Oct 12, 2026, at 1:14 PM, Chuck Lever wrote:
> On Mon, Oct 12, 2026, at 7:27 AM, Jinpyo Lee wrote:
>> nfs_localio_invalidate_clients() moves UUID nodes embedded in nfs_client
>> objects to a private list, then walks that list without retaining the
>> containing clients. Concurrent client teardown can free an entry that
>> the iterator has already selected, causing a use-after-free.
>>
>> Take a reference to each selected UUID under the namespace list lock.
>> Keep this reference count in nfs_common, independently of cl_count, and
>> have nfs_free_client() drain temporary UUID users before freeing the
>> client. Releasing a UUID reference wakes waiting probes and signals
>> completion when the last reference is dropped. It neither calls into
>> nfs.ko nor performs final NFS client teardown in the NFSD invalidation
>> context.
>
> Until someone tells me otherwise, I will treat this patch as going through
> the NFS client tree(s).

Yes, most likely. I still need to look over this version of the patch.

Anna

>
>
> -- 
> Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
