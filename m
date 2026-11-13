Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794564705;
	b=chg2nP52kluitD4QHCci0jlS1ST8JNq/hhXzPLIXW4oIe6ykQAhBNAgnhClHMS21G6S4
	 VBRaZZc0MCOPk2FxIuF4yd9UvLS1YETwkIlLmDXrUHCxbq9E8bgzJp7ivyE3yehiARRJ7
	 exND7tl8cD/pABiBs7kZnO1gBsn9w/a7tYAWcdup7a15zKe9Gr4C3/8OznmQRfyIFOSNr
	 nKfDJlvyWqSmvXptmRqbiOC7rI3vQgIsXUV1RKYf/lsVXqkl6PPtQcMbwmMgiW2kRhTBP
	 qo+l6bZdt9AcbsuKT+HTHBqDutiVPv3tjB2sztuIYAuxSpzh0LduBhBlgZ1ozMBEsQw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794564705;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=gXMsjTg9KyNTuX1cuQ9yr2iJq2/VClhNCtHhh+FL0ZU=;
	b=Tvywd7i5kUcS/H0vgUsH+najfPiJNQBL1c9EK7cIGMHKSnvAAZ8yewpJGCcvFbwn9L5X
	 Grwmzt0XfZ5C0viKviGHVz9da17Z18Tih03+d/hKxo0gPXp32ayU56IurIpRY5jY66cJA
	 35O8m6BfKqrF/CWEL/9gZqO/oIBS2S/HFiYQ+Fsy0ipSESWCiG54TIynE/Pl4rRL+qSgD
	 wHV9qxFV8wvUUQzssBtNFAPexLZM1cQCiF+sUwOrXxR6Y6BI7GqS9kBj8cu99zaYSB8gU
	 O+jGDwp/Oxbr3mdUISeM43i446ipbiO9t24GkXQRrlIfZcO45jC50Iz7YuvUT9Y9Fzw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=amutable.com;
	spf=pass smtp.mailfrom=amutable.com;
	dkim=pass header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=BADxd+iU;
	arc=none smtp.remote-ip=209.85.221.53
Received: from mail-wr1-f53.google.com (mail-wr1-f53.google.com [209.85.221.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 930ED606A88C
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 10:11:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 930ED606A88C
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=amutable.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amutable.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=amutable-com.20260707.gappssmtp.com header.i=@amutable-com.20260707.gappssmtp.com header.a=rsa-sha256 header.s=20260707 header.b=BADxd+iU
Received: by mail-wr1-f53.google.com with SMTP id ffacd0b85a97d-497614c95f0so327662f8f.1
        for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 02:11:44 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amutable-com.20260707.gappssmtp.com; s=20260707; t=1794564703; x=1795169503; darn=vger.kernel.org;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=gXMsjTg9KyNTuX1cuQ9yr2iJq2/VClhNCtHhh+FL0ZU=;
        b=BADxd+iUI5Bylfm9xHmZjb4pgHg0fbyWkyp8vNCt747iYknkt4pGGRNYLQ78EH/z4x
         Vbi/Jq3+E8iOs58TJRk6WPlWSpFf2OpeZbjgHeXjXzKeHm9XnJ+eEvU2VLt6liCBRq7I
         79Td6VY4SiSTAXWOIivpd5ztVkC+DBAB/J4OfHn49+YeU7s/KQ9yNfnwb8sPZOTKoGu0
         Zirp8LScbJznGaQAXzatlGuiy/pBfqScnET/jGobuhYjlwMbyAqyeVJ7smTe1nJkO+dB
         h89eeA8CIS4pNdPKyjqDo55n+EKX5qBSzrC2C/95dZzzzQLBvHRJ+46c+P8Bzg/7r93a
         +u0Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794564703; x=1795169503;
        h=mime-version:user-agent:content-transfer-encoding:content-type
         :references:in-reply-to:date:cc:to:from:subject:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=gXMsjTg9KyNTuX1cuQ9yr2iJq2/VClhNCtHhh+FL0ZU=;
        b=D6TZ9Jud9VOX0dULm3SC0/XoID1/nLkCD4dpK3nIB0UINsdrKMIhPOmQUGlNd+LqxW
         uiLOFIQYHPTlhKHxSSzLL6AFsu0C9Ptcp/urgL70LfJL9Crjk7pDtub55BX2jM7XejG9
         76ULP0WnC51yBYzhcclYSCjZG7uHi0NFKhRq9C+2QNWdjDMtYb5T9dGEPhK8V+dUBcyO
         pvokdqrMZEU51hiGqchpJSHbTq4PX2yUIvXMcF70KhGuAmoBCY989GyEF6dzaGOxc18C
         rLtIaBxbqu17ENi5zyLZQsllMCB9fGKbfDlCIhjnMMssOB3w2PnbpjYnAgE3/r3dDa8x
         9fLA==
X-Forwarded-Encrypted: i=1; AL+hErEXyJgoR0u3RQda5Owv1R3oeOPMYIPf3xW9avHD0rdjJFHV1VhA4ynfDFU6EfuouBl7MwY86s26Mtg=@vger.kernel.org
X-Gm-Message-State: APuU4Z8HQ3Vxcp4AX8Ws4CwZu9GxGQRddG9/i6nzdOSBa8FIUoHDQcVY
	nypofnw5NKwM6+9vHGwU70k4zoNOGrNb6UTSYttpm1UL0EtIMtmO4MxUC8u1ReYzb27+
X-Gm-Gg: AYBFou3i7C22k1IXY7e/3XX557pwsSXYDeBXI3/b/YRqD6hYy9WMGi3npwKwqLXhBb0
	HTwrc7iRxTUn2V7yjkI4tBzNRytboVfWP19rPeZuA/dLkyoWJaRjZeaPMA8E45VAmdlBkp56HHP
	+cNNJTTN9I2nr705fmhRTd2mcUhobFmAZ2mjwuS3gfJ0tosttIPCgz+eEfvBPBDWkGKG0q9j/MR
	VW7yOOGZHRPu/KkeFMm6uDbGI6y91TbbJx4rhTAbGxqOsxU6BxKqRWf6K+qoqFtF3RhFhT5yXHj
	dhxSNOjc/s3eUleGDKmcIef2Ig2CBCg5OmuLI97kfkbgErG42Q6ii8TD498KxTv/D+gnW5qJ4nb
	MF9bu4aEMM3RzltQ5D+mxi+k7jF3/8muRRdnUHxIeVcQ6iSbiRaQ48d4BYOwZUnbL2dwHikXY4+
	DOx9H+41xrCFGDxhX3LgdVyROf2W54w6VoY8PrHF9cl2jkG4pHIfeheuDnZ28ePE0eJs9lDU59I
	fwWoNlNR2EFFyCGNbf/QW0mAcz/VaxcaCHA6IINGrRB03UDkMX2OQcB4d5MzBKLdD7FDZwSPlxO
	GKaG8lgU5nGloAnN21u8EO5ze/x/rQhsxkSF0kehrl1dOpZq0JedWYbsyGM5SNk=
X-Received: by 2002:a05:6000:2501:b0:488:88ec:59c3 with SMTP id ffacd0b85a97d-49c73259cc3mr5012611f8f.14.1794564703010;
        Fri, 13 Nov 2026 02:11:43 -0800 (PST)
Received: from [10.0.0.233] (tmo-086-54.customers.d1-online.com. [80.187.86.54])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c5f1c1797sm4931434f8f.11.2026.11.13.02.11.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 13 Nov 2026 02:11:42 -0800 (PST)
Message-ID: <ff6d2a8c8623f5476d5c352dac1ad98ab3da303c.camel@amutable.com>
Subject: Re: [PATCH RFC 18/41] selinux: use fc_init_pseudo() for selinuxfs
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
Date: Fri, 13 Nov 2026 11:11:40 +0100
In-Reply-To: <20261110-work-loop-pseudo-v1-18-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
	 <20261110-work-loop-pseudo-v1-18-4c998976c6c7@kernel.org>
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
> Initialize selinuxfs as a pseudo filesystem. This raises SB_I_PSEUDO
> and
> SB_I_NOEXEC. selinuxfs never holds executables. SB_I_NOEXEC also
> refuses PROT_EXEC mappings but the status and policy files are only
> ever mapped for reading.
>=20
> But selinuxfs needs device nodes. The kernel replaces file
> descriptors
> with /sys/fs/selinux/null on exec via dentry_open() which doesn't
> care
> about SB_I_NODEV. Android init however opens /sys/fs/selinux/null by
> path as /dev/null doesn't exist yet at that point. So clear
> SB_I_NODEV
> again in sel_fill_super().
>=20
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Reviewed-by: Alexander Mikhalitsyn <alex@amutable.com>
   I.=20
> ---
> =C2=A0security/selinux/selinuxfs.c | 5 +++++
> =C2=A01 file changed, 5 insertions(+)
>=20
> diff --git a/security/selinux/selinuxfs.c
> b/security/selinux/selinuxfs.c
> index 310e19efff1d..d7ae853b6d68 100644
> --- a/security/selinux/selinuxfs.c
> +++ b/security/selinux/selinuxfs.c
> @@ -18,6 +18,7 @@
> =C2=A0#include <linux/vmalloc.h>
> =C2=A0#include <linux/fs.h>
> =C2=A0#include <linux/fs_context.h>
> +#include <linux/pseudo_fs.h>
> =C2=A0#include <linux/hex.h>
> =C2=A0#include <linux/mount.h>
> =C2=A0#include <linux/mutex.h>
> @@ -1852,6 +1853,9 @@ static int sel_fill_super(struct super_block
> *sb, struct fs_context *fc)
> =C2=A0 /* last one */ {"", NULL, 0}
> =C2=A0 };
> =C2=A0
> + /* Android init opens the null device below by path. */
> + sb->s_iflags &=3D ~SB_I_NODEV;
> +
> =C2=A0 ret =3D selinux_fs_info_create(sb);
> =C2=A0 if (ret)
> =C2=A0 goto err;
> @@ -1955,6 +1959,7 @@ static const struct fs_context_operations
> sel_context_ops =3D {
> =C2=A0
> =C2=A0static int sel_init_fs_context(struct fs_context *fc)
> =C2=A0{
> + fc_init_pseudo(fc);
> =C2=A0 fc->ops =3D &sel_context_ops;
> =C2=A0 return 0;
> =C2=A0}
