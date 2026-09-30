Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05B2B1A5B9E
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 00:20:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790727626; cv=none; b=kKRXXyG9RJh2fkCpuBr3jUah1k4NIcr/COjoFirz6nINYGSHSOku8AKvNpZXdJIiK4awm9vi+an6tFYsbypGiL5w9HgWhjTv5HSteukvh1XeXa0pcVE01iEpdhqaParo2cxKUrXGqY6ecdVNv8SqoX2qjmLHN4bV1MQdEgnYY0M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790727626; c=relaxed/simple;
	bh=SA11+Q6yr4xhilax30AcEnQ+Eb2nasWDSii+t1WjGVg=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=AD/JjIRHrddN2o1VWkTeKEWIwRjRU1ldNRsy0zPckqR9xNjhGj3Uxj9r5Ex6yZgqjslaKNFJHKaEHM6AG51xofT6TWSk9/0YXZ0TfYU94vKa397hvG/ZTm1rrhYmoCYu0qqBiZIUq1cZ6Lm0YTAX+QSKlDxxI/SGMKMRGwRPKCk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=WI2ddwxi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="WI2ddwxi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A18EB1F0089B;
	Wed, 30 Sep 2026 00:20:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790727624;
	bh=qI6QF1aZb87FNxJ33k/tHZURvTsc6s0zYRP6Od/xvxQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=WI2ddwxi6sbtZn9mHYmCiCN7Pet6xD9+sKSzxM/Pp20NzZ6WsJDjyOj/9jnZiP/+D
	 xwR9zU3GGP4G3LtEjA/rhUVgMM4zzZ79Xl5SSeali+6fLwO20sHgO9BSjlBYE2FSGm
	 0IHEzzLhQS2SUU3+sXZMhao8HGD7KKQm3F34g0u/kx/ecKRdTW5MNgD2URDuVPHgNZ
	 cdrAWBP0BpE1a7SYHPe0C9lP3/vAk1MffDPWqN02JkQU7UslSRs1pL64CPw/ENThxd
	 f25uYc/8wTUpYRLWJFI01mUAVdK5hjw44M0Ctxtl20YsAzSLZxTmUgDpG5nCanA6V8
	 pywdP5GS9sbdA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id C64B1F40067;
	Tue, 29 Sep 2026 20:20:23 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 29 Sep 2026 20:20:23 -0400
X-ME-Sender: <xms:x1W8ajCQZo75fDANH-6ILHrhJNmaNtOvym4ogPhQsqcVlReoRV5EnA>
    <xme:x1W8akVYBS_gZkiIEhVo03YxxmPi24_BMLKJwhXVI3jJGKGJqPtRdhwIAM_M4M0-i
    Ai4BUI8GDyAV4_VlxVfbnRoY4I1Dc6xOPdXo3G5gnnUKdjZ-X5aC1c>
X-ME-Proxy-Cause: dmFkZTFnaMMD689rnSHOBeaYPceOLo3FFLbE+dhWlp+VBjJahtvja2J6PDtG91Ula5SURW
    ZU0qUTa7gi7betP33eQjDX606nzQJFr11InXl5Ox02C1VxMg3H2yK8iENbT6P88tLgtvnX
    JFJfl6rWvHQIxAv77bCeFF2anBY8l5rG3FcEq1lUfKalMFaC6dR7sp241Oy8NX7a6MqsZ6
    NcHJJLnKAMwLanw+gIHgTqh+puaRIR5htZeq04hf8SEIj7yubFyBlU8yDebD8PR/PK7RFr
    L9sE3vDAuuWKBeW+J+43EIztpnU6GadSRXp6BCsCMjmvxCZ3Sovc/cBCgsy7gG3JYD03Yg
    hgYONqQDv0a6jkHKiqsNOGacvpt/YqE194JIAtVaYebh8vRrmhh3/ozxbCIfLFPGyh7sqK
    1V776og9T78DL3CThRHHyHa0eXqg3yvn1dSMOLId1B0/HFflXBPYr4rMG59iD55CHN2+0w
    ns/HaynJVJdEoRNW3XJ2VAYe1QBFMCwso2kQPxzK/BWxuMCR5AjI3HwPgDiRwOy19JT4cO
    HVZ38irwUB4X+bdPxyoI0vkJzantAyTsjkdueM0mIv4b1MJaaFLX8ttzv5euUJI8d0cveb
    R9bIC2X3ONuusOvDA1hhmuO83tJhrjMk62fvtcSBVzt1HCW2+E30LDE+qerg
X-ME-Proxy: <xmx:x1W8atoaZePwbycCI4V5uGML5ycfizeW7zX7llx93Zq8XIlsw-Wriw>
    <xmx:x1W8atdYRE7IzvnCuhk7ar2ZW5qna3lMnauBkbgEHKLgmqKYAKXWPg>
    <xmx:x1W8akozYMDtomIxBGzxspnRZEYvueRrenbVRXwrN5Bf7XHLQdg_Hg>
    <xmx:x1W8amGg2BlPeOjkDB1R80kTDYufMsYyMzb7ixvxGodyEGqKxM2xbA>
    <xmx:x1W8asuCqiDJim1LIcRHsS05HvBV_LGny4kkarolo-_ir5a3_ErLdg-H>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 98BAF780070; Tue, 29 Sep 2026 20:20:23 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A77Ixbv5qpj3
Date: Tue, 29 Sep 2026 17:20:03 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>
Cc: "Mike Snitzer" <snitzer@hammerspace.com>,
 "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Message-Id: <0cbfd399-45cd-4df2-888a-bdf8a2935ab0@app.fastmail.com>
In-Reply-To: <arxKM8RkjwYaPzwL@kernel.org>
References: <20260929173423.16149-1-snitzer@kernel.org>
 <20260929173423.16149-2-snitzer@kernel.org>
 <37625d4e-9d86-4651-bbc8-73c1c589942d@app.fastmail.com>
 <arwYBaemyvLoG2sT@hammerspace.com>
 <d5d7635a-fe7a-4664-8797-b581c23cdf9c@app.fastmail.com>
 <arxKM8RkjwYaPzwL@kernel.org>
Subject: Re: [PATCH 01/10] NFSD: interlock the use of NFSD_IO_DIRECT for NFS READ and
 WRITE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Sep 29, 2026, at 4:30 PM, Mike Snitzer wrote:
> On Tue, Sep 29, 2026 at 04:17:50PM -0700, Chuck Lever wrote:
>> 
>> 
>> On Tue, Sep 29, 2026, at 12:56 PM, Mike Snitzer wrote:
>> > On Tue, Sep 29, 2026 at 11:27:05AM -0700, Chuck Lever wrote:
>> >> 
>> >> On Tue, Sep 29, 2026, at 10:34 AM, Mike Snitzer wrote:
>> >> > Now that NFSD supports NFSD_IO_DIRECT for both READ and WRITE it is
>> >> > much safer to avoid needless buffered vs direct contention if/when
>> >> > only one of them has been configured to use NFSD_IO_DIRECT.
>> >> >
>> >> > Mixing direct and buffered I/O to the same file causes needless page
>> >> > cache invalidation and writeback, so although io_cache_read and
>> >> > io_cache_write remain separate interfaces, writing either one adjusts
>> >> > the other so that READ and WRITE are never left on opposite sides of
>> >> > the buffered/direct divide:
>> >> 
>> >> Jeff and I have been discussing making DIRECT the default for WRITEs and
>> >> BUFFERED the default for READs. This patch takes us in the opposite
>> >> direction.
>> >> 
>> >> Nothing here convinces me that mixing the modes is a bad thing to do.
>> >> "Needless page cache invalidation" needs some demonstration, and it
>> >> needs to show why the right thing to do is make it impossible to mix
>> >> modes rather than explore the issue as one or more bugs that can be
>> >> fixed. Or... why not let admins explore this for themselves? Where is
>> >> the hazard and why does it need to be forbidden by the admin UI?
>> >
>> > The basis for the interlock is that O_DIRECT mode is intended to avoid
>> > bloating memory with page cache and the excess CPU burn of managing
>> > the page cache.  Using read caching in conjunction with O_DIRECT
>> > writes knee-caps the wins of O_DIRECT.
>> 
>> Jeff and I have never seen that, and it's a counterintuitive result.
>> Buffered READ with DIRECT WRITE seems to work very well and the server
>> is easily capable of managing the page cache in this case, since
>> reclaiming a clean page doesn't mean having to flush dirty data.
>> Evicting clean pages is not slow.
>> 
>> So I'd like to see a quantification of the penalties in this mixed
>> mode before adjudicating it as a hazard. That is, you might be right,
>> but so far I've seen no direct evidence that having a substantial page
>> cache presence is a general deficit for WRITEs. If there are certain
>> cases where even caching READs is a problem, then by all means, set the
>> READ IO mode to DIRECT too in those cases.
>> 
>> I don't see this as an argument for forcing the server's mode setting
>> in every case.
>
> Yes, I understand and I've dropped the interlock patch in v2 (just posted).

Please give reviewers a chance to digest and review, as requested in
Documentation/filesystems/nfs/nfsd-maintainer-entry-profile.rst :

"As always, please avoid reposting series revisions more than once
 every 24 hours."

Trust me, it saves a lot of confusion.


>> Based on this description, it seems to me the client has full visibility
>> of the data to be pushed back and how it's sharded, it has information
>> about the network RTT (that's where the real throughput impact is for
>> COMMIT), and it has control over the selection of UNSTABLE vs. FILE_SYNC.
>> 
>> The problem here might be that when a large WRITE payload is sharded
>> across multiple servers, the client still thinks it is sending them via
>> UNSTABLE WRITES to one server, and plans for only one COMMIT after the
>> server completes the WRITEs.
>> 
>> But for the pNFS scenario, the client sends one UNSTABLE WRITE followed
>> by a COMMIT to each server. If the sharded WRITES are all single RPCs
>> to distinct servers, then they should each be FILE_SYNC.
>> 
>> The client can be smarter about how it writes data back to multiple
>> servers, can't it?
>
> When the server is operating in direct mode it isn't something exposed
> to the client.  That the client could be smarter and/or already has
> adequate controls to achieve the same FILE_SYNC result is besides the
> point.  The point is, if the server has already done the work then it
> should, within reason, convey as much back to the client to elide
> COMMIT work that isn't needed.

Your point assumes the other patches in the series are applied to make
DIRECT UNSTABLE WRITEs completely persistent.

The current IOCB flags do not include IOCB_DSYNC on a DIRECT UNSTABLE
WRITE for a very good reason: that makes them slower and more expensive.
The current server logic is working exactly as we designed it last year,
and I'm not enthusiastic about changing that. I expect at least one
other reviewer will have a similar reaction, once he sobers up from
ALPSS.

If the client wants to avoid the COMMIT, the standing rule is to send a
FILE_SYNC WRITE. That benefits all WRITE I/O modes on the server.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
