Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83EEA34FF41;
	Wed, 29 Jul 2026 02:17:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785291446; cv=none; b=SDPhEykJ5jCpuz/aaEiN9A3WNQc1x7ntAFx6qnTLVRxZ2UUVy3RiuQP5LC3hSqRCbmzhEMBY/NSx4L906IuisGZ3DJ7Ra0gNCRsryJMOSW+4OOiqe+iyH5Mtj0QXPo6fqhpXYixLLnR/XjgEwvg1LtbfXCqrNpGbb8hZaw+P2RQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785291446; c=relaxed/simple;
	bh=sL7uEii46aZa/DuhKhjvvQM+++2aKRBpUNaVwI+lhRA=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=kIfq0xKbqXHY9OGGaYg6n/4v/MRCvZY2h3i9cVZeyKZcbSIeBxsXBRMA6U1ZYVqAB7B9XlJ/JDI/TfihTiOOrGhYUAwbdov+ncOP/Vq6mBqHPWuxzF+8627Vbgk+VtYyDDQNSE0lqTh7Y3o9tge66/tZAOh9Ssl4kBj23sFwiKA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Gn3jRjGK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Gn3jRjGK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9A2E51F000E9;
	Wed, 29 Jul 2026 02:17:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785291444;
	bh=ohGdf4SsIOy1tOkYFpwNx4CjmKI2b8KyKl09C3+1xvs=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Gn3jRjGKo3d1MNcbOpkThs288kp2HY+OjGSm3tqg9aePYclXf1U4nMUD+GUpXq105
	 ArlM8DI/1/D7VgNlX/X54voi4r5pQPbeUO9NibwkptQzHM9WUecN4QdtQ+DK4w0hEF
	 kKSL4PiYO/9xhnTddqIrU3LaJAz/+FRrNVoAdAXstz6EwzTPBhx1G7T+5yQlGzDMG2
	 2TRv1IKTBD+G/fldbi39er7KUWv6Hsd3kt6qoc3coa95iA50JwOGsK6dTjH0qVGlFw
	 faG4bheG1CkgqMjCfhyVLNv+ocRqKZiwsHziwyKJjf6FHmLPyuiJszUqddzHmB0QI5
	 3kX4wlkBX0l8Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 96380F40073;
	Tue, 28 Jul 2026 22:17:22 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 28 Jul 2026 22:17:22 -0400
X-ME-Sender: <xms:smJpagYP0gGPmTiIuOpJQp2qbKOy-YtQMAUd02hRexWumlb0fXnPbg>
    <xme:smJpamOdBmmii3n7hTsNMTCUPv2CvpL2csI14JVJjwZk6lrM4779zLSKrIpCDD8KC
    bc4UABqUIMvfNjDQF34DoM5RQptFZ44p6yHLHidQcuZsIXSDc2HEfH6>
X-ME-Proxy-Cause: dmFkZTEe1jOODYsShCXVfQy/nOkZsIcM8Rt2KW/XfCg9CCgU8BG9srNc3TQOk51b/a5NEq
    7Z7LS6l71u6Ynzxybrr5l2QzZUtpk/SZQGIwg38Ql4F0FbNpqyRWi9ZunzlOIuZnFW0aHf
    neey4UkPIcRYAd1rh3nJIqd7cYX866r0BorSBZjt/Psepqyd5sGnpRUyZFnI/KRcoh+Htr
    vfRdC8uATRZQ/ZmUCoKg0oHCza5LrQWI7jQT2IFBAxMDmryNP8XOUCdVNmkharoDfF8jxT
    m6tkKDwdSwUC4WtERIS/MmswNSiBdgAZ5XInzB9VYMQ84DDUVqrD6TSxNoIeRjTz5YVkIz
    fIm2gkL+Qgpx8f5068eARi0lLPEglLem5ieOcDuIjd6KBBNlsW9ibXMhImERgBOuymaxte
    T6Ev5d0M9vg6yFUszhPxqc/m6Jb92XbWM7+VEAkEjHfT6Bj6UCzRwbzyAleGIhvF5dkoI/
    XuNStiBV88qD4Tz+PXevwbMK8o4hzuUg0ZslNLlauF2Bertt1d63kXZCjBXCWUyd0GCeiB
    121/oH3mBUd7JaYyoAEB7NqRuq/+9SPke/sT2my8vcytHcA9fiUlBh2dTgGOrZa9pFkhCO
    4NGrdL6pJRT3biRHtO4hJODbuxbXUsYTVYanvZeIhr8LYJ3hkOQZqtbnq45Q
X-ME-Proxy: <xmx:smJpaqTZcc_FPPimhtcxaS89k-BD-mFx6UKEcmjf57r5RMNKdPV09A>
    <xmx:smJpanXSxM4NMCsT4xomCL0TgqGT6Vf216hdle4pNlKfjYUuK94qag>
    <xmx:smJpanfEaXM6JXv1J9hD0kPqbZDmL-eZw8V1jgwbo-z11XHEHod6TA>
    <xmx:smJpaizw8i0ZPCrIqZtYvgXTPnHl4tnw2cLe4T8rhBKk4pu43SoGxQ>
    <xmx:smJpaqFSGXluW9qbLQ_WCZt118tP1N3f9WcqYvDGMSW2HXZMGFIjwTaw>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 64E51780070; Tue, 28 Jul 2026 22:17:22 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Tue, 28 Jul 2026 22:16:22 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jakub Kicinski" <kuba@kernel.org>
Cc: "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>,
 "Sabrina Dubroca" <sd@queasysnail.net>, "Shuah Khan" <shuah@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Message-Id: <0e1f1b09-fa91-4a6b-b60c-39bae6e287a6@app.fastmail.com>
In-Reply-To: <20260728185525.27b443a9@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260728184312.20b21582@kernel.org>
 <97b61f5f-57df-4a29-85a0-613f7b7e75eb@app.fastmail.com>
 <20260728185525.27b443a9@kernel.org>
Subject: Re: [PATCH net-next v2 0/6] Deliver TLS control records to kernel read_sock
 consumers
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Tue, Jul 28, 2026, at 9:55 PM, Jakub Kicinski wrote:
> On Tue, 28 Jul 2026 21:46:57 -0400 Chuck Lever wrote:
>> On Tue, Jul 28, 2026, at 9:43 PM, Jakub Kicinski wrote:
>> > On Mon, 20 Jul 2026 10:27:54 -0400 Chuck Lever wrote: =20
>> >> - The no-data cap (patch 1) is a prerequisite, not a stand-alone f=
ix.
>> >>   Once control records reach read_sock, a record carrying no paylo=
ad
>> >>   stops advancing the caller's read descriptor, so a peer streaming
>> >>   such records would pin the socket lock and the kernel receive
>> >>   context for as long as the flood lasts. Bounding consecutive
>> >>   no-data records supplies the return boundary a system call would
>> >>   otherwise provide. The cap is scoped to tls_sw_read_sock() alone:
>> >>   splice and recvmsg run in the caller's own context, reschedule, =
and
>> >>   drop the lock on return, so they need nothing. =20
>> >
>> > Is it just me or this is incomprehensible slop? Run on sentences=20
>> > full of terms no kernel developer would use? =20
>>=20
>> It makes sense to me. Which terms do you have trouble with?
>>=20
>> Patch 1 is moving to a pre-requisite series, so this can be dropped
>> from the cover letter.
>
> Did you write this? If not what model did you use?

I did not write this text. It was written with Opus 5 and reviewed by
gpt-5.6, sashiko (gemini), and myself, repeatedly.

I=E2=80=99m not aware of a requirement to add an AI-related tag to a ser=
ies
cover letter, nor am I aware of any a priori prohibition against
using assistance when composing one.

I agree it needlessly duplicates content from the patch commit messages.
It is bland, but I don=E2=80=99t find it nonsensical, or I wouldn=E2=80=99=
t have posted
it for review.


--=20
Chuck Lever
