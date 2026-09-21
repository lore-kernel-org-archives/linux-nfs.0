Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 189844E01E0;
	Mon, 21 Sep 2026 18:20:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790014846; cv=none; b=DaEC3lJJc82oFWqJw3mnAfabhHxwWNxBZkmHix5Dfrzi6Qf8sJmkDaN+Vl4GoaayNOF8oIbB7XN0jmTBKO3fWogKO1M54mwmG61dUO1F7ippEEstRkXZ/lIE2vfKxwVm9v4Zl1UWjyeZisIpbzU3drRdYXRKbwAmCr2nxn/n1C0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790014846; c=relaxed/simple;
	bh=ifh18PFLwUc4WCVqv2bBQrWNPjGyex+455kxpBAX05w=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=OiHX3+mkzKM/D+9ru2nwUf9LcRPa5FbGg7eGk5Dmes7jjHU0jQIX0HFhSo4K1reVDm9MpcUtXxcQd5ff++qIAFZUW04mxoKYQVTIBx9HdVNWIKJXjhaYR4Vj5O0BcCzNX+Vuy9MfXkz4AZXJFbdsT2LkjLf9FwKei3iwY1ssFZw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lroddLYu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lroddLYu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 635411F00893;
	Mon, 21 Sep 2026 18:20:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790014844;
	bh=N0Tv6GtH2poAXrq2dIuS3JYXFBy+lolP4AzgrJRISDw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=lroddLYucoDSkSHjPVrg8A7BG4sD+XAjet1Py2MB6kzG830oTg+mVMGjhBkB2P/ah
	 q6TZid1x19ub82H0bVOdua5GhsjsLjAceGq8nIO+AVxsXydnVshOy7YRN03VGMNnGn
	 RqG7QmeEO4GM5QrgX0G0yXL8o+zQh/pNQWFBLTFdDV+3bjpx4DzOjizYGmaImipsvU
	 KWBPEtXuWfcGabMqaRet5T5D72MsqXYCBOlWNVYT8lfhOIHgWix4rlUMaO5Ox/pi+m
	 zM8seh5+8m1a+5B9UATXe1D1yjkLJD7D0OTEgPnUgbQvV6ol2RGvoZdDx1xbdpJHBk
	 ZL45y+tEh4vgg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6D26BF4006A;
	Mon, 21 Sep 2026 14:20:43 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 21 Sep 2026 14:20:43 -0400
X-ME-Sender: <xms:e3WxaiVteI8Brz-90pXijnDlZi5r1GzzrrA3wLDtYP43uM_ifyI7oA>
    <xme:e3WxapaKANhexH-YsWSPhkc67c0TrKBtQDHl4G0M13Pqg97_RIPLjfYrw723f6AYQ
    qOTqk6KRBV9fqrr2wBMocnYKf9Nj5gGMmwXfrXEy0QN6TMxO27hiJQ>
X-ME-Proxy-Cause: dmFkZTGw5IEz9ggBveE4LY+gshD7KmdQ9CNoGOIiAKUXwQdPUcbM2DfqLEN4kMN2ftK/3K
    ITJ2vDxLVOVTzhDlQ1NOzhzqdJiRFu9/zIaBAMhqhI3pzJWClerUy92+Lu3dKeEsPbQVpD
    cigEtx//snUetUjF2Z4fYwLPGJB+wbCKwNFDGZsJ47KbIMNgQA7uvi7xQrlgFG6rJbd4HE
    uX5jlWyCZr/D3uCxOmkLUiqKU0Bfm6BrzGiKnGj9N9qGdWdHSOWfgfNLMtYy+0l+k1yWI7
    WXpNCwJyOREMa39gvhr+qWdtLAdnTLv07WVQK2DsBKj+pGcF9Hzm3b5mep9OU5sbCqiunw
    q5h84pmgBUySL8KNwxuj0b0jEz5ndWjl9mkhyABQWjtulwxNstRe8dvXuYNQBxdOVgnfZZ
    LXrs7uWf+FQWUevVsoVS2mHI47zmxhiNMeN1PVwfuIXKVY+qW3dD9/qRH3lD4UrNrHkM2Z
    OlqhyD3DfNbJgILYZ+sC7kn2HqzPXffDRE8Fyg1aQXYqWXY3PrC8thwYdeo5aeWYFyE7NT
    tNqG9Yg8ntwuaJR8HwVYBJ5ZSWowTMX36RhFVh430xHhhi4dlWzN3yieFBpNzbyJnmS7ge
    bNZkIykOrt0/XX4NTIC/ZMrws1g8WhxFjPQGjx16jJTd13ZhV5L8mrX4tGJQ
X-ME-Proxy: <xmx:e3WxatXZdaR4PO0JrKtf_WGvOtmU7Yy5FQW-W7FCdL4JDXswufXrJw>
    <xmx:e3WxaqIEC-bS5lhJhwnKbwgJcxcR4t5oyV1EYJBqQ2FrvEoUCpvZxA>
    <xmx:e3Wxat292A2buvQesPqWbfpV47wP_4XOCfi9p81JMMZqBpnvs33zJA>
    <xmx:e3WxanJmDn7mWfQ7EK3Aek35XHLctu6XF7cx-TrOQhk3Ats-zohrSQ>
    <xmx:e3WxaojiYUWHXk-DAQjqTpQohexXwLXyHkwWuXImohcgkYurygU7MbtJ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 4A898780075; Mon, 21 Sep 2026 14:20:43 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AYcrnN9msr83
Date: Mon, 21 Sep 2026 14:20:14 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Shuah Khan" <shuah@kernel.org>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org
Message-Id: <bc472084-1e3e-40bb-aade-6fd7aefaed4b@slotpi15m67>
In-Reply-To: <20260921-nfsd-per-net-mutex-v1-8-4a7287f6504c@kernel.org>
References: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
 <20260921-nfsd-per-net-mutex-v1-8-4a7287f6504c@kernel.org>
Subject: Re: [PATCH 8/8] selftests/nfsd: add a cross-namespace control-plane soak
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, Sep 21, 2026, Jeff Layton wrote:
> ---
>  tools/testing/selftests/nfsd/Makefile             |   1 +
>  tools/testing/selftests/nfsd/config               |   6 +
>  tools/testing/selftests/nfsd/nfsd_netns_isolation | Bin 0 -> 49192 bytes
>  tools/testing/selftests/nfsd/nfsd_netns_stress    | Bin 0 -> 39232 bytes
>  tools/testing/selftests/nfsd/nfsd_netns_stress.c  | 572 ++++++++++++++++++++++
>  tools/testing/selftests/nfsd/settings             |   2 +-
>  6 files changed, 580 insertions(+), 1 deletion(-)

Hi Jeff,

Did you intend to commit the nfsd_netns_isolation and nfsd_netns_stress
binaries?


> diff --git a/tools/testing/selftests/nfsd/Makefile b/tools/testing/selftests/nfsd/Makefile
> index 2b7c44c3fb00..b29bf642c0ad 100644
> --- a/tools/testing/selftests/nfsd/Makefile
> +++ b/tools/testing/selftests/nfsd/Makefile
> @@ -3,5 +3,6 @@ CFLAGS += $(KHDR_INCLUDES) -Wall
>
>  TEST_GEN_PROGS := nfsd_netlink_listener
>  TEST_GEN_PROGS += nfsd_netns_isolation
> +TEST_GEN_PROGS += nfsd_netns_stress
>
>  include ../lib.mk

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
