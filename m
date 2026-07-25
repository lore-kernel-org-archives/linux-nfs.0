Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D0BC625;
	Sat, 25 Jul 2026 20:31:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785011472; cv=none; b=aTgBjb9cj0tsiNCIRNgwNLQgX0d4hZvqBukP+Rg2l7tWTaje0908uRIqsphDDLpNn90NS7itft0NcPZn0kT/lLzw0lkWg+AGJ+lbKUrBFyLPInQnST1u4p1GrXrFF2jSYORyEQQo4xyOyaRpTavkuvEMlc1C2OJHvum7JLtMtJs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785011472; c=relaxed/simple;
	bh=e6KMoD3bd5/q6p3xQeg23qgiuejFXySUo/aGZ6esyCc=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=JKAGydDvVpvukxAV9Q1NF4vPSEA0b15yWfsrQ+p8Z/gHAJTBkG3dE+5eiVca8cKXSa3+Noh0ZRnip2j1grPveDwhnKx5JBqbrqP+cZ/zdtyC9p92rmeO423HfMKXTQCZvNPA2mBE33TwVY9FNnKOF7f2Gxtd/dBn9DwNGDP2Zzo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hAfTn9kP; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hAfTn9kP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DFFA01F000E9;
	Sat, 25 Jul 2026 20:31:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785011470;
	bh=e6KMoD3bd5/q6p3xQeg23qgiuejFXySUo/aGZ6esyCc=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date;
	b=hAfTn9kP3ZABFKIwidJBkzkwUEnV03/r5N7p8kmUos3uDtUKUWtEJzQPpdypzC87s
	 s8zXrjsDbl2M4eM1W7J86H4KiLLuZnMtxMMILtEw98qiQcngdzhm3Z933lwVaUuZ1u
	 NLkyUWEUlaRXQiJD2BrV3+doGFNu5m2sLbsSq0EGZklaA6R4wtvLOLLa2OnPQe5qNl
	 qRc/eqpUyUDjcyObmg1ruSpXH9PI078U1i4aarlF7k3SAVuPPwJdBfCiYHUHqv1JgK
	 gHSHbd+Pb+4KEwvFVr0Xj05kVhoMd7+HPlRE8f80fEhbz02ckPWPFwbzdqixw/v4UL
	 pVfAw00n8dMXA==
From: Thomas Gleixner <tglx@kernel.org>
To: Petr Pavlu <petr.pavlu@suse.com>, Tony Luck <tony.luck@intel.com>,
 Borislav Petkov <bp@alien8.de>, Ingo Molnar <mingo@redhat.com>, Dave
 Hansen <dave.hansen@linux.intel.com>, x86@kernel.org, "H. Peter Anvin"
 <hpa@zytor.com>, Philipp Reisner <philipp.reisner@linbit.com>, Lars
 Ellenberg <lars.ellenberg@linbit.com>, Christoph =?utf-8?Q?B=C3=B6hmwalde?=
 =?utf-8?Q?r?=
 <christoph.boehmwalder@linbit.com>, Jens Axboe <axboe@kernel.dk>, Johan
 Hovold <johan@kernel.org>, Alex Elder <elder@kernel.org>, Greg
 Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki"
 <rafael@kernel.org>, Michal Januszewski <spock@gentoo.org>, Helge Deller
 <deller@gmx.de>, Alexander Viro <viro@zeniv.linux.org.uk>, Christian
 Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, Trond Myklebust
 <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, Chuck Lever
 <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
 <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
 <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Mark Fasheh
 <mark@fasheh.com>, Joel Becker <jlbec@evilplan.org>, Joseph Qi
 <joseph.qi@linux.alibaba.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner
 <hannes@cmpxchg.org>, Michal =?utf-8?Q?Koutn=C3=BD?= <mkoutny@suse.com>,
 Luis Chamberlain
 <mcgrof@kernel.org>, Petr Pavlu <petr.pavlu@suse.com>, Daniel Gomez
 <da.gomez@kernel.org>, Sami Tolvanen <samitolvanen@google.com>, Aaron
 Tomlin <atomlin@atomlin.com>, Pavel Machek <pavel@kernel.org>, Len Brown
 <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Danilo
 Krummrich <dakr@kernel.org>, Nikolay Aleksandrov <razor@blackwall.org>,
 Ido Schimmel <idosch@nvidia.com>, "David S. Miller" <davem@davemloft.net>,
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>,
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, David
 Howells <dhowells@redhat.com>, Jarkko Sakkinen <jarkko@kernel.org>, Paul
 Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>, "Serge E.
 Hallyn" <serge@hallyn.com>, Kentaro Takeda <takedakn@nttdata.co.jp>,
 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-edac@vger.kernel.org, linux-kernel@vger.kernel.org,
 drbd-dev@lists.linux.dev, linux-block@vger.kernel.org,
 greybus-dev@lists.linaro.org, linuxppc-dev@lists.ozlabs.org,
 linux-acpi@vger.kernel.org, linux-fbdev@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org, ocfs2-devel@lists.linux.dev,
 cgroups@vger.kernel.org, linux-modules@vger.kernel.org,
 linux-pm@vger.kernel.org, driver-core@lists.linux.dev,
 bridge@lists.linux.dev, netdev@vger.kernel.org, keyrings@vger.kernel.org,
 linux-security-module@vger.kernel.org
Subject: Re: [PATCH v2 2/3] time/jiffies: Include linux/sysctl.h for
 proc_int_u2k_conv_uop(), ...
In-Reply-To: <20260721131207.803760-3-petr.pavlu@suse.com>
References: <20260721131207.803760-1-petr.pavlu@suse.com>
 <20260721131207.803760-3-petr.pavlu@suse.com>
Date: Sat, 25 Jul 2026 22:31:07 +0200
Message-ID: <874ihmke0k.ffs@fw13>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On Tue, Jul 21 2026 at 15:11, Petr Pavlu wrote:

> The kernel/time/jiffies.c file uses proc_int_u2k_conv_uop(),

jiffies.c uses ...

> proc_int_k2u_conv_kop(), proc_int_conv(), proc_dointvec_conv() and
> proc_doulongvec_minmax_conv(), which are declared in linux/sysctl.h. It
> currently relies on this header being included indirectly through
> linux/module.h -> linux/kmod.h. Add the missing include in preparation for
> removing the linux/sysctl.h include from linux/kmod.h.

Can you please split that spaghetti sentence into paragraphs?

https://docs.kernel.org/process/maintainer-tip.html#changelog

> Signed-off-by: Petr Pavlu <petr.pavlu@suse.com>

Other than that.

Acked-by: Thomas Gleixner <tglx@kernel.org>
