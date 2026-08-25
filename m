Received: from invmail4.hynix.com (exvmail4.skhynix.com [166.125.252.92])
	by smtp.subspace.kernel.org (Postfix) with ESMTP id 2038A3F8234;
	Tue, 25 Aug 2026 13:19:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=166.125.252.92
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787663954; cv=none; b=IwG6QUtDeJS4YCYlVmGeR6wcRTMZbP90WUjPgubRwlV/SPUCqJvPIQJw2zu8q8n0pEyNsOyrm0KI5SdjVqJyfKdYoL8qZZc3qVzFYiYseukAUwehvDeQnx90yoNFRsRCdpmm0jbWBjelkilJ8b9h/pvHITOn0oezuooPJuDJWxs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787663954; c=relaxed/simple;
	bh=5TVEsS2ZrICCGdu5fHn5ixwm1NzymOIz9G67H0t4KAU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=sS5yxDhceynggZz4nDlKvnshPEPOhqnyzdUwKYchoGdZ8IxDMNSfJ3sEtqCNz1eNBiCJN+u0SSYd6guAXg8/I1XHs7O9DCkdxOfAq7IMiD14XsckXL2xYnKQ5ZhX676VN6CgA6lKbweyfedRLEo/eXXapbPKo4tVX8dRYmqbvVQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com; spf=pass smtp.mailfrom=sk.com; arc=none smtp.client-ip=166.125.252.92
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=sk.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=sk.com
X-AuditID: a67dfc5b-c45ff70000001609-0b-6a8d964b2220
Date: Tue, 25 Aug 2026 22:19:06 +0900
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
Message-ID: <20260825131906.GC23086@system.software.com>
References: <20260706061928.66713-1-byungchul@sk.com>
 <359ea967-9b97-4584-88e6-bddb4044de2e@kernel.org>
 <20260821042143.GA40890@system.software.com>
 <825134a8-ceae-430c-b2fc-d1d0c7240f39@kernel.org>
 <20260825121322.GA23086@system.software.com>
 <e0c589d0-d17b-48c2-8e1b-d41b69ecaadc@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e0c589d0-d17b-48c2-8e1b-d41b69ecaadc@kernel.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Brightmail-Tracker: H4sIAAAAAAAAA01Sa0ybZRjN+13e76Oh8bPD+W4k/qghS9BtzGzuibqL8YefITEm/tsStbHN
	KIOytYCgISvILhQ2RpHiisxyq0DLIAWmVLpVhIIOQgsOStOGLtIicpk2ATJwQ4pZ3L+Tc85z
	zpM8D0/LLHgvr9bkqrQaRZYcSxjJcmLj/nTT1cy08sDrcOXiBZgqdjMwMl3CwPpmHQ0X+7YY
	eGz0cFBTjGDL5UFg8hlp8Hvv0mDvKaZg8ecYgpoHcxgeWiu2LaF5CqbXlhDMuS8jeGw6C982
	dmOILYQRuFpLMESu99Lw2+pDDCtdGHyjiwjq64wIogEXBV82dWIw1TsYCJqMFMxaowzUdPxI
	wSNrOwejTUEGrPoUqBubZMFjm+fg1vI4C4tRI4bZ4UssfK8Pc+CYGUJwxbnKgCvwCjRcamZg
	0vkNhoquXhb0desseN33WJiweRkYd3aw0DLto+BB2M9C99goDWvXksFbdZWFjpVGDNUrUQQz
	tUscTLgtFLT+XctCm2sMg8eyG7pKzdxJpWi/aUfi5oYRiS33lrC4sXofi81lG5RYNbZf7DOH
	OLH0ToATLY48sXRwmRW7W1PFpv4FSmyIrbKio70Miw2bf9BicKoff/DqKclbSlWWOl+lPXj8
	E0lGqLKFPediC26HKzk9qmIMKIEnwmFSHSjDT3Gfy04bEM8zQgqJRk7EaSzsI37/IzqOk4Q0
	Mj9SQhmQhKcF20vkq9lhLi7sEo6SnmA5js9KBSDjvz4X98iETooY7/fseKTC8+SXG3M7vbSQ
	SvxPFqi4nxaSyXdP+DidIBwn9jtzO10vCC8T9+3hnS4iRBPIn5dbqP/23EN+avUz15FgfibW
	/Eys+f9YC6LbkUytyc9WqLMOH8go1KgLDnyak+1A239rLfrn9A8o5v1wAAk8kidKt8+VKWMV
	+brC7AFEeFqeJP2iyJApkyoVhZ+rtDkfa/OyVLoBlMwz8helr619ppQJZxS5qrMq1TmV9qlK
	8Ql79ej0SLCzYejgKec+U9vb1pjDkH6sVlNReyw0GAmvVVZEnYGpa56NdXSo62tbSvWRPl3B
	ewtvvDNJH2mLsEn6MxdsStNQUFFkfdMuD5a/m3j+hO+vUGKe7EZ/80pp0u7ffQOZ79ffnE0b
	hPSPttDd85tcnm9msHfP0dSJnJNCbkQvZ3QZikOptFan+BcD5aJdswMAAA==
X-Brightmail-Tracker: H4sIAAAAAAAAA02SfUxTZxTGfd/39vbS2O3aod6IWUxl0ZD4lWg8m4sf2RbvNDOaLEFnnHbj
	RgqlaqsgW4xSaAZ1alttCa0ogq1M6mDlw3WujGAEUYitH6NRsJhciwQQo1QjUFhLYuY/J+c8
	5/nlOX8chihiknmMWntQ0GlVGiUto2Rb1hQu2Ww/kbW82s5AsfEo9IRFCfxb0EJBdLSYgrO1
	HhpizqtSKPaWSeBmt4GCwO81CMLRYgRvxp0EjL4pCmLWNimMvn0kBVsBgil/GwJ70EogFPiH
	gKehAMOrukkaBq+/RGB7ItJQOlBAwYj7VwSOiFMKAzc2wnD4mgSmevsxdL8eQuAWJzGILb8g
	iNmz4XxlfRy3v6BhvOsOgVJbAMGFJ70EXg70IWhoe4ygv3EMgb/aQMNTcyOBe+IHcD86QkOH
	7TgNw8GzGJ7X0VBh8Esg2DmIoNxpRRB56MdQWFVLg73cS4Gv7y8pBAcnMPTYrRhqvN9A2B2h
	4La5Esdvjrv+mAvO0kIcL88w2K5cw+vdiH9jPEnxl+ubMG+8G6N5zzkP4sfHrIgfdRUS3miO
	j9eHRghfVJ/Hu24P0fxY9AHN+19XUPytSo6/WDKGeUvXEt7n6JVu3fCd7PMMQaPOFXTL1u6R
	Zfaeckn2+yWHm/pOSY8hC2VCSQzHruR8fg8xIYah2E+4yNN1CZlmF3Gh0FuS6JPZ5Vz/TQM2
	IRlD2JqPuTPhdmli8RG7mmvoOU4nWDkL3J1bHyY8CrYWc9YHDdMeOTuL6ygTp7MIm8aFJgdw
	wk/YFO7SJJOQk9i1nKdZnM6azS7kWprasRnJHe/Rjvdox/90BSKXUbJam5ujUmtWLdVnZ+Zr
	1YeX/rgvx4viT+k+MmH5E43e29iKWAYpZ8oDlhNZCokqV5+f04o4hiiT5T8fMWUp5Bmq/J8E
	3b7dukMaQd+KUhhKOVe+KV3Yo2D3qg4K2YKwX9C922Imad4xZG4v2TX/i5IFXak7872z1Zlf
	Pg6EijTN5KTPtmOoSL/z+23LtKldaYcaXdVKU2k0b05VimgNlnV7A2dM4WrX1XLVloX2Hzqp
	zzIu8es76hbvdVZ9Onzh24ruPEPqb191bp+RHli3Rvza0pceOdCcc9r899SMzQvuh3J3Tww+
	G+/A55WUPlO1Io3o9Kr/AKCz9huQAwAA
X-CFilter-Loop: Reflected

On Tue, Aug 25, 2026 at 03:10:28PM +0200, David Hildenbrand (Arm) wrote:
> >> As the saying goes, it's hard to teach old dogs new tricks, but in the end
> >> taking care of two dogs is likely harder than only a single dog? :)
> >
> > Or it's better to train a unmatured hunting dog than to teach a pet dog,
> > how to hunt, for better hunting, even though the pet dog might
> > eventually become able to.
> 
> I'm not sure whether "pet dog" is the right analogy to lockdep in that scenario,
> though ;)

Ah.  Okay.  I will be careful in using terms.

I wanted to tell DEPT has its strength, lockdep has its own, and they
are different.

	Byungchul

> 
> --
> Cheers,
> 
> David
