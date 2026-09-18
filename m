Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27287313523
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 12:52:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789735969; cv=none; b=NbLD0yKfSUiotJmr3vpqI/6Ctvh4wIO3b14TqCzmkkgyOHZuSKduXScCF5Yl2HEE9DECQwN3CieShzKJiUgTEXReM06NbQQBrr+nZ9jCOD4lbdIZr9IXzutt3Tl/ZOYXerBwF1X9hYXqNunHv1+yjaMs/seWiPGF5WPdOFMgEoc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789735969; c=relaxed/simple;
	bh=URL5OVHpVZmJeSxZOa6qP69E2VQXQ72G81+v0ms+TiQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=et60kHfvawcsgVfPdpLgAEqX2zO3RzW9tIi8fbRTF/MLc3Y169CgeU21JSb3uHxne/ljRw1nJRx4sWxpkWxN/A3M0GjWl3I3LmP9+qK2ofEhv/M9ZOmwcghSlrdDjo+fRVnQ3RrSF9Aj2NrmT/0ZJ71n/iSAqik+7KRg/WQOZz8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JGkleZ/X; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JGkleZ/X"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5B9D81F0089A
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 12:52:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789735965;
	bh=URL5OVHpVZmJeSxZOa6qP69E2VQXQ72G81+v0ms+TiQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=JGkleZ/XAhcExzcKZYi+/mjkmIUpIz7ElmkzDgJx4CsNxWHyEjCmMZYPHzZR42/L1
	 b5RYJH4UGPjJnpZXK6W8pzvPo+v/PK/7jtfJaXnTKxjUgdQHkYCx7DoHkpnGC6uK3D
	 ae17+c+gbueBcmUUX4ruz4UZWFkzqCOVee5dXOJnlW1MNrDD4yj44h0MbMk85mSxmw
	 R1z1rbeZMkJgCLX+Ui0oQ5/a4ipfKl70ybCtC5qD7UUKu108ykC3Tw/Tk2TRVOL2X6
	 okk6yUCZHNSs6U0LkKvTq8tu/2e+RntE+waOoGGxT9BnoJPceENrakgp0v3rZN1d62
	 L60yoquFc5TXQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 75E0EF40066;
	Fri, 18 Sep 2026 08:52:44 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 18 Sep 2026 08:52:44 -0400
X-ME-Sender: <xms:HDStaren-s3mEd_C4H-zlsIV7JEzMAWsNt0EWptDbCnevV-pUJ_weA>
    <xme:HDStasCmqhBZxfbT5fMCOzd8ZQICQjPEnR5TVCHaGzkkxB37RwDMoZXuc4aiznTKy
    ouBiT5nxmiywQY_RVt4rDKO1EfYJJOMFM6YTS0VqpzqJT8b6IUrgfFN>
X-ME-Proxy-Cause: dmFkZTE33gkw3iy7iQIBCYo/4ICHCmC2a6ZnNhVNSgX+77E2Uj/vrbLC26dFdd/ArqndTg
    18tA+eunGD5VmfGGlJsxv59olllHR07FZNc3vw2mLaXz+nQ67UeJeidhrUUyNBO55TmjC5
    KriJMJE8kUsxN4SAWbdC/G1fukpWQ8unoeojVJgtd1S9dYwELM/e7JyM4K1eHTgNcdBs9V
    52JO6rS5Yx6+dT7jjEIhLlMfkhqEerhk+CQ1qd4RJrfcqoEVGY8tuNbwhTnZu0WwSfoAch
    76OZjH5gAiEI1IS8DfLQXk2GnMjcA5T8FpYzh8Q867ci9Rw4Obhj2fgQi4/J1uX2o+kuK+
    A8KHlAKLsFhm0xZGCcF1swPp1pOw7kY3dIHj+QSCte1x5VZLKLiV4NOVYzRCDzbnu7sccH
    VmMnbRvo5Hzn9qsDAk/sCiPGlsElurIXIbUB4cL0/HgpUJK7/aKF8IBM7RUrtAZtvT3NCl
    YXZNIz/A9SONwdQtYIkZG2SxX5tLLhsdtJKLYw3m3SjsJiaQz14eCWwm0iIjmuXlbD+z8a
    Xxa1KfnQyh/QtZWrbljpOxWJktNwhY6dOHq+TUIt0hyOS9Hvu4QhUCaWQLkBIsoJkt+pSU
    zHgLE5qoPdGVZOivcNXsWXXCxLII0x07Prj9bSOCULKTsgClyNXANxctlMew
X-ME-Proxy: <xmx:HDStanB6YYkI6hbuTGcK5Qe6mH2txNhmFslQE2VTFJQhu9MIKnPorQ>
    <xmx:HDStatpCUxyKrL-xL6K03kxspFiMWzxFQ6P_NgEFJpl6TUOWGh0hNg>
    <xmx:HDStaqhcTvhbVdkzBWQUPipFPLZqKeyLQpouoQwPflVsRkEShMZ9nQ>
    <xmx:HDStaiAkq56nvhGkte7O1T85C4nBLKBiJa2kUQUsXhguLHpVOT-dDQ>
    <xmx:HDStanEvvcxnymQyPheDXK_z1uKVUMW8PEufV3S8Ix3iuciPRXbLXGvD>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5770A780070; Fri, 18 Sep 2026 08:52:44 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AMlZhD_SRtH7
Date: Fri, 18 Sep 2026 08:52:17 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Sirisha Mylavarapu (she/her)" <smylavarapu@everpuredata.com>,
 linux-nfs@vger.kernel.org
Cc: cgroups@vger.kernel.org
Message-Id: <b5fbd385-383c-4497-a927-b86565dac9c9@app.fastmail.com>
In-Reply-To: 
 <CABc6Dy5mvvCSECx2z+-L1q6FpQGO_hQfoLaS6vtpWVud6+8zbA@mail.gmail.com>
References: 
 <CABc6Dy5mvvCSECx2z+-L1q6FpQGO_hQfoLaS6vtpWVud6+8zbA@mail.gmail.com>
Subject: Re: cgroup v2 io.max throttling works for NFSd reads but not writes
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Wed, Sep 16, 2026, at 2:59 AM, Sirisha Mylavarapu (she/her) wrote:
> Hi,
>
> I have been experimenting with cgroup v2 io.max throttling for NFSd on
> kernel 7.0.0-14-generic (Ubuntu 26.04) and I wanted to share results
> and ask for recommendations.
>
> Goal: Throttle NFS server I/O bandwidth using cgroup v2 io.max by
> placing nfsd kernel threads in a dedicated cgroup, to limit block
> device I/O performed by the NFS server.
>
> Setup:
>
> -NFSd direct I/O mode enabled via debugfs (io_cache_read=3D2, io_cache=
_write=3D2).
> -All 16 [nfsd] kernel threads moved to a dedicated cgroup
> (system.slice/nfsd.slice)
> -io.max throttle set to 50 MB/s on underlying block device (sdb,64GB
> disk, major:minor 8:16).
> -NFS export mounted locally via loopback for testing.
> -fio used for benchmarks
>
>
> Results:
> Read throttling works as expected, consistently capped at 50 MB/s.
> Write throttling doesn't work regardless of io_cache_write mode(tried
> DIRECT=3D2 and DONTCACHE=3D1).
>
> Root cause (as I understand it): The NFS client buffers writes in the
> local page cache and returns immediately to the application. The
> actual disk write happens asynchronously, so the application never
> waits for data to reach disk =E2=80=94 meaning the throttle does not p=
rovide
> backpressure to the writer even when the nfsd cgroup's io.max is
> active.
>
> Questions:
> 1. Is NFSd write throttling via cgroup v2 io.max a known limitation?
> Is there active upstream work to address this?
> 2. Are there any known workarounds or recommended approaches to
> achieve NFS write I/O throttling at the server side?
>
> Any pointers to upstream patches or LKML threads would be appreciated.

I have a to-do to look at constraining memory consumption with
cgroups, but nothing involving I/O bandwidth. As far as I am
aware, you are now the owner of this topic.


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
