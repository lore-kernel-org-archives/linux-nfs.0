Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C4D04ADD88;
	Thu, 23 Jul 2026 13:25:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784813114; cv=none; b=qvn4JNtVqhL3+kf9TMkFRWNO7r8bgmITPs+JLSi4KiKpyKG2M9U4ZbKGzAGYPbkyedPnOltgV1atb67RodaglV1L6EXJzMNl6zaued7/Rp9tAs8vtphi1+aKOwUKjM4jknHFBbAV+M9Ktue0hb5kNBAxNGFrX7cNS1UU4mq1sdc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784813114; c=relaxed/simple;
	bh=+iWr8OpaJ5TU0IiAraJloQet5APXdgUoVFdU0dsewFk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=pUnwFfXQ9Nc98j3Vj0nGhYoOzd14ImpRkuEoCxslrQGs2D/dte6fcFUbaGXnG3ISEOMUG0dF6oQtr8KZNh24nnkWPpTceYIyTz7jz6EaeAnrKBFHh7r0taarAM1SHyjeT7sfPAAhbUJXxEt1ZC5DVviD0cMuvXJHjMISY7VNPiU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=alB7t7HB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="alB7t7HB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F1FC51F00A3A;
	Thu, 23 Jul 2026 13:25:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784813109;
	bh=XfoXV5zKHhEStwiESOWCUjT3nr0t9Ovcx9JkQKxS7B0=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=alB7t7HB85sTjCVHKziVm164ckWofiYvwW9o7DwJTR0KWL/srhlp0NyHXKoVby4KC
	 5NGht23gLQ216adDffjtYT0/1uQ6Fy6WGNlNzBDeeuXAOXm3g9Mx2HxdIUMf8WX+tw
	 PaNYKxjUzjAhykE596320SUdcI1KffKmGhGMO7npUvlzhBzJFelPPdRuPpgEz/Ash5
	 63Dxe10QQhC/OEwwAJ0pJ+K4UJQL+YmJBxuHQa7L8N/uY3fnlPeh36hjVtOdo0tgzI
	 Z0kxhTyqIotXf3CpCrpEnVZNLCq52uAwwvZKhdRiMA2afoCQjMY9/NIbrLNn7rYhIK
	 ed6HEecQj++xQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 07DC3F40078;
	Thu, 23 Jul 2026 09:25:08 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 23 Jul 2026 09:25:08 -0400
X-ME-Sender: <xms:MxZiaqCeryaL51E1nO9pnlDP_AGIgNJWkSC-NUoXIqC-G3JgnX5H-w>
    <xme:MxZiavUdWRhQt0HCm_NZpx4cuig4GzCQE-h1uqTpM4FDk9DaC7wQpWf_b61MRG0Sf
    4xEEgFf64mpyrQNkZ73MesUmAqRCX2IgCNbbytVyjw74IT73hxAXEdS>
X-ME-Proxy-Cause: dmFkZTF7PTeqYW1N2ILwoxGV9H2088DWTkDINmb9nTVGfZMGC40IZZbae/JtOHiVqowYtW
    pDNMxvXW2C+HgGGGAIZUElapwBTcCnk0A/C8dw7s26e5Mm/A4wbAi6Wbm/5Tq+XnggFsxl
    LZEMJg1ZhwjGPr6vZGgx3k3n48baFaa0kfEsMTWzpgI1tIiHXjdeKAs8Y5tdANO0KdHJbv
    EA2fpJvdvSiTT9o9RrXOKJ20mkzRAQz1rcd1Ds8tvORkILV19zCdPWHbuBF6DYGwLfmgkg
    62A3+MWswIeH1n6V5jSyxxg0jtqD8SGptMjQb0DkDIf8kERp/7mmL1IGNYUdeztsX7MKTV
    Re7IpcOZGPnkbGnmDEA58Ys/h94zDsxOdZmZtwrJQSyoZi9y4c8HzD/wQBxyMFCqtn+sRc
    7ZU0QNaPWR9F8yPNeNev2wFIKgfGiycv0Kd4D/l8UZ1AzSpBQpdw/x5GEDjrxJH5xczKZ0
    TUrq7H9V2eHC35L/6U89aIu7wcMtVQUrdGmv03AAzJnnxQ05TH7PG+KELrBW5zEyS61Eo9
    acXrv8Y+sYqu8hN33/US/fvZnF843deomgz39MnQpsf2eoecLPc13IOEv6ZPStJdZ5jQTT
    aMdcQvs6JcudrilzSu+nNm2LrqZ/2m42zhe2qvAj7WMNN8UtsEUJCNkHYh2g
X-ME-Proxy: <xmx:MxZiahnTeffI-85bY55ISM2vxXe-bBV4sU67aQ6L_B5Mv_j0Z1Q3Cg>
    <xmx:NBZiamOj-ex2VKTBlXdrP9Q0v4N6GUNA60vnSQskCyup9wOEZc43UQ>
    <xmx:NBZiagLBWHiMuNQs7mX0xmbicf4szbRcBByUvFLFdyfosZi2qZ6lRg>
    <xmx:NBZiahF4QuGGlX4q4SeSTUOFEFYTvFttZxPWabyx62-yEmn224mnNg>
    <xmx:NBZiahBrhe2sRrP2eieOu_UCzwwISdp8nYnYhAWV93rsMOJmoYugtmEq>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DA2CA780075; Thu, 23 Jul 2026 09:25:07 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AxBNoR0sEYLw
Date: Thu, 23 Jul 2026 09:24:47 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Hannes Reinecke" <hare@suse.de>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>,
 "Sabrina Dubroca" <sd@queasysnail.net>, "Shuah Khan" <shuah@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: netdev@vger.kernel.org, kernel-tls-handshake@lists.linux.dev,
 linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <909e0132-5c0c-4c0c-b8c5-b90b88ad0231@app.fastmail.com>
In-Reply-To: <b9d60674-1ba7-4f23-beee-4ddfffd4dda9@suse.de>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-1-29545d034f3c@kernel.org>
 <b9d60674-1ba7-4f23-beee-4ddfffd4dda9@suse.de>
Subject: Re: [PATCH net-next v2 1/6] net/tls: Bound consecutive no-data records in
 tls_sw_read_sock()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Jul 23, 2026, at 3:11 AM, Hannes Reinecke wrote:
> On 7/20/26 4:27 PM, Chuck Lever wrote:
>> A record that delivers no payload -- an empty TLS 1.3 data record
>> today, a control record once read_sock_rectype() lands -- leaves
>> tls_sw_read_sock() in its loop without advancing the caller's read
>> descriptor. A peer that streams such records keeps the receive loop
>> running, and the socket lock held, for as long as the records
>> arrive.
>> 
>> Cap the number of consecutive no-data records consumed per call. The
>> count resets on any record that delivers bytes, so a normal stream
>> is unaffected; a peer supplying only empty records is bounded to
>> TLS_RX_NODATA_LIMIT iterations before the call returns 0. read_sock
>> consumers treat that as "no progress, re-poll" rather than EOF, so
>> the connection stays up and makes progress once real data arrives.
>> 
>> Only tls_sw_read_sock() needs this cap. Its consumers drive the receive
>> loop from kernel context -- a work item or service thread holding the
>> socket lock across the whole call with no return to userspace -- so an
>> unbounded empty-record stream keeps that context and the lock pinned
>> for as long as the flood lasts. The cap supplies the return boundary
>> that a system call would otherwise provide. tls_sw_splice_read()
>> and tls_sw_recvmsg() already have one: they run in the calling task's
>> context, reschedule while draining the socket backlog (cond_resched()
>> in __release_sock()), and drop the socket lock when the call returns. A
>> flood there costs the caller only its own scheduler time, so the cap
>> would add nothing.
>> 
>> Signed-off-by: Chuck Lever <cel@kernel.org>
>> ---
>>   net/tls/tls_sw.c | 13 +++++++++++++
>>   1 file changed, 13 insertions(+)
>> 
> This is technically a fix, so it might be worthwhile sending it
> on its own.

My impression is that the issue this patch addresses is not
reachable until the subsequent patches in this series have
been applied. Thus I positioned it as a pre-requisite patch
in this series, and not as part of the earlier "fixes" series.

But light taps with a clue bat are welcome, as always.


-- 
Chuck Lever
