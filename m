Received: from mail-10628.protonmail.ch (mail-10628.protonmail.ch [79.135.106.28])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AEA9F23C51D
	for <linux-nfs@vger.kernel.org>; Tue, 24 Feb 2026 02:09:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=79.135.106.28
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771898972; cv=none; b=jXEKxt/v+MSU9mpxrCdXz/qQvZskrmZWpx0XuPXwvJYH/LXHa4QTCe3Jq4OK9aNAXqwrpC7H/0chvZh/1tKwXJ3HW5CKFOW7UVgsxkv4yf0bfD+pTJysePGrrFdmJwcuXTythB7UEPkdXtf2q0NCfEz+rtCrJpzXOktfz4YJysI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771898972; c=relaxed/simple;
	bh=xm6jH84Xqhv4PsVB+ToFxuPD5b/FmDOyr90R6DBa11g=;
	h=Date:To:From:Cc:Subject:Message-ID:MIME-Version:Content-Type; b=K9jJRy0oztxyeF33Uv7ZNQqZ73t5w5H4z7TA+qZzQOIWi6NFiOtLdBoQeoY7b20UFMgHihxn7+1PFQi8XftXKo1UsudR1vHl8hiaoXtnNGKU8DDK1kb5a93ekW0X+Ao6+NEDgdP5FT13MXqVV+gSEbf8uXXapbQ6nhqakh85v94=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=proton.me; spf=pass smtp.mailfrom=proton.me; dkim=pass (2048-bit key) header.d=proton.me header.i=@proton.me header.b=R26zEOeq; arc=none smtp.client-ip=79.135.106.28
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=proton.me
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=proton.me
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=proton.me header.i=@proton.me header.b="R26zEOeq"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=proton.me;
	s=protonmail; t=1771898960; x=1772158160;
	bh=xm6jH84Xqhv4PsVB+ToFxuPD5b/FmDOyr90R6DBa11g=;
	h=Date:To:From:Cc:Subject:Message-ID:Feedback-ID:From:To:Cc:Date:
	 Subject:Reply-To:Feedback-ID:Message-ID:BIMI-Selector;
	b=R26zEOeqeDzeraIswDxw0NQCWO8iJlvKX2QGb0vJRrAdLJWvkFwg0R/yHe8KvHR4o
	 hYV9+LPZq4LHVE+MPxVXWYclOZKLuMxzQ3f77HgNytU97wKrmYXKPEAox4e1t9sp4r
	 KpUInOqUZWkkiagnzWVQ4wqRYxm/GhvqQjx0POghRkqtPVyN54lzBXfC8plb+mbPpl
	 Vd7x9La6mdbEtoLbsHZvFqqVuMMMwlTZaYNVAqxdo0WYcE8dYKiO5HzRakmGVVkvBL
	 wpodRAChvyceZsInNJHFEYh0F+eca0r1DDnv81Jk0KLVclIKHMWdNYzuRH8XabWpeT
	 u7AMZXbHYoAvA==
Date: Tue, 24 Feb 2026 02:09:15 +0000
To: 1128861@bugs.debian.org, Neil Brown <neilb@suse.de>
From: Tj <tj.iam.tj@proton.me>
Cc: linux-nfs@vger.kernel.org, Olga Kornievskaia <okorniev@redhat.com>, stable@vger.kernel.org
Subject: Regression: Missing check in nfsd_permission() causes -ENOLCK No locks available
Message-ID: <c0f15088-3fc0-487a-9f24-cf89c158420d@proton.me>
Feedback-ID: 113488376:user:proton
X-Pm-Message-ID: 070dfc1e520590817ffbb2e91b91c20970ddd6d0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Upstream commit 4cc9b9f2bf4dfe13fe573 "nfsd: refine and rename=20
NFSD_MAY_LOCK" and
 =C2=A0stable v6.12.54 commit 18744bc56b0ec=C2=A0 (re)moves checks from=20
fs/nfsd/vfs.c::nfsd_permission().

 =C2=A0This causes NFS clients to see

$ flock -e -w 4 /srv/NAS/test/debian-13.3.0-amd64-netinst.iso sleep 1
flock: /srv/NAS/test/debian-13.3.0-amd64-netinst.iso: No locks available

Keeping the check in nfsd_permission() whilst also copying it to=20
fs/nfsd/nfsfh.c::__fh_verify() resolves the issue.

This was discovered on the Debian openQA infrastructure server when=20
upgrading kernel from v6.12.48 to later v6.12.y where worker hosts (with=20
any earlier or later kernel version) pass NFSv3 mounted ISO images to=20
qemu-system-x86_64 and it reports:

!!! : qemu-system-x86_64: -device=20
scsi-cd,id=3Dcd0-device,drive=3Dcd0-overlay0,serial=3Dcd0: Failed to get=20
"consistent read" lock: No locks available
QEMU: Is another process using the image=20
[/var/lib/openqa/pool/2/20260223-1-debian-testing-amd64-netinst.iso]?

A simple reproducer with the server using:

# cat /etc/exports.d/test.exports
/srv/NAS/test=20
fdff::/64(fsid=3D0,rw,no_root_squash,sync,no_subtree_check,auth_nlm)

and clients using:

# mount -t nfs [fdff::2]:/srv/NAS/test /srv/NAS/test -o=20
proto=3Dtcp6,ro,fsc,soft

will trigger the error as shown above:

$ flock -e -w 4 /srv/NAS/test/debian-13.3.0-amd64-netinst.iso sleep 1
flock: /srv/NAS/test/debian-13.3.0-amd64-netinst.iso: No locks available

A simple test program calling fcntl() with the same arguments QEMU uses=20
also fails in the same way.

$ ./nfs3_range_lock_test=20
/srv/NAS/test/debian-13.3.0-amd64-netinst.{iso,overlay}
Opened base file: /srv/NAS/test/debian-13.3.0-amd64-netinst.iso
Opened overlay file: /srv/NAS/test/debian-13.3.0-amd64-netinst.overlay
Attempting lock at 4 on /srv/NAS/test/debian-13.3.0-amd64-netinst.iso
fcntl(fd, F_GETLK, &fl) failed on base: No locks available
Attempting lock at 8 on /srv/NAS/test/debian-13.3.0-amd64-netinst.overlay
fcntl(fd, F_GETLK, &fl) failed on overlay: No locks available


