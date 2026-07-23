Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 36E0B38CFFE;
	Thu, 23 Jul 2026 22:05:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784844325; cv=none; b=rSAAfHU72NbWuUbMjOj+6cAD1iyVVz4YAu5C6FT4f4hBsLJVGXZDlXNg6z35ajiVrIlmXNuNnKEqNcw+0ckqRmOV1P8GBirl8Vf9qjAksm3bM2eMJQE9k/KPZRbrDdM9Uu9FYWEfbqEH+/cik1Lfk7/6VO6n4V+CAl9RGWEbbCQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784844325; c=relaxed/simple;
	bh=KMSi59vXSlbpEDk7Z4Wo2L6x6XXJwMmnEmjaGikfZQY=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=B1fhiw0HCIgeS2CKBsMZZtMrUlXA8NO/BkZ4GpJaVVkqgnWMIQtW8eeURtRoh+qZuRsiakmSpucRjUKgK8oZmQhhGB1tyss1CLgR0oTkksZltpTaZRiiDFX7+sUP0lf5j4wQnXUlLTxEgJb6ojnbJJHeB/E+bavzr06CWlkA4go=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net; spf=pass smtp.mailfrom=queasysnail.net; dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b=Ou97u7w/; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=rFgsJsHY; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=queasysnail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=queasysnail.net header.i=@queasysnail.net header.b="Ou97u7w/";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="rFgsJsHY"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id BB5C31D00275;
	Thu, 23 Jul 2026 18:05:19 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Thu, 23 Jul 2026 18:05:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=queasysnail.net;
	 h=cc:cc:content-type:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=fm3; t=1784844319; x=
	1784930719; bh=IgxnXdgI6dZEbDB2iGOyGA56ThzoX6AIFR2BrSSKah8=; b=O
	u97u7w/K+gTx8I5BXzY+hAeuZh/zTC5N3QzqVS7UHvSb1B6lEnzHJRnYqIdW8v4L
	/vsJ1+F8GXNvtRwvnMuE+czgIWJI2g5LZ0knhsCzaOTRfIn5IjvPicb4iYaCPpSf
	h7FitCL2o/LLg0PfZqQs0hKaN8Qxn9sd9ObeKbs3TpLkzpeLnKBitZH3Ti54fDlM
	DwIQVZijF0jwBI/pCFjNC3otsvU3XoZNGOFPGOAIqBdRY5VQ1XllXDSQIyReb2uq
	XkPBJ80aEX/4HH/kvmZhBIY8RQQAY67mMxHGpLxUC10s857yQY/2mKuB9WfOMps/
	0MB1XsE5eRYQghuPp9/Kg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-type:content-type:date:date
	:feedback-id:feedback-id:from:from:in-reply-to:in-reply-to
	:message-id:mime-version:references:reply-to:subject:subject:to
	:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=
	1784844319; x=1784930719; bh=IgxnXdgI6dZEbDB2iGOyGA56ThzoX6AIFR2
	BrSSKah8=; b=rFgsJsHYKkMEvDt03q12OstgPl1t73jA/HNG0m1C8YkUvl++zjj
	sYkt5M1e1fq2rE1bu7oS7MHjyYmBashIebz4JfDyaGjpv6wOMTP4ZyHQjk+he27O
	14cMpXh33p1oH+rjZz93OYrEvlxIvCAoMJQTj+EaCItTo608lac854u4A+9CnsoD
	f2+QtQHTf0BmE+4OsHlGVpNxXf3FfG+enGRY0HXgd5vyAZntigx05aN/hQZlep6z
	XtMT1kEH/W/F+DZCED+LjqagnG9eV/2OEvmrfHgBGrXbZV7XGoyBlGNSa63aRlP3
	WFX3rjlz9YflVHkX06h2eGz0bQhLxC7D/Rw==
X-ME-Sender: <xms:HpBian6W0sUs-f53JnMn0UoOMz2aR_dHAD-GAb9r9WCo_9zr3uimSA>
    <xme:HpBiaraFjU1HIqqkPa8J4NuySWDzgRcTCW8AfmA0isdx1VQ4isVgpHMkF-yiNLz5Y
    xvQZnGZ6BktwzU7eGYxG4Ar55RNXdlOdOHOZ4nOmdZ3YE_x88rqLrs>
X-ME-Received: <xmr:HpBialSOJ7n_T79Yz3m537owniyFYN1L_q1WPOQVpSCbbOkM_K_ptwEaavA>
X-ME-Proxy-Cause: dmFkZTFxIrBP8eFCFTDjPyo2F2C0tvnGNTBqRlwzId+BV0hPrymnk6ayyxVnYbr5ZXIQNo
    NagcGQQT0Srw1e6ihcOuafm2xP3fZEFPpei7PWvqhbO6kQ3dfpTidKAzeQsLQ5+7hj3Lq6
    BHspIBw1iLT7mBKmbE0rCTPO+FIG4dETBhgBldkoSdrO+Ms6M92UJXoUdLCwmLCHEj+LiT
    FZY7KMEVvKPuPL5Q3Tvb5Xxaa7vSXT7/ZAMYc3mmlBTDjBWGkhhn0CYWbx4A7SvrcLyLqt
    lItHZvS7H6d1OROBHlcXXJ+5FNBG326/1GNX01TAiTh68j33KrbzysPLyHdKd1gJR2IyXt
    ky5lKlqdemIL5gAbj4qgi0eaTElHj3klueS7dfT3RZvsqJYVli9PFHKpoOesBL6mk86sOx
    Iy53c+xIVWY1Do2kQ/+zUrJARa8VdI0aZEtpGHdpob2OS+sCkJkNy6wI3oClKXha+Ex2H6
    PDbW//e49NvDpHuq8gjhdtZSWr7eiyhU5TEUu2vPVDXoGvIRoiAMrxdAQG90tmuxP0t9Nz
    TYq73RbwxkLiW39OKEbAR9b0HQVkl11o1WM6FaD8CS5oViTAob3MGGS+a8qmB1RfbU/GcC
    YfW4j22VNlu1OtludlunAVEK3hpzq7hJQ5xn6YoN/5vakezLXYAv4JBlS4UA
X-ME-Proxy: <xmx:HpBiaoJdjT4PHfK3DCRx8jgvF7Q8GJUUVS6qcbJvraUoRTqSJeT1MQ>
    <xmx:HpBiajXaCmSLIPP6TwstYvu6U2nblRbvuJgHBcFOO0l1TD6xUNTXXg>
    <xmx:HpBiasgEv7Ob6EcyteTZFHakcLoF_ykfttBcg6q8nZjXEgZiaSAi5g>
    <xmx:HpBiavu-rd2bHCgr8k9DJB7OCv5EtnYHBf9mxYwdj9qXjXVFPDpK2g>
    <xmx:H5BiarQX2rmPo5D_irklZ_SlXZHNi4CIOWEBpk7TeRMVnHjAM8A8Vf_4>
Feedback-ID: i934648bf:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 23 Jul 2026 18:05:17 -0400 (EDT)
Date: Fri, 24 Jul 2026 00:05:15 +0200
From: Sabrina Dubroca <sd@queasysnail.net>
To: Chuck Lever <cel@kernel.org>
Cc: Hannes Reinecke <hare@suse.de>, Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>,
	John Fastabend <john.fastabend@gmail.com>,
	Shuah Khan <shuah@kernel.org>, Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	netdev@vger.kernel.org, kernel-tls-handshake@lists.linux.dev,
	linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v2 1/6] net/tls: Bound consecutive no-data
 records in tls_sw_read_sock()
Message-ID: <amKQGyH41zom7LGe@krikkit>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-1-29545d034f3c@kernel.org>
 <b9d60674-1ba7-4f23-beee-4ddfffd4dda9@suse.de>
 <909e0132-5c0c-4c0c-b8c5-b90b88ad0231@app.fastmail.com>
 <amIj_DG7SuWx8MeY@krikkit>
 <7a0f5521-3a44-4e8e-9a30-542b0ece448d@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <7a0f5521-3a44-4e8e-9a30-542b0ece448d@app.fastmail.com>

2026-07-23, 10:29:55 -0400, Chuck Lever wrote:
> 
> 
> On Thu, Jul 23, 2026, at 10:23 AM, Sabrina Dubroca wrote:
> > 2026-07-23, 09:24:47 -0400, Chuck Lever wrote:
> >> 
> >> 
> >> On Thu, Jul 23, 2026, at 3:11 AM, Hannes Reinecke wrote:
> >> > On 7/20/26 4:27 PM, Chuck Lever wrote:
> >> >> A record that delivers no payload -- an empty TLS 1.3 data record
> >> >> today, a control record once read_sock_rectype() lands -- leaves
> >> >> tls_sw_read_sock() in its loop without advancing the caller's read
> >> >> descriptor. A peer that streams such records keeps the receive loop
> >> >> running, and the socket lock held, for as long as the records
> >> >> arrive.
> >> >> 
> >> >> Cap the number of consecutive no-data records consumed per call. The
> >> >> count resets on any record that delivers bytes, so a normal stream
> >> >> is unaffected; a peer supplying only empty records is bounded to
> >> >> TLS_RX_NODATA_LIMIT iterations before the call returns 0. read_sock
> >
> > Would a time-based limit be "better" than a packet count? For example
> > that's what net_rx_action() (net/core/dev.c) does.
> >
> >
> >> >> consumers treat that as "no progress, re-poll" rather than EOF, so
> >> >> the connection stays up and makes progress once real data arrives.
> >> >> 
> >> >> Only tls_sw_read_sock() needs this cap. Its consumers drive the receive
> >> >> loop from kernel context -- a work item or service thread holding the
> >> >> socket lock across the whole call with no return to userspace -- so an
> >> >> unbounded empty-record stream keeps that context and the lock pinned
> >> >> for as long as the flood lasts. The cap supplies the return boundary
> >> >> that a system call would otherwise provide. tls_sw_splice_read()
> >> >> and tls_sw_recvmsg() already have one: they run in the calling task's
> >> >> context, reschedule while draining the socket backlog (cond_resched()
> >> >> in __release_sock()),
> >
> > tls_sw_read_sock() would also do that via tls_rx_rec_wait(), no?
> >
> >> >> and drop the socket lock when the call returns. A
> >> >> flood there costs the caller only its own scheduler time, so the cap
> >> >> would add nothing.
> >> >> 
> >> >> Signed-off-by: Chuck Lever <cel@kernel.org>
> >> >> ---
> >> >>   net/tls/tls_sw.c | 13 +++++++++++++
> >> >>   1 file changed, 13 insertions(+)
> >> >> 
> >> > This is technically a fix, so it might be worthwhile sending it
> >> > on its own.
> >> 
> >> My impression is that the issue this patch addresses is not
> >> reachable until the subsequent patches in this series have
> >> been applied. Thus I positioned it as a pre-requisite patch
> >> in this series, and not as part of the earlier "fixes" series.
> >
> > It looks to me like a follow-up for 3be28e2c9cd0 ("net/tls: Consume
> > empty data records in tls_sw_read_sock()"). Control records only
> > become a problem after the rest of the series, but TLS 1.3 empty data
> > records would get there with the current code, no?
> 
> It sounds like a change in presentation strategy might be
> needed: I have the other patches you suggested before but
> was planning on submitting them after this series goes in.
> 
> But it could be sensible to post those first, along with
> 1/6 of this series, destined for "net". Thoughts?

That makes sense. 2..6/6 from this series can still be around for
review (maybe with a [RFC] prefix if you resend the net-next patches
before net gets merged into net-next, to help the maintainers by
avoiding conflicts).

-- 
Sabrina
