Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6899347045F
	for <linux-nfs@vger.kernel.org>; Thu, 23 Jul 2026 14:30:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784817023; cv=none; b=WKSx7uskebeHZ1Yp0C6zcU/VCtSsOZ337Q3Ht66ngqmveb/8n9fiQ4YjEvshw694nOYwB2Kdc2al0dPXG5E5sBC4aE7pQ34RLZ5yLdyBsAgfHhpxquZZ4Tg28qZ3HyR1enwbylsr9IzK8gjnU/vJcXRVtdmsDZueUGcBav1USQA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784817023; c=relaxed/simple;
	bh=F2s46wGOdPXKLgCIDws5nDZNONmvFp/+H2PhS2Z5czo=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=jy6DnGAVwGveZSrTMycygzMJ79nviw9A7DT8L7NQ0C3KPTDhym9i2VruJpRTGDusCgqvOrz/PTAmayab97ICSkI6kGvYpnCrHIBjlQvaFK7hz0OLOrHe6lZt8Un6TsktWGC9xEyV7RnGIJ2doPFeySNgVj//ko2LsVeO6nEFCFc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D37761F000E9;
	Thu, 23 Jul 2026 14:30:21 +0000 (UTC)
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6D96AF40070;
	Thu, 23 Jul 2026 10:30:15 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 23 Jul 2026 10:30:15 -0400
X-ME-Sender: <xms:dyViatwpYRxNT02u_2BdszsfWlN12RRwUXvpN4Seqql8f1ay6M1CPA>
    <xme:dyViaoFOWZtvf9wdOM0e0erX3Nz87Hv16tCtQKL5HmloQv58ILVrfGIrErwsvN5PM
    UNYFyp6PbmiuSOCzNewAlKLf6DlEsk9NKRu0emWmuPGhN7ffuP0U9pj>
X-ME-Proxy-Cause: dmFkZTEQAPoN18lgstHosNLPhj4kQ17L7UPJTbGO/hDZVLaKqmCDYBcvf5RQ0sv26awX0C
    +Yvjj86QfeDKbjS0CY3Ab6vDDIssEhfOF1FsHOkYY4AbCHdVu61HU06vO2mzPWK0AX/yil
    VwP6wk7ty+Slb5OOiEVt1iAFtw3/SmB0ftOG0IzUU6UijDTpgzsZe4QpV1rbYvn+JQaf0q
    LiEMUPwgtSdLxSNRmk+k/vhcjS+7CUopIiyON+EIOawKNxpITdvBAuy/HZVKpDB7bUNkFu
    VfR+9KIHMly7FKskG6dku65Tw2vqzJtY7k7aWdJ4lzFSOAYnIyh32IuJ8twGNQR9D6qSKC
    nZ6CCbeHtLS53v5l7e0xsnec4chGSvfSuF3qD+m3eZWfVaaWFFYKgksmwekpxN6EaqthA8
    mPexOTNBfzeK8Ru3A9dPiVrv/HtXxfHsWSK1tfWPawM9UIWlH/711w+1MZbU8anh51IxYS
    C8PGHQ4mDfbLnHShB4QybmmZ4NQPHA8W7sgkwmF02eGYATIXdf/XcxmGnIpuzEE4rnOyHf
    94qlHzdt8YhoWImkPNbSyVc7GAYTMqRmYe3nGZacKUPBot9O0s5FJCwaw9aW75DHLIPlsZ
    /h959mtyW02LnfmZJwG5HbMWDvWpLTVZbjtxT3W81BIhOgtKn5bQfklGOzjg
X-ME-Proxy: <xmx:dyViajXYGEfKb6J8SfGpeXdJ_WjoeaZ4oodkEgMSyyWaIcLnyLIvrg>
    <xmx:dyViak_4FbBW0Yedy2tXYkqyApXGsvArHl3KGNVAyjYoSCHFHJbi3A>
    <xmx:dyVian7xRPEWBmVWzoED-zGMlI3EiPAd7W-64frsRXwayLnjssQyUQ>
    <xmx:dyViat2EssvHQ3gcmRjU8-w0hKF8w_PJYpYXP8gSbLZ191vfwxOJLg>
    <xmx:dyViauwlyh5FspUBJCtXLxbz6jgN6pVOFMihwyyLnWktbwbzRTRoqeBS>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 413F1780070; Thu, 23 Jul 2026 10:30:15 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AxBNoR0sEYLw
Date: Thu, 23 Jul 2026 10:29:55 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Sabrina Dubroca" <sd@queasysnail.net>
Cc: "Hannes Reinecke" <hare@suse.de>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>, "Shuah Khan" <shuah@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Message-Id: <7a0f5521-3a44-4e8e-9a30-542b0ece448d@app.fastmail.com>
In-Reply-To: <amIj_DG7SuWx8MeY@krikkit>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-1-29545d034f3c@kernel.org>
 <b9d60674-1ba7-4f23-beee-4ddfffd4dda9@suse.de>
 <909e0132-5c0c-4c0c-b8c5-b90b88ad0231@app.fastmail.com>
 <amIj_DG7SuWx8MeY@krikkit>
Subject: Re: [PATCH net-next v2 1/6] net/tls: Bound consecutive no-data records in
 tls_sw_read_sock()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Jul 23, 2026, at 10:23 AM, Sabrina Dubroca wrote:
> 2026-07-23, 09:24:47 -0400, Chuck Lever wrote:
>> 
>> 
>> On Thu, Jul 23, 2026, at 3:11 AM, Hannes Reinecke wrote:
>> > On 7/20/26 4:27 PM, Chuck Lever wrote:
>> >> A record that delivers no payload -- an empty TLS 1.3 data record
>> >> today, a control record once read_sock_rectype() lands -- leaves
>> >> tls_sw_read_sock() in its loop without advancing the caller's read
>> >> descriptor. A peer that streams such records keeps the receive loop
>> >> running, and the socket lock held, for as long as the records
>> >> arrive.
>> >> 
>> >> Cap the number of consecutive no-data records consumed per call. The
>> >> count resets on any record that delivers bytes, so a normal stream
>> >> is unaffected; a peer supplying only empty records is bounded to
>> >> TLS_RX_NODATA_LIMIT iterations before the call returns 0. read_sock
>
> Would a time-based limit be "better" than a packet count? For example
> that's what net_rx_action() (net/core/dev.c) does.
>
>
>> >> consumers treat that as "no progress, re-poll" rather than EOF, so
>> >> the connection stays up and makes progress once real data arrives.
>> >> 
>> >> Only tls_sw_read_sock() needs this cap. Its consumers drive the receive
>> >> loop from kernel context -- a work item or service thread holding the
>> >> socket lock across the whole call with no return to userspace -- so an
>> >> unbounded empty-record stream keeps that context and the lock pinned
>> >> for as long as the flood lasts. The cap supplies the return boundary
>> >> that a system call would otherwise provide. tls_sw_splice_read()
>> >> and tls_sw_recvmsg() already have one: they run in the calling task's
>> >> context, reschedule while draining the socket backlog (cond_resched()
>> >> in __release_sock()),
>
> tls_sw_read_sock() would also do that via tls_rx_rec_wait(), no?
>
>> >> and drop the socket lock when the call returns. A
>> >> flood there costs the caller only its own scheduler time, so the cap
>> >> would add nothing.
>> >> 
>> >> Signed-off-by: Chuck Lever <cel@kernel.org>
>> >> ---
>> >>   net/tls/tls_sw.c | 13 +++++++++++++
>> >>   1 file changed, 13 insertions(+)
>> >> 
>> > This is technically a fix, so it might be worthwhile sending it
>> > on its own.
>> 
>> My impression is that the issue this patch addresses is not
>> reachable until the subsequent patches in this series have
>> been applied. Thus I positioned it as a pre-requisite patch
>> in this series, and not as part of the earlier "fixes" series.
>
> It looks to me like a follow-up for 3be28e2c9cd0 ("net/tls: Consume
> empty data records in tls_sw_read_sock()"). Control records only
> become a problem after the rest of the series, but TLS 1.3 empty data
> records would get there with the current code, no?

It sounds like a change in presentation strategy might be
needed: I have the other patches you suggested before but
was planning on submitting them after this series goes in.

But it could be sensible to post those first, along with
1/6 of this series, destined for "net". Thoughts?


-- 
Chuck Lever
