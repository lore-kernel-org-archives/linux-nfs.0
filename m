Received: from invmail4.hynix.com (exvmail4.hynix.com [166.125.252.92])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 5FB7D3F44FC;
	Tue, 25 Aug 2026 12:13:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=166.125.252.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787660015; cv=none; b=cDJjwiVXuicQrlg6dUx+QJ8s7O7KgF+g6X+1BglgVgmYn31MpoIWtHXWycIFahJCcN6Paagvy7AkW7Nks86mN8Dfqlei2HqvcVUIeKdn8BFxMP78cHKJEejX4TTwWTB60EGxRFM8a5AjnPTC1Cm2/sSisgxJh/rfEHKyNu7fkrI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787660015; c=relaxed/simple;
	bh=yhKLfzID1f/dA9Xk/1pmQH6YYuXV9c5I6vqhpAJ1P+E=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=gvVHb5syyXJzYrj0NUmtZvcniGVehEBeAgXvVsG+/zSbmVIANrpLUAy1q4KYGNbGZw+gL8GbingDESvHVXBH5c+FJO7EE5dvo9v1GumQaYlANDVdRS9kkQ+phXp2wgyJir04itfuJiacmJbnLbcf8WAafT48m2PzY9T7RaBVM50=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com; spf=pass smtp.mailfrom=sk.com; arc=none smtp.client-ip=166.125.252.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sk.com
X-AuditID: a67dfc5b-c2dff70000001609-65-6a8d86e25743
Date: Tue, 25 Aug 2026 21:13:22 +0900
From: Byungchul Park <byungchul@sk.com>
To: "David Hildenbrand (Arm)" <david@kernel.org>
Cc: linux-kernel@vger.kernel.org, max.byungchul.park@gmail.com,
	kernel_team@skhynix.com, torvalds@linux-foundation.org,
	damien.lemoal@opensource.wdc.com, linux-ide@vger.kernel.org,
	adilger.kernel@dilger.ca, linux-ext4@vger.kernel.org,
	mingo@redhat.com, peterz@infradead.org, will@kernel.org,
	tglx@linutronix.de, rostedt@goodmis.org, joel@joelfernandes.org,
	sashal@kernel.org, daniel.vetter@ffwll.ch, duyuyang@gmail.com,
	johannes.berg@intel.com, tj@kernel.org, tytso@mit.edu,
	willy@infradead.org, david@fromorbit.com, amir73il@gmail.com,
	gregkh@linuxfoundation.org, kernel-team@lge.com, linux-mm@kvack.org,
	akpm@linux-foundation.org, mhocko@kernel.org, minchan@kernel.org,
	hannes@cmpxchg.org, vdavydov.dev@gmail.com, sj@kernel.org,
	jglisse@redhat.com, dennis@kernel.org, cl@linux.com,
	penberg@kernel.org, rientjes@google.com, vbabka@suse.cz,
	ngupta@vflare.org, linux-block@vger.kernel.org,
	josef@toxicpanda.com, linux-fsdevel@vger.kernel.org, jack@suse.cz,
	jlayton@kernel.org, dan.j.williams@intel.com, hch@infradead.org,
	djwong@kernel.org, dri-devel@lists.freedesktop.org,
	rodrigosiqueiramelo@gmail.com, melissa.srw@gmail.com,
	hamohammed.sa@gmail.com, harry.yoo@oracle.com,
	chris.p.wilson@intel.com, gwan-gyeong.mun@intel.com,
	boqun.feng@gmail.com, longman@redhat.com, yunseong.kim@ericsson.com,
	ysk@kzalloc.com, yeoreum.yun@arm.com, netdev@vger.kernel.org,
	matthew.brost@intel.com, her0gyugyu@gmail.com, corbet@lwn.net,
	catalin.marinas@arm.com, bp@alien8.de, x86@kernel.org,
	hpa@zytor.com, luto@kernel.org, sumit.semwal@linaro.org,
	gustavo@padovan.org, christian.koenig@amd.com,
	andi.shyti@kernel.org, arnd@arndb.de, lorenzo.stoakes@oracle.com,
	Liam.Howlett@oracle.com, rppt@kernel.org, surenb@google.com,
	mcgrof@kernel.org, petr.pavlu@suse.com, da.gomez@kernel.org,
	samitolvanen@google.com, paulmck@kernel.org, frederic@kernel.org,
	neeraj.upadhyay@kernel.org, joelagnelf@nvidia.com,
	josh@joshtriplett.org, urezki@gmail.com,
	mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com,
	qiang.zhang@linux.dev, juri.lelli@redhat.com,
	vincent.guittot@linaro.org, dietmar.eggemann@arm.com,
	bsegall@google.com, mgorman@suse.de, vschneid@redhat.com,
	chuck.lever@oracle.com, neil@brown.name, okorniev@redhat.com,
	Dai.Ngo@oracle.com, tom@talpey.com, trondmy@kernel.org,
	anna@kernel.org, kees@kernel.org, bigeasy@linutronix.de,
	clrkwllms@kernel.org, mark.rutland@arm.com, ada.coupriediaz@arm.com,
	kristina.martsenko@arm.com, wangkefeng.wang@huawei.com,
	broonie@kernel.org, kevin.brodsky@arm.com, dwmw@amazon.co.uk,
	shakeel.butt@linux.dev, ast@kernel.org, ziy@nvidia.com,
	yuzhao@google.com, baolin.wang@linux.alibaba.com,
	usamaarif642@gmail.com, joel.granados@kernel.org,
	richard.weiyang@gmail.com, geert+renesas@glider.be,
	tim.c.chen@linux.intel.com, linux@treblig.org,
	alexander.shishkin@linux.intel.com, lillian@star-ark.net,
	chenhuacai@kernel.org, francesco@valla.it,
	guoweikang.kernel@gmail.com, link@vivo.com, jpoimboe@kernel.org,
	masahiroy@kernel.org, brauner@kernel.org,
	thomas.weissschuh@linutronix.de, oleg@redhat.com, mjguzik@gmail.com,
	andrii@kernel.org, wangfushuai@baidu.com, linux-doc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org,
	linaro-mm-sig@lists.linaro.org, linux-i2c@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-modules@vger.kernel.org,
	rcu@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-rt-devel@lists.linux.dev, 2407018371@qq.com, dakr@kernel.org,
	miguel.ojeda.sandonis@gmail.com, neilb@ownmail.net,
	bagasdotme@gmail.com, wsa+renesas@sang-engineering.com,
	dave.hansen@intel.com, geert@linux-m68k.org, ojeda@kernel.org,
	alex.gaynor@gmail.com, gary@garyguo.net, bjorn3_gh@protonmail.com,
	lossin@kernel.org, a.hindborg@kernel.org, aliceryhl@google.com,
	tmgross@umich.edu, rust-for-linux@vger.kernel.org
Subject: Re: [PATCH v19 00/40] DEPT(DEPendency Tracker)
Message-ID: <20260825121322.GA23086@system.software.com>
References: <20260706061928.66713-1-byungchul@sk.com>
 <359ea967-9b97-4584-88e6-bddb4044de2e@kernel.org>
 <20260821042143.GA40890@system.software.com>
 <825134a8-ceae-430c-b2fc-d1d0c7240f39@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <825134a8-ceae-430c-b2fc-d1d0c7240f39@kernel.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Brightmail-Tracker: H4sIAAAAAAAAA02SbUxTZxTH+9z79N5LY5Nrh+MRjMuqBKaR6XTbiZm6LRpvTLa4DP3APkg3
	bqQIhZX3LWYUEFGZOrKWrTBFkMp4cawFN142Cwi002VVGHSos5VujiCwdbSJCLJbiBlfTv45
	53/+v/PhcLTKxkRyWl2WqNdpUtWMAismV9RsGiv5NGXzYGcUlB77BIYNdgyBmVIMVd80MeAY
	KcTgutyI4Fj7Aob58n4WjAYEbtdVGppaDRRM9PoRGL0+BirGDRimLWUIzH9WsjDetxdGgg8R
	WHxPKPDZjyOYNx2B8zU2BiZMf0t+owuBf9yDYCgwzYDTeIqByZtVFEy1MGD6yoqh3dPBwh1T
	OQWN1rekfKn9bQRUVhRRUvmLAmNzJwWWgmi4X29mYc67BRaq0+HuGSOG7wo8LFh/60MwM+Sl
	wDo2LIcLJRcxdP3gxFA6P4OgrKVNDi77dTlc73dgcJq/xnD75zMs/NLRLIe6kZsUeD1uOQRP
	R4H77B8ImqdqpNODFhpu2aspMHTX4teThAbbFUpoOteEhMez5UiYqSuihd6H07RQbMsVZgO/
	MkK7+S4rFP84ygrV1myh+NqkXLDVbxBqu8Yp4YI/IBdGJ3YI1oYTzP6NCYrXksRUbY6of3Fn
	oiLZ4I/PqFif19F2jy5AhjUnURhH+G3EO3YcPdWDV5upkMZ8NLnWV8SENMPHELf7ER3S4fxm
	8sBRKHkUHM03riWf3xtgQ4Nn+FdJ651T0gLHKXkgjkerQx4VfwORyUtLQUp+JXF+6cMhTUuh
	c+du0SE/zUeRS0+4pfZzpKitcpEVxu8ko21Vi/Gr+HXEfmVgkUv4YBjpOvGYWjp6Nemud+Oz
	aKV5GcK8DGH+H2FehqhGuAGptLqcNI02dVtccr5Omxf3QXqaFUmvbDk69973yO96twfxHFKv
	UCa+XZaikmtyMvPTehDhaHW48uOjJ1NUyiRN/keiPv2QPjtVzOxBURxWRyhfCuYmqfjDmizx
	iChmiPqnU4oLiyxAkQ9GuX9Gdr/jO3zgzTWdiT/JvC/UOWJ7p/gSZ9YXhbF47Ru7ZGmaoa2x
	L8d7n219Zb3p/X2yiB0xg90bB/J2ny5n9nlif0/WykxxW9cN1yX4AqwtPlem1c7u+ZDS5Tzf
	YhET7kfvCXdlt5QcrPisVtx+Y0E4sH3X7dnOmIz+f42Ve9U4M1mzZQOtz9T8B4Qr2ejGAwAA
X-Brightmail-Tracker: H4sIAAAAAAAAA02SbUxbZRTHfZ7n9umlsctd7cbdZmasW1iW7C2ReXSGqF96NZkuZkpijKOR
	u1HKy2wnDnUZpdbVMSdrbAktTMStW1bGECiOLc2QSQcDwptzDAoF7UBCEYeUhXdvtxj5cvI/
	5/zP75wPhyUqB13P6rOOiMYsXYaGKhjFm3ss237/8uv0neHoFrBZj0MwFJbBb+YGBqLTNgZK
	rlRQWHT/JAdbdbEMmu/mM9BZ6UUQitoQPJx3E7DWLzOwaA/IYXq2Xw4OM4JlfwCBs8tOoLfz
	BoGKWjOGf6qWKIzfnELgGA5TKBozMzDpOYXANeKWw1iTFiZC12WwPDCK4e5MBIEnvIQh3HAC
	waLTAN+V10jjzr8pzLd3EChydCL4fniAwNTYEILawCCCUd8cAv/FfAr3C30EesKr4NfoJIUW
	RwGFia4SDH9VUSjL98ugq20cQanbjmCkz4/B8sMVCs7Sagbqh67JoWt8AUPQacfgrd4LIc8I
	A62F5Vi6WXL9GA/uIguWwp8YHJev41c8SHhoPc0Il2rqsGDtXqRCxdkKJMzP2ZEwfd5CBGuh
	lN6MTBLhi5pPhPOtESrMRe9QwT9Txgi3y3nh3FdzWDjTvk2odw3I9736nuLlVDFDnyMadySl
	KNLMU/sPF206es0XInnI/PRJFMfy3PN8z43LOKYZbjP/S5OFxjTlEvje3lkS02puJz/anC95
	FCzhvBv5b0O35LHGU9wLfG2wQBpgWSUHfPPsuphHxbUhfuLCY5CSW823FIeZmCYSdOFsN4n5
	CbeBv7DEPi4/w1t87ke74rgkvs9X8gi/hnuOb6i7hQvRKtcKkmsFyfU/ybWCVIaYS0itz8rJ
	1OkzErebDGm5Wfqj2z/MzqxG0rN6ji2cuYqme7SNiGOR5kll2jun0lUyXY4pN7MR8SzRqJWf
	HTuZrlKm6nI/FY3ZB4wfZ4imRrSBZTTxyjeSxRQVd0h3RDSI4mHR+F8Xs3Hr89ATDbuzK5Pb
	f276aIipTeHeUree02SXvuY9UWC6c7vyj6RgYgLZMd4hnt61721D1drXg5tn8o7vTh38QBb0
	NiUm39ubu/9FXHwxsGbw3lDbg2cPft4iFrwUGL5qflC21r6Rvrunv3FhXbnNrXp/a117h1aj
	jnRCt+wb7f2+eK0hoT+iYUxpul1bidGk+xf0qtPwqAMAAA==
X-CFilter-Loop: Reflected

On Fri, Aug 21, 2026 at 09:56:05AM +0200, David Hildenbrand (Arm) wrote:

[...]

> >>> Q. Why not build DEPT into lockdep?
> >>>
> >>> A. Lockdep is stable, battle-tested code. I chose separation because
> >>>    while DEPT borrows BFS and hashing ideas, the wait/event model
> >>>    requires rebuilding from scratch. Lockdep was designed for lock
> >>>    acquisition order — retrofitting it would risk its stability.
> >>
> >> Why can't this just be some configurable extension to lockdep
> >> (CONFIG_LOCKDEP_XYZ) until the feature is stable and can unconditionally be
> >> enabled along with it?
> >
> > Answered?
> 
> Not quite. I don't understand why this must be a completely separate machinery,
> even if, conceptually, it would do more than traditional lockdep.
> 
> Is it either DEPT or LOCKDEP in current configurations? Can both run at the same
> time?

Yes.

> >
> >> I don't quite buy the "would risk its stability" argument. A lot of stuff we do
> >> "risks stability", every day :)
> >
> > That's awsome anyway :)
> >
> >> Is there another good reason (incompatible with X, dangerous with Y, cinfusing
> >> Z) why this really must be a separate thing?
> >
> > Roughly:
> >
> >    1. Similar or less effort is needed for the new one - retrofitting
> >       lockdep is not easy and big changes are required since the
> >       reusable parts are not that big.
> >
> >    2. Even though you didn't agree, retrofitting it would risk its
> >       stability.
> 
> Well, I don't buy the stability argument, really :)
> 
> Retrofitting effort for lockdep is an interesting point, though. Lockdep
> maintainers would have to make the call here regarding direction and feasibility.
> 
> [...]
> 
> >> But I am not a locking maintainer. I think there was plenty of discussion in the
> >> past, so I might just be raising points that were already discussed in the past,
> >> but I really just read some random pieces of earlier discussions. (ideally
> >> previous discussions would be summarized here)
> >>
> >> Long story short: we are now in v19 and I think there was pushback in the past.
> >> Did the opinion of locking maintainers change, or is there a way forward to
> >> integrate this in a way that would make locking maintainers accept this?
> >
> > One of locking maintainers who I met in an LPC told me that he agrees
> > with the direction of DEPT and supports DEPT, not officially tho.
> 
> Hm.
> 
> >
> > What he and other people are concerning w.r.t DEPT the most is, false
> > positives, which is the most important issue for now.
> 
> Thanks for highlighting that. What's the main reason for false positives? Is it
> something conceptual that is mostly impossible to solve, or rather just
> implementation work to cover all edge cases?

It's because of lack of annotations for proper classification.  As Willy
mentioned, different call paths for various usages should be annotated
with different classes throughout the kernel.

> > At the same time, I think the most important thing is to make DEPT
> > useful in practice especially with folio locks involved.  Actually, I'm
> > planning to share DEPT's true reports periodically to LKML and work with
> > people who believe DEPT can make things better.
> >
> > Any advices will be welcome.  Thanks for your opinions.
> 
> I think we must come to some conclusion on how to proceed with DEPT. I see the
> following options:
> 
> (1) Don't merge it and carry it OOT. Shame if it delivers real value.
> 
> (2) Merge it (after proper review and acks from relevant maintainers ;) ),
>     keeping it entirely separate from lockdep.
> 
> (3) Integrate it with lockdep on a high level, giving us a single locking
>     dependency checker, but mostly letting dept have a separate implementation.
>     Look into possible merging afterwards.
> 
> (4) Retrofit and extend lockdep to really have one mechanism.
> 
> As the saying goes, it's hard to teach old dogs new tricks, but in the end
> taking care of two dogs is likely harder than only a single dog? :)

Or it's better to train a unmatured hunting dog than to teach a pet dog,
how to hunt, for better hunting, even though the pet dog might
eventually become able to.

> I tend to favor (4) (or 3 with possible future work to achieve 4), but I am not
> a locking maintainer, so really they have to voice what to do.

Right.  However, thanks for your opinion.

> I do see value in DEPT (even if the folio lock might be handled differently).

Thanks!

	Byungchul
> 
> --
> Cheers,
> 
> David
