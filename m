Received: from mail-wr1-f50.google.com (mail-wr1-f50.google.com [209.85.221.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5811535F602
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 14:47:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789138029; cv=none; b=huvpvqO71QvUmwmNmbKC+Z5PgTkSpeqHFhKDrnWuYmShG0HXfG9qYBgYXqaS0AH+YrOTeNQT8GDmuszhMcG8vtMOzPv07s+LotAqQ6LqEoBv/pdKIUtPH7R1IzgyTpbbtTwryAC80/lDdsgwixMSuszo7nAoxwteivu7Jk7PFdY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789138029; c=relaxed/simple;
	bh=6qK7Y4OCyC5WsOE2SJMQ4fti6jzNs1Pji9/QbACrVAA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Y/KLonURn2FJjHCBLOw/WmNTU+wqDbwxMPcitaErhRZwi2yHCfpPlLsbGrzUVHDrUskWfgjf15pzAalUyRQjBssn484lZMNLJLr9XLV4130RisO3aD9gFfDOAzupueKxOkzz3GhEL7JPoELWm2aSHuz4J6aL5ZP4flDbe+sbfu4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=A/5m4Fh/; arc=none smtp.client-ip=209.85.221.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="A/5m4Fh/"
Received: by mail-wr1-f50.google.com with SMTP id ffacd0b85a97d-48441a2ba1bso713067f8f.1
        for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 07:47:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1789138023; x=1789742823; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=QuYE5JBWhvW9oHs2kdysh3HB71WxLYQMcei9gKN4bpc=;
        b=A/5m4Fh/sngCKaEoJLtOhd0PEwql+T8zBi0qHa6cFg5H9HZAwcJa6OQkyRfUkv+4l5
         PrwPUM2nfa2NQ5ZfES2qecayX0h9xaZPjNb5dZ+gNkld9Gq+JI7LtsTkqcJdS043KHXL
         AYrw5uKonljqZ69+949bBF4VmJLQCR12wMLd9GTD7yU89XnGbPwo5FMSdRPi3bUSbnco
         ibBekgmGXt2s/P3iIX1rpyu/BfwNKBORTLgqjA1B0N5VgKnIbC7oztcfa1lA32Qmm1Fp
         rZA6+wXmHyJJXapZZo9qqcM+UPHrA+PTNhVhLBZyYMs5jY9zkFEivXrcP5idys2xQ9LL
         Xd5w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1789138023; x=1789742823;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=QuYE5JBWhvW9oHs2kdysh3HB71WxLYQMcei9gKN4bpc=;
        b=qLHjPDSZzEfWoLGLbKT+4ZMe8rtazFajcTaS6OZn8Ho9nhX1namlKowUr56d6+e3Oj
         86HqsjFXRKPGMTQZtwMqcSUQzSxOe9I9sNS19yfmdOTYqE8RUnlYv2e9vWyqtjEKhBdI
         /SPyIDNQH/h8OHNr1GXzJ9QvDB7eReRap9F9qVdL176uGltETfQbDW69tjuVZWUJ0uBN
         E+IsTgxb2kr6X5UgrekPHyESW+FdmngyqFHXE4mVyW6//CtxlSef7jcK+BPhVxRPh8o+
         +PspEKVoxq2PKPfoW1nQejXbday3DKW/i9vwHAl9cvFOCHP6HXEzYbuYGZZWJDFD4Etl
         7S4Q==
X-Forwarded-Encrypted: i=1; AKwUvByiYBtmCJWxXbRuZ7O2Ml402KdRffxb+gikHW8ReRlfJIfHtJMBVu1tRYMKmQQFd0w9Xqwhrh/Hvys=@vger.kernel.org
X-Gm-Message-State: AFuF++lrFYt/f2RB+FkevHZPtfduxMCh6amLjQmZIzteLVXG26u0WAIc
	BOGMgpUMxM43cJyuj4+hXE0k+/JC/50SESbDF/5BET8MlsBh6zUSfmRdgeZ3qs960io=
X-Gm-Gg: AYBFou08jBDrPLr7jmhSFDErVkJIpb8+HXitood68i5MPQDlqaeotuSyGdvJdQWvzb3
	vY9cVmo+nQ4aTRD4oR9ObBcUKnL46BvUjIH7/gaZI7bsvqQ739oVZSXvu2zDD9MZ6/9ONpRu5PY
	W+fn/ytFBAWD9HpA4xvCz39OI3t1GDpExWHrVjNbGlS3JQThINKN60oClsApT2TIA/q6/lxoukP
	K9YLJdzNzir+QwqLkG1+S/Pixgm25JWU8Nx6jJ4waXbtyN0k8551spmqs5oZd7ZzTi7pGElUfbo
	bGWIQNBzNbZKGmWvzefxLaRJv5ju3T/GDh1Pu3Ld4rO+EQzCyYgV/fteMKXcNHNtIFWGTZ1sAG8
	ClUG0G2tpuOi4bA1ATuujWfzyY50Bh+yJIagD0QMq+xqPXdxK+jwME6c1bdtMqHT4aeJfezbN5S
	avyyGdv+Z4Y+QqQ6AN27VNlQ2HSfdbKNwNcOU70xiNqrVSvAqC86IM71bUDeni5zfl1uCOAVisy
	VyfpA==
X-Received: by 2002:a5d:5e08:0:b0:486:e81b:842a with SMTP id ffacd0b85a97d-486eb358ab6mr5259626f8f.48.1789138022582;
        Fri, 11 Sep 2026 07:47:02 -0700 (PDT)
Received: from localhost.localdomain ([2001:af0:8000:1409:193:86:92:181])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-486eb32e8d1sm6328068f8f.11.2026.09.11.07.47.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 11 Sep 2026 07:47:02 -0700 (PDT)
From: Petr Pavlu <petr.pavlu@suse.com>
To: Tony Luck <tony.luck@intel.com>,
	Borislav Petkov <bp@alien8.de>,
	Thomas Gleixner <tglx@kernel.org>,
	Ingo Molnar <mingo@redhat.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Philipp Reisner <philipp.reisner@linbit.com>,
	Lars Ellenberg <lars.ellenberg@linbit.com>,
	=?UTF-8?q?Christoph=20B=C3=B6hmwalder?= <christoph.boehmwalder@linbit.com>,
	Jens Axboe <axboe@kernel.dk>,
	Johan Hovold <johan@kernel.org>,
	Alex Elder <elder@kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Michal Januszewski <spock@gentoo.org>,
	Helge Deller <deller@gmx.de>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Mark Fasheh <mark@fasheh.com>,
	Joel Becker <jlbec@evilplan.org>,
	Joseph Qi <joseph.qi@linux.alibaba.com>,
	Tejun Heo <tj@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	=?UTF-8?q?Michal=20Koutn=C3=BD?= <mkoutny@suse.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Petr Pavlu <petr.pavlu@suse.com>,
	Daniel Gomez <da.gomez@kernel.org>,
	Sami Tolvanen <samitolvanen@google.com>,
	Aaron Tomlin <atomlin@atomlin.com>,
	Pavel Machek <pavel@kernel.org>,
	Len Brown <lenb@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Danilo Krummrich <dakr@kernel.org>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	Ido Schimmel <idosch@nvidia.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	David Howells <dhowells@redhat.com>,
	Jarkko Sakkinen <jarkko@kernel.org>,
	Paul Moore <paul@paul-moore.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Kentaro Takeda <takedakn@nttdata.co.jp>,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-edac@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	drbd-dev@lists.linux.dev,
	linux-block@vger.kernel.org,
	greybus-dev@lists.linaro.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-acpi@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ocfs2-devel@lists.linux.dev,
	cgroups@vger.kernel.org,
	linux-modules@vger.kernel.org,
	linux-pm@vger.kernel.org,
	driver-core@lists.linux.dev,
	bridge@lists.linux.dev,
	netdev@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-security-module@vger.kernel.org
Subject: [PATCH v3 2/3] time/jiffies: Include linux/sysctl.h for proc_int_u2k_conv_uop(), ...
Date: Fri, 11 Sep 2026 14:46:15 +0000
Message-ID: <20260911-module-include-kmod-v3-2-6ebccc3e0731@suse.com>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260911-module-include-kmod-v3-0-6ebccc3e0731@suse.com>
References: <20260911-module-include-kmod-v3-0-6ebccc3e0731@suse.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

jiffies.c uses proc_int_u2k_conv_uop(), proc_int_k2u_conv_kop(),
proc_int_conv(), proc_dointvec_conv() and proc_doulongvec_minmax_conv(),
which are declared in linux/sysctl.h. It currently gets that header
indirectly through linux/module.h -> linux/kmod.h, but the latter no longer
needs to include linux/sysctl.h.

Include linux/sysctl.h directly in jiffies.c ahead of removing the
unnecessary include from linux/kmod.h.

Signed-off-by: Petr Pavlu <petr.pavlu@suse.com>
Acked-by: Thomas Gleixner <tglx@kernel.org>
---
 kernel/time/jiffies.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/time/jiffies.c b/kernel/time/jiffies.c
index 213ae1d6a014..9231fea557ce 100644
--- a/kernel/time/jiffies.c
+++ b/kernel/time/jiffies.c
@@ -8,6 +8,7 @@
 #include <linux/jiffies.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/sysctl.h>
 
 #include "timekeeping.h"
 #include "tick-internal.h"

-- 
2.55.0
