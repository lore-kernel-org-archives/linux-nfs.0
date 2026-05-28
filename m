Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 509AD369D4B;
	Thu, 28 May 2026 23:12:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780009943; cv=none; b=BQKGhUFLcp0Fluo3a1Zp/sdnWW7VUWd/0hHYICS/v8H5aaVnF0+FfyEuGKismFmNiikhDTzAKxnzZNsIUiDkCqz70VlQc5wocjNEhVir2RpLNt8EfmazQKwKmbkAgF3DI1izGEJYnnRwdZCiRRY7x9lIICMq0WqmClDr7Lpxxfs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780009943; c=relaxed/simple;
	bh=tjVLUJ3hcQ4f4QG6DOCoy6QqoKuRP9VuObCyKypLdp0=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=amocf/3qdMVTTSURhdPaxkv/LXIGeWR4q662TcmvfC10bj6CfnZV64xsPJa1VA717nFq5h323NVmYEejKMo0gt9PpITYseY07pL5VdFZIg7GVa0ktSoXRH6G5LBvWsKVDlErvd2xIRrfwb4FuxyPrkI3uapEm9FRqhn3tLgshoI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=W79LGtSK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="W79LGtSK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7ED6C1F00A3C;
	Thu, 28 May 2026 23:12:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780009942;
	bh=7+JlzBsC54oTmko1yeIZkPdrFu3gzyduwT6kv37XTKE=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=W79LGtSKSGf1RvEkWnzdeko8skjJHiQFiI1vbar4HRlSL+07ZSegQkkpEyU2m0Gqh
	 cMMr0lmRzeNwI0pgCnrifhmtvVeQoTN7iC7LNQIoYdAEXFM4UGf1ayR96OWF6EKx6c
	 RqeaAoirw+xCg2wHy7PtD/j2z9t8h6TxleUSpBuso1ltbCfUSNv9W5vBc9byQ17IS9
	 SuqDOOhLA2gjRKFNSJgxNByXf3c+q0U6rjl0hCtfEybfXzCGl3HZcol0IR4QVFWQmC
	 DirDtVIABPL0BGJSbDuJRuHnWUJzaSk0m63hgxwIUaOecxugML47EGDhxUPElgbSv3
	 qIRVS/4W9GCBg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 9D13DF4006D;
	Thu, 28 May 2026 19:12:20 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 28 May 2026 19:12:20 -0400
X-ME-Sender: <xms:1MsYajh6ZxR3OkcYf5YE5ykRrSSdNvCCdhW3YMUVckzwy1vgvgkSsQ>
    <xme:1MsYaq0tDL9f2jAvmyR3qg15MutuygE7OxpwzKbf1HFbc-BSHe5ydDg_5HrXipjmA
    RPkCksnbo0AUqLF8BKaSYbloke3aUa-PHt5AqsamtTOH0HXvmUfI2U>
X-ME-Proxy-Cause: dmFkZTGZkB937SyZ52sUTPba904ccbToH0w+1MSXYca2POFTJnnIvMwAqoETHbkQusi/YF
    yLZUuE8PiAzRW3pJSljHTCPZLsJiUlpFsHNGryQBqwf4iw+EHdo2h7KXrRETlQN9Ux23P2
    2ai427SQpbFwIw5u51cPDwwhO4Ma8tSy8CjaizWEIz8iY3glOKtme7xORgjyV9jcecn+6I
    uxMckucNfKi9993RWlZ+/DNQB3Yes7+Xlr0MblLb24UQI5vpiz88nZ+HS7lF+SLeK1V+ls
    XSNG238Id9+IWGPHhWFLuV0qMlv4nPFBXzG+5LVJin5e32v8Po8TNsHnHrgIWevKJoLafu
    lDd2EgZJg5GuYS1ttUmEZvKhDKWuAw7ha6wVsnv35lCJTtneYOT7PJms5feGHj8SHrxyT5
    rWoudwKcqSIrAaX9/IKXXCL4Cc0O1UONmmPTpwqNDmVRXoNOC9Lj+fTbFIHo+3zDIAPqLI
    RP/NH16OqUmirVVF9HoQnnj3RjSakAHvCU74pUTRUmill5NLX+VfPGbn6VaWoBYYo2rTzr
    dVNykcyOIHz+C9V+BcBZksHCZfYrXBs/L7Y+KExQWFM4/ni7EnomRRe60q5gyp5VrqlgDg
    cTfPeIYah7j1Nr/AFqr2XHKQMpoD41Y4TZY5qJo4b9F8tDahVSTIjjtwd3dg
X-ME-Proxy: <xmx:1MsYahmR4pJLjQihVox9u5ssUMyLYJwfy36Qp5JWuT9TDLiC5dZtEA>
    <xmx:1MsYaiadkz0e40TUj7GP9LgwCmyfP7hpv8_xZDLBwkfVkt0sTOsb3Q>
    <xmx:1MsYahOVY756pmo9EXQLpm-DB3NJtifDtiiBCMVdDwP-V5aNuZArgQ>
    <xmx:1MsYaifJX08cPnRCLw-cwGDslqQm0xfZeM3a0o9hEeO9BahkYuDgsA>
    <xmx:1MsYanHLcZIkjnO2wDGXr7fDtEL_CunHrdUBYeHnWMTzNWfDghazvMGd>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 74E65780098; Thu, 28 May 2026 19:12:20 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Thu, 28 May 2026 19:11:59 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Rick Macklem" <rick.macklem@gmail.com>,
 "Jeff Layton" <jlayton@kernel.org>
Cc: "Chuck Lever" <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "J. Bruce Fields" <bfields@fieldses.org>,
 "Scott Mayhew" <smayhew@redhat.com>,
 "Trond Myklebust" <Trond.Myklebust@netapp.com>,
 "Andreas Gruenbacher" <agruen@suse.de>, "Mike Snitzer" <snitzer@kernel.org>,
 "Rick Macklem" <rmacklem@uoguelph.ca>, "Chris Mason" <clm@meta.com>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <bffd1333-a65e-40d9-9553-7de4401a55bd@app.fastmail.com>
In-Reply-To: 
 <CAM5tNy7sSXFUWFVkKEYVt9nLPOCT_-+7KfgZeoZ2UCv_eLMvrQ@mail.gmail.com>
References: <20260528-nfsd-fixes-v1-0-e78708eff77d@kernel.org>
 <20260528-nfsd-fixes-v1-9-e78708eff77d@kernel.org>
 <CAM5tNy7sSXFUWFVkKEYVt9nLPOCT_-+7KfgZeoZ2UCv_eLMvrQ@mail.gmail.com>
Subject: Re: [PATCH 09/10] nfsd: cap decoded POSIX ACL count to bound sort cost
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Thu, May 28, 2026, at 6:11 PM, Rick Macklem wrote:
> On Thu, May 28, 2026 at 2:56=E2=80=AFPM Jeff Layton <jlayton@kernel.or=
g> wrote:
>>
>> CAUTION: This email originated from outside of the University of Guel=
ph. Do not click links or open attachments unless you recognize the send=
er and know the content is safe. If you are unsure, forward the message =
to ITHelp@uoguelph.ca for review.
>>
>>
>> From: Chris Mason <clm@meta.com>
>>
>> nfsd4_decode_posixacl() reads a u32 entry count off the wire and pass=
es
>> it straight to posix_acl_alloc() and sort_pacl_range(). The latter is
>> an O(n^2) bubble sort, so a client-chosen count drives unbounded CPU =
in
>> the server's compound processing path.
>>
>>     nfsd4_decode_posixacl()
>>       xdr_stream_decode_u32(&count)       /* uncapped u32 */
>>       posix_acl_alloc(count, GFP_KERNEL)
>>       sort_pacl_range(*acl, 0, count - 1) /* O(n^2) bubble sort */
>>
>> The encoder side in the same file already rejects ACLs whose a_count
>> exceeds NFS_ACL_MAX_ENTRIES, but the decoder introduced in commit
>> 5fc51dfc2eb1 ("NFSD: Add support for XDR decoding POSIX draft ACLs")
>> omitted the symmetric check.
> My recollection is that Chuck didn't like this limit. He argued that i=
t was
> specific to the NFSv3 ACL protocol and that the limit on the size of a=
 NFSv4
> RPC message was sufficient.  I, personally, think that 1024 is a reaso=
nable
> limit for # of ACEs, but Chuck can jump in here if he doesn't agree.

The NFSACL protocol limits the number of ACEs in an ACL to NFS_ACL_MAX_E=
NTRIES
(1024). It=E2=80=99s a limit that is defined in the protocol itself.

The NFSv4 protocol sets no similar limit. In particular, NFS_ACL_MAX_ENT=
RIES
is not a constant defined or used by the NFSv4.x family of protocols IIR=
C.

Using NFS_ACL_MAX_ENTRIES to cap the number of ACEs in NFSv4 ACLs is a
convenience, but it adds technical debt (slight though it may be).

So=E2=80=A6 We can define an implementation limit for NFSv4 ACL support =
in NFSD.
But it shouldn=E2=80=99t be called NFS_ACL_MAX_ENTRIES, IMHO. For clarit=
y of
documentation, pick a number (could be 1024) and state in a comment that
it is an NFSD implementation constraint, not a protocol limit. Name the
constant something like NFSD4_MAX_yada to make it clear it is an
implementation limit, not a protocol limit.

(Check if the Linux POSIX ACL implementation already defines and imposes
a similar limit before defining a new one for NFSv4).

Then prepare for an onslaught of complaints that 1024 is just too small =
:-)


--=20
Chuck Lever
