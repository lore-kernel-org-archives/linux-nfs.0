Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.41
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564223;
	b=vH+Wf55Eg6Qya9xzazhc9WR24m9dWVIAm5KbMu+XiiEg6XkZL7LlyAmTHISL9ujfAwVa
	 /vhFibfpp1eCHVy34Gk4Kq1vNY8bug4Vy4YaJBR3N8r66A7V2OE2hO5TNPyRy0/vqOyUp
	 n+JEXQ7a1Q8tXPlDM9HFLPnQsI8VYA91zrCAzeLPQrQRzGgPH0NXyxNi+J61ANv3OOpl8
	 ZKWbEK6/CWzXfhJniQf3n6xGJDXkZy/10e9RwiPW1eOGeCsS1v4GHzpMgL7juazD2OEGw
	 HXZY3j8qr2CTFO4EtVE70IeCWC9zFCghm5/Hpz+n5r9F4CRU6a63mUQx2T8FLjtoxTA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564223;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=6cN8hpP/bnwcYzPsZf0cUkd2pk5Vve+UdRh8Jmnig90=;
	b=LhOKBf2L/rNOhHNDwFAWHROcxpdjAXNVp8J8GvKtnhXCekX2qdTgBK5eAf523rCuh2HP
	 VYTtfFQZ9i2xsCJYNZ6JGq4a3TREjr1ehlB8G0lbahYrgV9PdDL5I4B26NhCFv+uz9F16
	 CjUEYxK0EGL9j3Nlzvl8H9hnptNW4HEfl3ZI3GeiOx06JvEP3yxTrN/X3XOM6vVlm/5Bx
	 ITaee4xHdifBFZmnenlLgXy3GmiRStNzLqmmzPuMHNXbUXX+vq7psscVFjCdG/GFmH8G6
	 gkBM4+0OrEZPK0HwtLi1P+ORCtQL84CsiirP0mJjIYl31P6KmreE1/hlFOjLR8V2sLA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b="YppAuU/f";
	arc=none smtp.remote-ip=209.85.218.41
Received: from mail-ej1-f41.google.com (mail-ej1-f41.google.com [209.85.218.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C884660A262B
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:03:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C884660A262B
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=YppAuU/f
Received: by mail-ej1-f41.google.com with SMTP id a640c23a62f3a-c40e30c26a4so170618066b.0
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:03:42 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564221; x=1795169021; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=6cN8hpP/bnwcYzPsZf0cUkd2pk5Vve+UdRh8Jmnig90=;
        b=YppAuU/f77eWMTZ8F/Y/RTjltBDd6igz4EttMolmckndL9mvAt3euwqVCnUFPcnj1L
         wpVFClVgg0YlcE6bTABHQT1NnQyujG09t70SZ+IGoHQq0qQgGGwB+4JQikI2kaQwvi8W
         H3KupRONVF9kXu90kRN/xwbfNoANJajav9pnhnb3IMIJ4A6DWEq+8017kOKRrUT+YN/m
         jRUDmGHXRq1c+43Y1O2K5XEGEQl+nQ8YkAZ+/5vrEItOhIamTuHGEOkZUAeGsE8baOwB
         Dj4haSBpRwT/bMXANPqkevI0ogqYaGkZDRE/CPrkXlmZ9T16K5sayD5Snik8DtXgYcT5
         haBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564221; x=1795169021;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=6cN8hpP/bnwcYzPsZf0cUkd2pk5Vve+UdRh8Jmnig90=;
        b=r3WK04O5ng0k9gQiBY5Tgaek0fwq5hgtKYMCcPZ4SfykckQHJnvoEZv+MsyzJf6jM+
         JdpKzTSe9drmiG0E3wp/CaCS8/QIl24WHcFMD1ML0epnX15zGttnW8CedVL2YuM5HFq0
         PgfATv5MoNbMCvIgr34jNAI67z3inYkFblfe8TEhI9iDqxdhWDGPDdchqtKH6rrPeFem
         gbnw5fLXsMUJmUQ4xuZgg+yP+BdVvJ7nvcDjocRjFxOQnve/T6SvsptsWqhlWpHoEHE/
         rNfj2poywX/IxeEvmv9ebvadjh3N0+8BJayQbOqP13hNg1cXg5RN4/WuTkwBTXK8eUtC
         ryTw==
X-Forwarded-Encrypted: i=1; AL+hErEVic37uDWIi9WNKxqXk5wLUF9zhpBHR8AmXw22FJFHQ0EKBxIwkAjb7U7L+FOZU7uFNov/gbezFjQ=@vger.kernel.org
X-Gm-Message-State: APuU4Z9HEIvDaXSy7y2cKn7/eYYPPM0Ctj1xwDuxTCU/Pl8kMRtw9vcz
	41i3b2nPbr4WPqjnheV4y+httzOl6POI1Wm+wW4jTNQPFfgIqXbvWf0X2SHf2pB/EiTl
X-Gm-Gg: AYBFou2T3b3dejbNiifqGD70C45121Y2XBCENMd0PjAOMLR3sp+Nfl9UcF/Xt+BTkGU
	Zrkn5Q9qnI4Rq10UqdPDWea/KrIRFunkBx97pmZR46CvCAuF9RxG+KOgb13hJSB2SBl/ExVL1RB
	GMWp6dUjU62ZdB4Ml0nhv/C1GEXLU1IH76JbI8TxAKsa6n1sOmeGDW69OROviqwiYDJs7zQUrhJ
	5gRf1KzRu3+HsQ/EDUjoLHvghkEb/9zCq8xgrfZ/HnnBTDA6h6C7ZHvqMxZYqw3HkA3IDv3Qaub
	cXCXuZ71dr0ZnwBJFR8XwpmvxpvPcseCMwUyrTBUUmMhBf5K3QUgRtK4aAinNVRdWv3IaCxUgKM
	3S+gM+uG6EEneex62+xua3Aop/uWcElbyt3Y0vS9TSbKL0olfYofDoNlgqAR3qKZtcKLJRk1n/u
	xYThkv1ERlDlkOEtK5RgpdNUDf4ROYZuTLOJ2f92+xdUEb96QCdL97IFgsYTxwQGDs0Yvqfb8wl
	/xfZhuazVhm+DwrLasod4gTYVg4P4avkcb42cfTAyyqAuJmWkleW98YX9XGwQh8Wm4Y9NvD3YNq
	PSh6QmjjwauSuenVfYsvwhz4yj4+LX1kJilpSiU9kZi7k7u+5u9BzBmkcMuCFgo=
X-Received: by 2002:a17:907:7b8c:b0:c42:bc58:f21 with SMTP id a640c23a62f3a-c50963856f2mr175546966b.15.1794564221164;
        Fri, 13 Nov 2026 02:03:41 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c5095b23b3asm74752966b.27.2026.11.13.02.03.39
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:03:40 -0800 (PST)
Message-ID: <cfcbef5caf7651b63774549fa1999d34981c78a4.camel@amutable.com>
Subject: Re: [PATCH RFC 09/41] bpf: use fc_init_pseudo() for bpffs
From: Alexander Mikhalitsyn <alex@amutable.com>
To: Christian Brauner <brauner@kernel.org>, linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, Josef
 Bacik	 <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>,
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org,
 target-devel@vger.kernel.org, 	driver-core@lists.linux.dev,
 linux-mm@kvack.org, bpf@vger.kernel.org, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org, 	fuse-devel@lists.linux.dev,
 linux-efi@vger.kernel.org, 	xen-devel@lists.xenproject.org,
 ocfs2-devel@lists.linux.dev, 	linux-s390@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, 	linux-usb@vger.kernel.org, Amir Goldstein
 <amir73il@gmail.com>, 	linux-erofs@lists.ozlabs.org,
 linux-kselftest@vger.kernel.org
Date: Fri, 13 Nov 2026 11:03:39 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-9-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-9-4c998976c6c7@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.56.2-0+deb13u1 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Tue, 2026-11-10 at 10:14 +0100, Christian Brauner wrote:
> Initialize bpffs as a pseudo filesystem instead of raising
> SB_I_NOEXEC and SB_I_NODEV by hand. This adds SB_I_PSEUDO.
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>

> ---
> =C2=A0kernel/bpf/inode.c | 4 ++--
> =C2=A01 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
> index c6f328e4752e..57cf3775c076 100644
> --- a/kernel/bpf/inode.c
> +++ b/kernel/bpf/inode.c
> @@ -15,6 +15,7 @@
> =C2=A0#include <linux/namei.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/fs_parser.h>
> =C2=A0#include <linux/kdev_t.h>
> =C2=A0#include <linux/filter.h>
> @@ -1197,8 +1198,6 @@ static int bpf_fill_super(struct super_block
> *sb, struct fs_context *fc)
> =C2=A0	sb->s_magic =3D BPF_FS_MAGIC;
> =C2=A0	sb->s_op =3D &bpf_super_ops;
> =C2=A0	sb->s_xattr =3D bpf_fs_xattr_handlers;
> -	sb->s_iflags |=3D SB_I_NOEXEC;
> -	sb->s_iflags |=3D SB_I_NODEV;
> =C2=A0	sb->s_time_gran =3D 1;
> =C2=A0
> =C2=A0	inode =3D bpf_get_inode(sb, NULL, S_IFDIR | 0777);
> @@ -1261,6 +1260,7 @@ static int bpf_init_fs_context(struct
> fs_context *fc)
> =C2=A0	opts->delegate_attachs =3D 0;
> =C2=A0
> =C2=A0	fc->s_fs_info =3D opts;
> +	fc_init_pseudo(fc);
> =C2=A0	fc->ops =3D &bpf_context_ops;
> =C2=A0	return 0;
> =C2=A0}
