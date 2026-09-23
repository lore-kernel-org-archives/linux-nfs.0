Received: from fhigh-a8-smtp.messagingengine.com (fhigh-a8-smtp.messagingengine.com [103.168.172.159])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 08AB53B8BD1;
	Wed, 23 Sep 2026 04:08:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.159
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790136487; cv=none; b=qAjBMrzFwKsjuqDru5GJYDtvjO2NT7FyNVacE9As42aoEezaBBZmP6wtjVU/muSRJ4ncBU4StaUhbeazCd3mY1/b1h+ZmLdanu+voE3n7ZOx6fzGgLaUig+3A+Dv9NR9YENqlvXRavqImQBRj8Fj6+rbSO/KPiQTfSZIfzJ3Vp4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790136487; c=relaxed/simple;
	bh=Lj2Fbi+FXV/wCuoVFmvECm7gyCHyX3Bw8bz5HdWW7VE=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=E/gfvcEwZjW2jZbJAMzxH7lnI4VwcuoNlJkzsyXpCJx8G8CPJmLp9qti4GH57fgh/cDOPLaKiAAEPar7W+o3tjjtpDfVmNFXhy5WkqITMhb+Lu+b6TLgMMr7WiVIh2vYa3wl5UZdD77TxaXyx8uMRZTgFL8SbyoGVS7oGu7QRjs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=kh+sFNNG; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=P9KzoJv4; arc=none smtp.client-ip=103.168.172.159
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="kh+sFNNG";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="P9KzoJv4"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 2499B1400141;
	Wed, 23 Sep 2026 00:08:04 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Wed, 23 Sep 2026 00:08:04 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790136484; x=1790222884; bh=7687imxnyqYKdQpZxfQERznnhqWc2eAJVdr
	7Tc4rXhY=; b=kh+sFNNGAmnfao1CYC27RR/Rrv0bFXkl1ahzJ9eKRjWeVYrwZXU
	qKJmi/aONgLfLscqbk2fPGp5uDUQ4yHYfagZ3G1T3i8lVexU0c/JwAmPBCLrP++e
	ATqw2FA0XnxEcZ/wG/DR49LH9WYFlmO2iEYdGyaJVyUvr0JWE03rf37PFCzkGYQz
	dgzbd2jaNHhVvc67vYgDPVPrx3eXqU2OuP/zuP9cz/zaqY8fnyrFIeIyuQRsxZKP
	f0IdqUr8cv7JD1HuY9BrGNd9IizPsTCoMB38uFk8oDuGEDmLh1F7qDcXnOJpg+eY
	YqRPhJpnGGnjWU/KrqTIJVNXQG0M3c3Qngw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790136484; x=
	1790222884; bh=7687imxnyqYKdQpZxfQERznnhqWc2eAJVdr7Tc4rXhY=; b=P
	9KzoJv4IZk8PVHQF46ymMzIEDt1RSXzmTTjjvNGpfH7AuVLREMbOwers5/aOCoX/
	Ofu3CZYgFHrTwufoozkcfnjhUk6CGU0LK2ZRhDtf8pLhQumQ7pF7mAGqMmJIbIlh
	r9Oaap/SOI3TE8q9kKltBN3nr4xJaRrPp1xQufhpgSVL1zQxk+4vkPd53jgt+ajC
	JmIp43HZZGtpCfWxWLGpvy2W2hT406jLDnDtN6u7tanYSh/R/IC2dPcISpd95j3s
	1+ZsNVDoB34ux1ixZLEatEXZfShM4ljUJp+J+CDiveqtmEXK8Ud4+4FydIu6Ce4j
	0KkwsrHkBQrlJj6VSwxOw==
X-ME-Sender: <xms:o1CzapEuTKIwuw8xvwbjFNlLZ55LhoItbb20NNfheNu7FccAauCGZA>
    <xme:o1CzauvNAAJZdedNrem1ZyIzMEkyy6eHwR-c0OaSgnhJ7UyHQv8rB4-Fdy7VNy9An
    nzM53bdLpPx20Y-L3ck0cxDaXlwra1w1_YIyGfd9CYCENS4M1I>
X-ME-Received: <xmr:o1CzasTctrB74IdzRCPIB73vy6J1FQsA7OHZtbQQ8bO0DICc3K8cbuyqMO2saZqDE55ZhLSLofqTn6bxpNfN8dV8Rt2ndIY>
X-ME-Proxy-Cause: dmFkZTGbKx1XIXuhovXsOSwhyPjNh41Q9u4cakwDNfVJjNkwbDrNAtWoxM04p8iMx0qiBQ
    y+36mEHzF5zS2+s4Vrw4e2IK9wxnkBlKgMXTbJRlrmgP58LyxFL/OOx8OmJioaZamDGd7p
    G7vSyPLmo/RSoX/9P0zHrmRfKoU+0sDeFwLWywIbuY8tw44Z6yIp/mUKS942b0QQwYBOBK
    8y7vmE2VgV6WztR+qw0ubdByPIadsQTS4Xnjusn6L5FHb7ZKtVGNxNCkNeNcTn8/Ik6dKH
    suNCv1nSCIETpR1JuQzSNAFtrdR/ncDEq1fnONM8+pTRBmRgMo5Rf5lNNLPOK1JRH/f5pl
    KhDSxRimALbxxrxsroq2NlUW1WdVybhvRi92l+McD9LLSY+eYoPA9TytqRrezz4kGFZ/+3
    AmpSNDa1haJ7waZmladBXHSS1ElyNpQJbu3nPm9PVc7NcY1iF3ftRvXTZBhwTAFu9+8r4G
    jp1weJ9PvNkm6uBTlN8HZ4q2ZSO6CFpDCn96tPd+o2eOUm0lXxBdieSYkkIcWVXzKsp1OJ
    261CIXIBPTZbsgWkN/kO0IQtivXXWYg/WQMNPEf17oXhkhVnLGm3ktvc+iciEmehyRPba3
    9xCHossQkQx7pg7QAKblIEZ9evpUwd98rITeZozetSMCP898h8Nh7UNwgx9g
X-ME-Proxy: <xmx:o1CzarHItaJl8qqFanzU9wfA58PtKXXUOXyJDINzJzjgeXeGZp2yMg>
    <xmx:o1Czaud9ELZDeerJFxr5Rdvxb_J_QWVQaSOT35ffqmIDZCendtZD5Q>
    <xmx:o1CzaivN0mMDE0rHH4I-xlrU3yVRdvqAz9k79-SdH1zPdvu1RKvO9A>
    <xmx:o1Czasea35jc1LbX0eX-ANze4Xv99LSmuEvMs7a-w4xTHA9sKLd12A>
    <xmx:pFCzav7FHC8KsomHiwqMW6kpzZ3yCbh00Mn8ManHi-hEKyJjYAT-gXUr>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 23 Sep 2026 00:07:57 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Jori Koolstra" <jkoolstra@xs4all.nl>, "Mateusz Guzik" <mjguzik@gmail.com>,
 "Dorjoy Chowdhury" <dorjoychy111@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Andreas Gruenbacher" <agruenba@redhat.com>, gfs2@lists.linux.dev,
 "Ilya Dryomov" <idryomov@gmail.com>, "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
 "Paulo Alcantara" <pc@manguebit.org>, "Namjae Jeon" <linkinjeon@kernel.org>,
 linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 12/14] nfsd: switch NFS4 OPEN to use vfs_lookup_open()
In-reply-to: <179011412461.37859.5169498575115711178@noble.neil.brown.name>
References: <20260919022441.3305170-1-neilb@ownmail.net>
  <20260919022441.3305170-13-neilb@ownmail.net>
  <0b2597f9-2af1-448d-9bff-c9a96a07068b@slotpi15m67>
  <179011412461.37859.5169498575115711178@noble.neil.brown.name>
Date: Wed, 23 Sep 2026 14:07:52 +1000
Message-id: <179013647294.37859.820765753524082731@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 23 Sep 2026, NeilBrown wrote:
> On Mon, 21 Sep 2026, Chuck Lever wrote:
> >=20
> > Can this fail an OPEN that nfsd_permission() would have allowed?
>=20
> Yes.  As you explain in detail (thanks) this is a problem.
>=20
> This highlights a problem with using nfsv4 to re-export a remote filesystem.
>=20
> Any non-standard permission checking we do in nfsd to handle reading
> execute-only files, or opening recently created files without the
> requested access, also needs to be performed on the server for a
> re-exported filesystem.
>=20
> Re-exporting NFS is probably safe because nfsd is already relaxed about
> these permissions, with NFSD_MAY_OWNER_OVERRIDE and NFSD_MAY_READ_IF_EXEC.
> But other filesystems may not be.
>=20
> I wonder if we should communicate this through the VFS so we can at
> least tell ->atomic_open and ->permission that it can be a little
> relaxed about certain permission checks...
>=20
> I don't know what is best, but will dwell on if for a while.

This is the sort of thing I'm thinking of.
The FMODE_SERVE_FILE flag isn't used at the moment but it could be.
e.g. nfs4_opendata_access() could use it to allow an FMODE_READ open
to be satisfied by NFS4_ACCESS_EXECUTE.
Currently if you re-export NFSv4 and the client tries to execute
a file which it doesn't have read-access to, then it will fail.
I haven't actually tried this - maybe I should.

Anything reflections on this approach most welcome.

Thanks,
NeilBrown



diff --git a/Documentation/filesystems/vfs.rst b/Documentation/filesystems/vf=
s.rst
index 4a58450d8310..6afb7cdb2be8 100644
--- a/Documentation/filesystems/vfs.rst
+++ b/Documentation/filesystems/vfs.rst
@@ -642,6 +642,11 @@ otherwise noted.
 	FMODE_CREATED should be set if it is possible that this operation
 	created the object.
=20
+	If atomic_open() calls finish_open() then it must have performed
+	all necessary access permission checks.  If FMODE_SERVE_FILE
+	is set in file->f_mode, this it should assume MAY_SERVE_FILE if=20
+	possible.
+
 	This method is only called if the last component is negative or
 	needs lookup.  Cached positive dentries are still handled by
 	f_op->open().
diff --git a/fs/namei.c b/fs/namei.c
index 8ef2d44b6108..16c6ee8cfd74 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -441,6 +441,11 @@ static int acl_permission_check(struct mnt_idmap *idmap,
 	unsigned int mode =3D inode->i_mode;
 	vfsuid_t vfsuid;
=20
+	if (mask & MAY_SERVE_FILE) {
+		/* 'x' permission grant 'r' permission */
+		mode |=3D (mode & 0111) << 2;
+	}
+
 	/*
 	 * Common cheap case: everybody has the requested
 	 * rights, and there are no ACLs to check. No need
@@ -468,7 +473,12 @@ static int acl_permission_check(struct mnt_idmap *idmap,
 	if (likely(vfsuid_eq_kuid(vfsuid, current_fsuid()))) {
 		mask &=3D 7;
 		mode >>=3D 6;
-		return (mask & ~mode) ? -EACCES : 0;
+		if (likely((mask & ~mode) =3D=3D 0))
+			return 0;
+		if (mask & MAY_SERVE_FILE)
+			/* Owner always gets access */
+			return 0;
+		return -EACCES;
 	}
=20
 	/* Do we have ACL's? */
@@ -4652,6 +4662,7 @@ struct file *vfs_lookup_open(struct path *parent, struc=
t qstr *last,
 	file =3D alloc_empty_file(open_flag, current_cred());
 	if (IS_ERR(file))
 		return file;
+	file->f_mode |=3D FMODE_SERVE_FILE;
=20
 	nd.path =3D *parent;
 	nd.last =3D *last;
@@ -4666,6 +4677,7 @@ struct file *vfs_lookup_open(struct path *parent, struc=
t qstr *last,
 	op.acc_mode =3D ACC_MODE(open_flag);
 	if (open_flag & O_TRUNC)
 		op.acc_mode |=3D MAY_WRITE;
+	op.acc_mode |=3D MAY_SERVE_FILE;
 	dentry =3D lookup_open(&nd, file, &op);
=20
 	if (IS_ERR(dentry))
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f9d1e05e8ae6..83c36a5dc51f 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -98,6 +98,8 @@ typedef int (dio_iodone_t)(struct kiocb *iocb, loff_t offse=
t,
 #define MAY_CHDIR		0x00000040
 /* called from RCU mode, don't block */
 #define MAY_NOT_BLOCK		0x00000080
+/* Passed by nfsd - owner may have any access, X access gives R */
+#define	MAY_SERVE_FILE		0x00000100
=20
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspo=
nd
@@ -120,8 +122,8 @@ typedef int (dio_iodone_t)(struct kiocb *iocb, loff_t off=
set,
 #define FMODE_WRITE_RESTRICTED	((__force fmode_t)(1 << 6))
 /* File supports atomic writes */
 #define FMODE_CAN_ATOMIC_WRITE	((__force fmode_t)(1 << 7))
-
-/* FMODE_* bit 8 */
+/* File used to serve file to a client, so MAY_SERVE_FILE applies */
+#define FMODE_SERVE_FILE	((__force fmode_t)(1 << 8))
=20
 /* 32bit hashes as llseek() offset (for directories) */
 #define FMODE_32BITHASH         ((__force fmode_t)(1 << 9))
