Received: from mail-ej1-f51.google.com (mail-ej1-f51.google.com [209.85.218.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A433942B324
	for <linux-nfs@vger.kernel.org>; Sun, 11 Oct 2026 09:41:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.51
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791711705; cv=pass; b=kvVFbDbSo9X/vRV9aMDmdw6gLUh6fG21/UJ+U6CjXiDIgdT1784MC5skmBoYKx1sqHEpbW6kmKuUnhUt9tcAMTAd1XUFejDcrEYwR/HCvFaPy8RSAmQuIxuquZ3mk9LAPZZ2QgUWV2DHIXGC8QSI1CATLh7zuYJ05fcfBQ8maJw=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791711705; c=relaxed/simple;
	bh=+0/wC2P1sBiZBSlz4MO89ZW9Q1VNULVBR4nQmWrzLBE=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=lgJ2mK/RM7HAqPeZGWIrFWVpYsaDCRz8Mb9DW3RYN9qYDo9S4Bgjw/IgpmK9R7y+OUXy/dJ+V3w9tYulWqSd2Cb1zA+kTEOoNRZNPzGpn4vzjZs4U6OFcgkPeG1nLfFK8cLGnFYZbHpjq1hK+6ViVCejDHSFzVke+Bb4aXsHimM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=OYUVDWDD; arc=pass smtp.client-ip=209.85.218.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OYUVDWDD"
Received: by mail-ej1-f51.google.com with SMTP id a640c23a62f3a-c2dc63f8d8aso174146666b.0
        for <linux-nfs@vger.kernel.org>; Sun, 11 Oct 2026 02:41:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1791711701; cv=none;
        d=google.com; s=arc-20260327;
        b=OkePhaQaejjcvu16jVHiGLG28LjV0K75OURwX8UlaJZUDAdBlxJix+nbxUEW7OKbt8
         4IS8S4elfaTxaUVIm5kvvi9McgrkuuyxLZHi+INSwyXnbTLoZ2KJaLofC30Ka4+exbFs
         q6NY4LIiDSVuUcSHboBMzRk9eRMmavkVZtFcMV6sowDdM5ZNUNMTPW11l6LSB96a3CaS
         qAdKXQSbZfB41QEC1TnLQlKBSPv0wf8ly4nF3UrIDNmImflLrzFjcUyde0Za17KLrx+z
         gf2LsCVv/Uif2KYV6aPRRdoQkO3EbKphCYQKEqDCP51FINCZZGbidVriGdjCWHmCQZ0s
         o7Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ZA0UDoj8CNA0VByif2bup5iXTFjD+81/G74dWuGFqT0=;
        fh=a1YeqGAUch5LOLmR4fcsD5q8uKp1zOhgvbXsEjBPNhg=;
        b=JlUr3gtxp7ZGLkomq+xAAzl5yKpW0ia3mssq1lw0xOPyfzm+AW19LGMcRFaZDHyUng
         trrt1QZrX/B8VGNhSLxXwv8ZS2h/RIv2oauRwRfWaP8k5vWpcpoQ1k8JH2dpT1YhN7tb
         VcQ7P2Ro+tTbqGhKCAJ3RvPUvzDe4Lgjp1yCqu/LCgNA69Dj2aDCOMo+OWJUoiOQN+Zn
         h+osufh2OrQFChZxDwH3SuY2tR9NtKIJKo3Y3JazYV+Gt9v0DPxUd24CH/FtuybL8U75
         G76tXfKs18qcugFCBDgbdfTwMJ9fZLnS33SeRiifUhs9jBdWLV3X6JvZSB3w56uZE7uQ
         0i5w==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791711701; x=1792316501; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=ZA0UDoj8CNA0VByif2bup5iXTFjD+81/G74dWuGFqT0=;
        b=OYUVDWDD5wegLFEwJKjCgr3D3TdKQSaSlUioHO9nCG8gMsiEl3zbiDcd/7fjfPbzWs
         Ixw/79Vc7pSk0I5axV8uHf98drV2LiFodNkNwZebapa0/06Pgo30U2roIUPZ2QN/QdZX
         Lg/CCGlHxZvIZjaefk9JxqTLJe8dRrp1lCXjfW2rtMXZ/NlIG10sTnM/j0knUcoas05W
         8FJChaZUcgZ48M9bNvLkvPVxZkejbTAlX9S/khZKLp9WawjuvXhnrOKxPD2rg7KsyNNQ
         BYojAUvqGKEcapdu2p/sVV0u5PkAYZcCBkBtHU7zBiu5RAIUH3a7DlhZfmiYLeVG+930
         wdMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791711701; x=1792316501;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=ZA0UDoj8CNA0VByif2bup5iXTFjD+81/G74dWuGFqT0=;
        b=aFj8ASLR94ZBQ3te5b8PcUmnp974ETpf1U04NH254oLg4Qf+oyMoyI18NyqDSI4vCq
         kRxP8AfFYJUXBjhNSpZSRDI+Yz8nL69Fps0jSpEivSIlnoH0KJ5cPCQBaOf8QgU1T7pq
         QmpnpI/TRvxlYOCp/7CSsRUPPjZS/43+tTD+aW0r8llJnzaT/UNC9vbr9C/HKNsUcUZz
         b/6pCw/jssZ1Awp0Zp0WlJxYNFS1SnsfKmkiCX9d4Fdf249UHUvopnygUgriGw3oEwkd
         rf/2oFk7uyzLGJxLvjwei/ZZioJiEGNoxkJZhNYGf8pfeXyidU1VYqcfKY4WbYP4fvbX
         XQqQ==
X-Forwarded-Encrypted: i=1; AKwUvByXMG9aml7Xp8EGDqVcg+ZulTOh2Wa/p/Q2MgSKCUH2zl3IplnUmUoHOjjbAc0iV4WFnszZfX3CiMg=@vger.kernel.org
X-Gm-Message-State: AFq9FYJDvLw96t1I8DOikWpD455FNZXSsBYWHDpBGvES/1fEuYPDGeyJ
	GwNUwzLyLWHeWrR/q0QVvJPJPs+/cb2S9wpxlAVjPNalcgUvTMVrDk0ev0gF//1CQbt4Pemi46h
	tLQQopheYCD2mzWxqKX3okyB1u1Ot1QI=
X-Gm-Gg: AYBFou2AZKAR89zP5Gnt2hZTPmu+x7CMyA3v/6V51fFpj+NVsz+IplQ5XqdbyJrVBRI
	2Wm0odW6LsEfttXMAKxAsWX1cWlAd8cg+McfPAnVjP70ONGdfttHaNCeKA926wyRkJev+qrOaiK
	XT5ERx+UfUguqXIa6Rf9iAKntXpfJqaGm/ifcUrfeoAF+3zasQGNO4GS9PQOX1G7Qumgsej5KhD
	bhAl8O49iIqC+Di5ZrPx3yy1ribiCSaybRC/P1hN+a4xP60rMy1iU+7dxxUio7kX+K/a5IjsBY7
	qD9LOFAtcm5SLUNCT0vryHomMYFg24hPZM/TXz0FsqOg8N1WQUDryStWnmK91OfUBaOYhKyKS3b
	AlqFmd/YL0t5D
X-Received: by 2002:a17:907:3f8d:b0:c2c:d06f:cf87 with SMTP id
 a640c23a62f3a-c31aa0d3106mr630522266b.46.1791711700455; Sun, 11 Oct 2026
 02:41:40 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20261009-acl-mode-v3-0-ba487c5e66e0@kernel.org> <20261009-acl-mode-v3-8-ba487c5e66e0@kernel.org>
In-Reply-To: <20261009-acl-mode-v3-8-ba487c5e66e0@kernel.org>
From: =?UTF-8?Q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>
Date: Sun, 11 Oct 2026 11:40:00 +0200
X-Gm-Features: AclHuK9FIMe7pGhc-LWE7eoAz369yY2Jjmr0aPeJ2gkMCRNOQWFcheXweT5G_i4
Message-ID: <CA+1jF5pyuVULzoAjbfCLDjwwOwHQP7sG29G-dkG9ZSOdVShHWg@mail.gmail.com>
Subject: Re: [PATCH pynfs v3 8/9] Add tests for SETATTR with MODE and ACL
To: Chuck Lever <cel@kernel.org>
Cc: Calum Mackay <calum.mackay@oracle.com>, linux-nfs@vger.kernel.org, 
	Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

What about testing FATTR4_MODE_SET_MASKED too? IMO this is a better
way to set the mode, because it is atomic and might fit better with
ACLs because it only sets intended mode bits.

Aur=C3=A9lien

On Fri, Oct 9, 2026 at 6:35=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
> From: Chuck Lever <chuck.lever@oracle.com>
>
> Add comprehensive tests that verify SETATTR behavior when both
> mode bits and an ACL are set simultaneously. The new tests cover:
>
> 1. SATT19: testSetattrModeWithACL
>  - Sets MODE and ACL in a single SETATTR, once each with a MODE the
>    ACL widens (0o640, 0o600) and one more restrictive than the ACL
>    grants (0o400)
>  - Verifies both attributes appear in attrsset, the ACL is stored as
>    given, and the final mode is derived from the ACL rather than
>    taken from the requested MODE
> 2. SATT22: testSetattrACLThenMode
>  - Compares setting MODE+ACL together vs separately in sequence
>  - Creates two files and verifies consistent behavior
>
> These tests ensure that servers correctly handle the interaction
> between MODE and ACL attributes when setting file attributes, and
> verify that the ACL specified in the OPEN operation matches the ACL
> after the OPEN completes.
>
> SETATTR: ACL-to-mode verification tests
>
> These new tests verify:
>
> - Mode is correctly derived from ACL per RFC 8881 =C2=A76.3.2
> - Write bit requires both ACE4_WRITE_DATA and ACE4_APPEND_DATA
> - ACL evaluation order (first ACE takes precedence)
> - EVERYONE@ ACEs affect all three permission classes
> - Complex ACLs with multiple identifiers
>
> SETATTR: Two additional ACL verification tests
>
> New test SATT28: Verify that the final ACL is the same no matter what
> the file's previous mode bits were.
>
> New test SATT29: Verify that SETATTR(ACL) preserves high-order mode
> bits (SUID/SGID/SVTX).
>
> SETATTR: Verify behavior when setting both MODE and ACL
>
> Add three comprehensive tests that verify SETATTR(MODE+ACL) behavior
> per RFC 8881 =C2=A76.4.1.3:
>
> SATT30:
> Verify attrsset bitmap and final mode consistency when MODE+ACL set
> together. The server must report both MODE and ACL in attrsset, and
> the final mode must match what the ACL derives to per =C2=A76.4.1.3.
>
> SATT31:
> Test MODE+ACL interaction when they conflict significantly.
> Regardless of requested MODE, final mode always matches ACL
> derivation. This shows that ACL wins when both are set (per
> =C2=A76.4.1.3: "possibly changing the final mode").
>
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
>  nfs4.0/servertests/st_setattr.py | 728 +++++++++++++++++++++++++++++++++=
+++++-
>  1 file changed, 727 insertions(+), 1 deletion(-)
>
> diff --git a/nfs4.0/servertests/st_setattr.py b/nfs4.0/servertests/st_set=
attr.py
> index 5d51054c29b4..2dd496503f48 100644
> --- a/nfs4.0/servertests/st_setattr.py
> +++ b/nfs4.0/servertests/st_setattr.py
> @@ -1,9 +1,10 @@
>  from xdrdef.nfs4_const import *
>  from .environment import check, get_invalid_utf8strings
>  from nfs4lib import bitmap2list, dict2fattr
> -from xdrdef.nfs4_type import nfstime4, settime4
> +from xdrdef.nfs4_type import nfstime4, settime4, nfsace4
>  import nfs_ops
>  op =3D nfs_ops.NFS4ops()
> +import nfs4acl
>
>  def _set_mode(t, c, file, stateid=3DNone, msg=3D" using stateid=3D0",
>                warnlist=3D[]):
> @@ -783,3 +784,728 @@ def testMixed(t, env):
>      c.init_connection()
>      fh, stateid =3D c.create_confirm(t.word(), deny=3DOPEN4_SHARE_DENY_N=
ONE)
>      _set_mixed(t, c, fh)
> +
> +def testSetattrModeWithACL(t, env):
> +    """SETATTR with both MODE and ACL attributes
> +
> +    Per RFC 8881 Section 6.4.1.3, when both MODE and ACL are set togethe=
r,
> +    both are processed, but the final mode is derived from the ACL and m=
ay
> +    differ from the requested MODE. The requested MODE is varied from on=
e
> +    that the ACL widens to one more restrictive than the ACL grants.
> +
> +    FLAGS: setattr acl all
> +    DEPEND: MODE ACL0
> +    CODE: SATT19
> +    """
> +    c =3D env.c1
> +    c.init_connection()
> +    acl =3D nfs4acl.make_test_acl()
> +
> +    for mode in (0o640, 0o600, 0o400):
> +        fh, stateid =3D c.create_confirm(t.word() + (b"_%o" % mode))
> +
> +        # Set both MODE and ACL in a single SETATTR
> +        attrs =3D {FATTR4_MODE: mode, FATTR4_ACL: acl}
> +        ops =3D c.use_obj(fh) + [c.setattr(attrs)]
> +        res =3D c.compound(ops)
> +        check(res, msg=3D"SETATTR with MODE 0%o and ACL" % mode)
> +
> +        # Check which attributes were actually set by examining the repl=
y bitmask
> +        attrsset =3D bitmap2list(res.resarray[-1].attrsset)
> +
> +        # Verify both MODE and ACL were set (processed)
> +        if FATTR4_MODE not in attrsset:
> +            t.fail("MODE not in attrsset, but MODE 0%o was requested" % =
mode)
> +        if FATTR4_ACL not in attrsset:
> +            t.fail("ACL not in attrsset, but ACL was requested with MODE=
 0%o"
> +                   % mode)
> +
> +        # Verify ACL was set correctly and the mode derived from it
> +        attrs_dict =3D c.do_getattrdict(fh, [FATTR4_ACL, FATTR4_MODE])
> +        try:
> +            nfs4acl.verify_mode_and_acl(attrs_dict, acl,
> +                                        "SETATTR with MODE 0%o" % mode)
> +        except AssertionError as e:
> +            t.fail(str(e))
> +
> +def testSetattrACLThenMode(t, env):
> +    """SETATTR MODE+ACL together vs ACL then MODE separately
> +
> +    Per RFC 8881 sections 6.4.1.1-6.4.1.3, when MODE and ACL are set
> +    together in a single SETATTR, the server computes the final mode
> +    from the ACL (the MODE attribute is effectively ignored). When
> +    ACL is set first and MODE is set in a separate operation, the
> +    final mode is the explicitly-set MODE value.
> +
> +    This test verifies this difference by using a MODE (0o755) that
> +    differs from the ACL-derived mode (0o644).
> +
> +    FLAGS: setattr acl all
> +    DEPEND: MODE ACL0
> +    CODE: SATT22
> +    """
> +    from nfs4acl import acl2mode_rfc8881
> +    c =3D env.c1
> +    c.init_connection()
> +
> +    # Create two test files
> +    fh1, stateid1 =3D c.create_confirm(t.word() + b"_1")
> +    fh2, stateid2 =3D c.create_confirm(t.word() + b"_2")
> +
> +    # make_test_acl() derives to mode 0o644 (rw-r--r--)
> +    acl =3D nfs4acl.make_test_acl()
> +    acl_derived_mode =3D acl2mode_rfc8881(acl)
> +
> +    # Use a different mode to demonstrate the RFC-defined difference
> +    explicit_mode =3D 0o755
> +
> +    # File 1: Set MODE and ACL together
> +    # Per RFC 8881 Section 6.4.1.2, mode is derived from ACL (MODE ignor=
ed)
> +    attrs =3D {FATTR4_MODE: explicit_mode, FATTR4_ACL: acl}
> +    ops =3D c.use_obj(fh1) + [c.setattr(attrs)]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR with MODE and ACL together")
> +
> +    # File 2: Set ACL first, then MODE separately
> +    # Per RFC 8881 Section 6.4.1.1, final mode is the explicit MODE valu=
e
> +    ops =3D c.use_obj(fh2) + [c.setattr({FATTR4_ACL: acl})]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR with ACL")
> +
> +    ops =3D c.use_obj(fh2) + [c.setattr({FATTR4_MODE: explicit_mode})]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR with MODE after ACL")
> +
> +    # Verify the modes differ as expected per RFC 8881
> +    attrs1 =3D c.do_getattrdict(fh1, [FATTR4_MODE, FATTR4_ACL])
> +    attrs2 =3D c.do_getattrdict(fh2, [FATTR4_MODE, FATTR4_ACL])
> +
> +    mode1 =3D attrs1[FATTR4_MODE] & 0o777
> +    mode2 =3D attrs2[FATTR4_MODE] & 0o777
> +
> +    # File 1 (MODE+ACL together): mode should be derived from ACL
> +    if mode1 !=3D acl_derived_mode:
> +        t.fail("MODE+ACL together: expected ACL-derived mode 0%o, got 0%=
o"
> +               % (acl_derived_mode, mode1))
> +
> +    # File 2 (ACL then MODE): mode should be explicit MODE value
> +    if mode2 !=3D explicit_mode:
> +        t.fail("ACL then MODE: expected explicit mode 0%o, got 0%o"
> +               % (explicit_mode, mode2))
> +
> +def testSetattrACLModeDeriveBasic(t, env):
> +    """SETATTR(ACL) should derive mode per RFC 8881 Section 6.3.2
> +
> +    Test basic mode derivation from ACL when setting ACL alone.
> +    The mode's permission bits should match what is computed from the AC=
L.
> +
> +    FLAGS: setattr acl all
> +    DEPEND: MODE ACL0
> +    CODE: SATT23
> +    """
> +    from nfs4acl import acl2mode_rfc8881
> +    c =3D env.c1
> +    c.init_connection()
> +
> +    fh, stateid =3D c.create_confirm(t.word())
> +
> +    # Create ACL: OWNER@ gets read+write+execute, others get nothing
> +    acl =3D [
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | AC=
E4_EXECUTE,
> +                b"OWNER@"),
> +        nfsace4(ACE4_ACCESS_DENIED_ACE_TYPE, 0,
> +                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | AC=
E4_EXECUTE,
> +                b"GROUP@"),
> +        nfsace4(ACE4_ACCESS_DENIED_ACE_TYPE, 0,
> +                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | AC=
E4_EXECUTE,
> +                b"EVERYONE@")
> +    ]
> +
> +    # Set ACL only (not MODE)
> +    ops =3D c.use_obj(fh) + [c.setattr({FATTR4_ACL: acl})]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR with ACL only")
> +
> +    # Get resulting mode
> +    attrs =3D c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
> +    returned_mode =3D attrs[FATTR4_MODE] & 0o777
> +
> +    # Compute expected mode from the requested ACL per RFC 8881 Section =
6.3.2
> +    expected_mode =3D acl2mode_rfc8881(acl)
> +
> +    if returned_mode !=3D expected_mode:
> +        t.fail("Mode (0%o) does not match RFC 8881 Section 6.3.2 derivat=
ion "
> +               "from ACL (expected 0%o)" % (returned_mode, expected_mode=
))
> +
> +def testSetattrACLModeDeriveWriteBits(t, env):
> +    """SETATTR(ACL) write bit requires BOTH WRITE_DATA and APPEND_DATA
> +
> +    Per RFC 8881 Section 6.3.2, the write mode bit should only be set if=
 BOTH
> +    ACE4_WRITE_DATA and ACE4_APPEND_DATA are present in the ACL.
> +
> +    FLAGS: setattr acl all
> +    DEPEND: MODE ACL0
> +    CODE: SATT24
> +    """
> +    from nfs4acl import acl2mode_rfc8881
> +    c =3D env.c1
> +    c.init_connection()
> +
> +    # Test 1: Only WRITE_DATA (no APPEND_DATA) - write bit should NOT be=
 set
> +    fh1, stateid1 =3D c.create_confirm(t.word() + b"_1")
> +    acl1 =3D [
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_WRITE_DATA,  # Missing APPEND_DATA
> +                b"OWNER@")
> +    ]
> +    ops =3D c.use_obj(fh1) + [c.setattr({FATTR4_ACL: acl1})]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR ACL with only WRITE_DATA")
> +
> +    attrs1 =3D c.do_getattrdict(fh1, [FATTR4_MODE, FATTR4_ACL])
> +    mode1 =3D attrs1[FATTR4_MODE] & 0o777
> +    expected_mode1 =3D acl2mode_rfc8881(acl1)
> +
> +    if mode1 !=3D expected_mode1:
> +        t.fail("Mode (0%o) with only WRITE_DATA does not match expected =
(0%o). "
> +               "Write bit should NOT be set without APPEND_DATA." %
> +               (mode1, expected_mode1))
> +
> +    # Test 2: Only APPEND_DATA (no WRITE_DATA) - write bit should NOT be=
 set
> +    fh2, stateid2 =3D c.create_confirm(t.word() + b"_2")
> +    acl2 =3D [
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_APPEND_DATA,  # Missing WRITE_DATA
> +                b"OWNER@")
> +    ]
> +    ops =3D c.use_obj(fh2) + [c.setattr({FATTR4_ACL: acl2})]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR ACL with only APPEND_DATA")
> +
> +    attrs2 =3D c.do_getattrdict(fh2, [FATTR4_MODE, FATTR4_ACL])
> +    mode2 =3D attrs2[FATTR4_MODE] & 0o777
> +    expected_mode2 =3D acl2mode_rfc8881(acl2)
> +
> +    if mode2 !=3D expected_mode2:
> +        t.fail("Mode (0%o) with only APPEND_DATA does not match expected=
 (0%o). "
> +               "Write bit should NOT be set without WRITE_DATA." %
> +               (mode2, expected_mode2))
> +
> +    # Test 3: Both WRITE_DATA and APPEND_DATA - write bit SHOULD be set
> +    fh3, stateid3 =3D c.create_confirm(t.word() + b"_3")
> +    acl3 =3D [
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_WRITE_DATA | ACE4_APPEND_DATA,  # Both present
> +                b"OWNER@")
> +    ]
> +    ops =3D c.use_obj(fh3) + [c.setattr({FATTR4_ACL: acl3})]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR ACL with both WRITE_DATA and APPEND_DATA")
> +
> +    attrs3 =3D c.do_getattrdict(fh3, [FATTR4_MODE, FATTR4_ACL])
> +    mode3 =3D attrs3[FATTR4_MODE] & 0o777
> +    expected_mode3 =3D acl2mode_rfc8881(acl3)
> +
> +    if mode3 !=3D expected_mode3:
> +        t.fail("Mode (0%o) with WRITE_DATA+APPEND_DATA does not match "
> +               "expected (0%o)" % (mode3, expected_mode3))
> +
> +def testSetattrACLModeDeriveAllowDeny(t, env):
> +    """SETATTR(ACL) with ALLOW/DENY interaction
> +
> +    Test that ACL evaluation order is correct when mixing ALLOW and DENY=
 ACEs.
> +    Per RFC 8881 Section 6.3.2, evaluate ACEs in order, with earlier ACE=
s taking
> +    precedence.
> +
> +    FLAGS: setattr acl all
> +    DEPEND: MODE ACL0
> +    CODE: SATT25
> +    """
> +    from nfs4acl import acl2mode_rfc8881
> +    c =3D env.c1
> +    c.init_connection()
> +
> +    # Test: ALLOW first, then DENY - the ALLOW should win
> +    fh, stateid =3D c.create_confirm(t.word())
> +    acl =3D [
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA,
> +                b"OWNER@"),
> +        nfsace4(ACE4_ACCESS_DENIED_ACE_TYPE, 0,
> +                ACE4_READ_DATA,  # This should be ignored (already allow=
ed)
> +                b"OWNER@")
> +    ]
> +
> +    ops =3D c.use_obj(fh) + [c.setattr({FATTR4_ACL: acl})]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR ACL with ALLOW then DENY")
> +
> +    attrs =3D c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
> +    returned_mode =3D attrs[FATTR4_MODE] & 0o777
> +    expected_mode =3D acl2mode_rfc8881(acl)
> +
> +    if returned_mode !=3D expected_mode:
> +        t.fail("Mode (0%o) with ALLOW/DENY does not match expected (0%o)=
. "
> +               "First ACE should take precedence." % (returned_mode, exp=
ected_mode))
> +
> +def testSetattrACLModeDeriveEveryone(t, env):
> +    """SETATTR(ACL) with EVERYONE@ affecting all identifiers
> +
> +    Test that EVERYONE@ ACEs are considered when evaluating permissions
> +    for OWNER@ and GROUP@ per RFC 8881 Section 6.3.2.
> +
> +    FLAGS: setattr acl all
> +    DEPEND: MODE ACL0
> +    CODE: SATT26
> +    """
> +    from nfs4acl import acl2mode_rfc8881
> +    c =3D env.c1
> +    c.init_connection()
> +
> +    # EVERYONE@ gets read, specific OWNER@ gets nothing extra
> +    # Final result: OWNER@ should have read (from EVERYONE@)
> +    fh, stateid =3D c.create_confirm(t.word())
> +    acl =3D [
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA,
> +                b"EVERYONE@")
> +    ]
> +
> +    ops =3D c.use_obj(fh) + [c.setattr({FATTR4_ACL: acl})]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR ACL with only EVERYONE@")
> +
> +    attrs =3D c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
> +    returned_mode =3D attrs[FATTR4_MODE] & 0o777
> +    expected_mode =3D acl2mode_rfc8881(acl)
> +
> +    if returned_mode !=3D expected_mode:
> +        t.fail("Mode (0%o) does not match expected (0%o). "
> +               "EVERYONE@ should affect all mode bits." %
> +               (returned_mode, expected_mode))
> +
> +def testSetattrACLModeDeriveComplex(t, env):
> +    """SETATTR(ACL) with complex ACL including multiple identifiers
> +
> +    Test mode derivation with a more realistic ACL including OWNER@,
> +    GROUP@, and EVERYONE@ with various permissions.
> +
> +    FLAGS: setattr acl all
> +    DEPEND: MODE ACL0
> +    CODE: SATT27
> +    """
> +    from nfs4acl import acl2mode_rfc8881
> +    c =3D env.c1
> +    c.init_connection()
> +
> +    fh, stateid =3D c.create_confirm(t.word())
> +
> +    # Create a complex ACL:
> +    # OWNER@: read + write + execute
> +    # GROUP@: read + execute (no write)
> +    # EVERYONE@: read only
> +    acl =3D [
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | AC=
E4_EXECUTE,
> +                b"OWNER@"),
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA | ACE4_EXECUTE,
> +                b"GROUP@"),
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA,
> +                b"EVERYONE@")
> +    ]
> +
> +    ops =3D c.use_obj(fh) + [c.setattr({FATTR4_ACL: acl})]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR with complex ACL")
> +
> +    attrs =3D c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
> +    returned_mode =3D attrs[FATTR4_MODE] & 0o777
> +    expected_mode =3D acl2mode_rfc8881(acl)
> +
> +    if returned_mode !=3D expected_mode:
> +        t.fail("Mode (0%o) does not match RFC 8881 Section 6.3.2 derivat=
ion "
> +               "from complex ACL (expected 0%o)" %
> +               (returned_mode, expected_mode))
> +
> +def testSetattrACLIndependentOfMode(t, env):
> +    """SETATTR(ACL) outcome should not depend on existing mode bits
> +
> +    Per RFC 8881 Section 6.4.1.2, when setting ACL without mode, the ACL=
 should
> +    be set as given. The existing mode should not affect the ACL that ge=
ts
> +    stored. This test verifies that setting the same ACL on files with
> +    different initial modes results in identical ACLs being stored.
> +
> +    FLAGS: setattr acl all
> +    DEPEND: MODE ACL0
> +    CODE: SATT28
> +    """
> +    from nfs4acl import acl2mode_rfc8881
> +    c =3D env.c1
> +    c.init_connection()
> +
> +    # Create the same ACL to use for all files
> +    # OWNER@: read + write, GROUP@: read, EVERYONE@: nothing
> +    test_acl =3D [
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA,
> +                b"OWNER@"),
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA,
> +                b"GROUP@")
> +    ]
> +
> +    # Test with various initial mode values
> +    initial_modes =3D [0o600, 0o644, 0o755, 0o777, 0o400, 0o000]
> +    files =3D []
> +
> +    # Create files with different initial modes
> +    for initial_mode in initial_modes:
> +        fh, stateid =3D c.create_confirm(t.word() + (b"_%o" % initial_mo=
de))
> +
> +        # Set initial mode
> +        ops =3D c.use_obj(fh) + [c.setattr({FATTR4_MODE: initial_mode})]
> +        res =3D c.compound(ops)
> +        check(res, msg=3D"Setting initial mode to 0%o" % initial_mode)
> +
> +        files.append((fh, initial_mode))
> +
> +    # Now set the same ACL on all files
> +    for fh, initial_mode in files:
> +        ops =3D c.use_obj(fh) + [c.setattr({FATTR4_ACL: test_acl})]
> +        res =3D c.compound(ops)
> +        check(res, msg=3D"SETATTR ACL on file with initial mode 0%o" % i=
nitial_mode)
> +
> +    # Retrieve the ACLs that were actually stored
> +    acls =3D []
> +    for fh, initial_mode in files:
> +        attrs =3D c.do_getattrdict(fh, [FATTR4_ACL])
> +        acls.append((initial_mode, attrs[FATTR4_ACL]))
> +
> +    # Helper function to compare ACLs (comparing ACE lists)
> +    def acl_equal(acl1, acl2):
> +        """Compare two ACLs for equality"""
> +        if len(acl1) !=3D len(acl2):
> +            return False
> +        for ace1, ace2 in zip(acl1, acl2):
> +            if (ace1.type !=3D ace2.type or
> +                ace1.flag !=3D ace2.flag or
> +                ace1.access_mask !=3D ace2.access_mask or
> +                ace1.who !=3D ace2.who):
> +                return False
> +        return True
> +
> +    def acl_to_string(acl):
> +        """Convert ACL to readable string for error messages"""
> +        aces =3D []
> +        for ace in acl:
> +            type_str =3D "ALLOW" if ace.type =3D=3D ACE4_ACCESS_ALLOWED_=
ACE_TYPE else "DENY"
> +            aces.append("<%s:%s:0x%x:0x%x>" %
> +                       (type_str, ace.who.decode(), ace.access_mask, ace=
.flag))
> +        return "[" + ", ".join(aces) + "]"
> +
> +    # Compare all ACLs - they should all be identical
> +    reference_mode, reference_acl =3D acls[0]
> +    for initial_mode, acl in acls[1:]:
> +        if not acl_equal(reference_acl, acl):
> +            t.fail("ACLs differ based on initial mode! "
> +                   "File with mode 0%o has ACL %s, "
> +                   "but file with mode 0%o has ACL %s. "
> +                   "RFC 8881 Section 6.4.1.2: ACL should be set as given=
, "
> +                   "independent of existing mode." %
> +                   (reference_mode, acl_to_string(reference_acl),
> +                    initial_mode, acl_to_string(acl)))
> +
> +    # Also verify that the mode derived from the ACL is consistent
> +    modes =3D []
> +    for initial_mode, acl in acls:
> +        derived_mode =3D acl2mode_rfc8881(acl)
> +        modes.append(derived_mode)
> +
> +    if len(set(modes)) !=3D 1:
> +        mode_str =3D ", ".join("0%o (from initial 0%o)" % (m, acls[i][0]=
)
> +                             for i, m in enumerate(modes))
> +        t.fail("ACLs derive to different modes: %s. "
> +               "This suggests ACLs were stored differently based on init=
ial mode." %
> +               mode_str)
> +
> +def testSetattrACLIndependentModeHighBits(t, env):
> +    """SETATTR(ACL) should preserve high-order mode bits (SUID/SGID/SVTX=
)
> +
> +    Per RFC 8881 Section 6.4.1.2, when setting ACL without mode, the thr=
ee
> +    high-order bits of mode (SUID, SGID, SVTX) SHOULD remain unchanged.
> +    Only the low-order nine permission bits should be modified.
> +
> +    FLAGS: setattr acl all
> +    DEPEND: MODE ACL0
> +    CODE: SATT29
> +    """
> +    from nfs4acl import acl2mode_rfc8881
> +    c =3D env.c1
> +    c.init_connection()
> +
> +    # Create ACL to set
> +    test_acl =3D [
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | AC=
E4_EXECUTE,
> +                b"OWNER@"),
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA,
> +                b"GROUP@")
> +    ]
> +
> +    # Test with different high-order bits set
> +    test_cases =3D [
> +        (0o4755, "SUID"),      # Set-user-ID
> +        (0o2755, "SGID"),      # Set-group-ID
> +        (0o1755, "SVTX"),      # Sticky bit
> +        (0o6755, "SUID+SGID"), # Both SUID and SGID
> +        (0o7755, "ALL"),       # All three bits
> +    ]
> +
> +    # Preserving the high-order bits is a SHOULD, so collect violations
> +    # and warn once the MUST checks below have run for every case
> +    not_preserved =3D []
> +    for initial_mode, description in test_cases:
> +        fh, stateid =3D c.create_confirm(t.word() + (b"_%s" % descriptio=
n.encode()))
> +
> +        # Set initial mode with high-order bits
> +        ops =3D c.use_obj(fh) + [c.setattr({FATTR4_MODE: initial_mode})]
> +        res =3D c.compound(ops)
> +        check(res, msg=3D"Setting initial mode 0%o (%s)" % (initial_mode=
, description))
> +
> +        # Verify the mode was set
> +        before_attrs =3D c.do_getattrdict(fh, [FATTR4_MODE])
> +        before_mode =3D before_attrs[FATTR4_MODE] & 0o7777
> +
> +        # Set ACL only (not mode)
> +        ops =3D c.use_obj(fh) + [c.setattr({FATTR4_ACL: test_acl})]
> +        res =3D c.compound(ops)
> +        check(res, msg=3D"SETATTR ACL on file with %s" % description)
> +
> +        # Check that high-order bits are preserved
> +        after_attrs =3D c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
> +        after_mode =3D after_attrs[FATTR4_MODE] & 0o7777
> +
> +        # Extract high-order bits (SUID, SGID, SVTX)
> +        before_high =3D before_mode & 0o7000
> +        after_high =3D after_mode & 0o7000
> +
> +        if before_high !=3D after_high:
> +            not_preserved.append("%s: before=3D0%o, after=3D0%o" %
> +                                 (description, before_mode, after_mode))
> +
> +        # Verify low-order bits match ACL derivation
> +        after_low =3D after_mode & 0o777
> +        expected_low =3D acl2mode_rfc8881(test_acl)
> +
> +        if after_low !=3D expected_low:
> +            t.fail("Low-order mode bits (0%o) don't match RFC 8881 Secti=
on 6.3.2 "
> +                   "derivation (expected 0%o) for %s" %
> +                   (after_low, expected_low, description))
> +
> +    if not_preserved:
> +        t.pass_warn("High-order mode bits not preserved (RFC 8881 Sectio=
n "
> +                    "6.4.1.2: SHOULD remain unchanged): %s" %
> +                    "; ".join(not_preserved))
> +
> +def testSetattrModeACLattrsset(t, env):
> +    """SETATTR(MODE+ACL) should indicate which attributes were actually =
set
> +
> +    Per RFC 8881 Section 6.4.1.3, when both MODE and ACL are set togethe=
r, the
> +    server processes MODE first, then ACL (which may modify the mode).
> +    The attrsset bitmap indicates which attributes were actually set.
> +    This test verifies the attrsset bitmap and final mode consistency.
> +
> +    FLAGS: setattr acl all
> +    DEPEND: MODE ACL0
> +    CODE: SATT30
> +    """
> +    from nfs4acl import acl2mode_rfc8881
> +    c =3D env.c1
> +    c.init_connection()
> +
> +    fh, stateid =3D c.create_confirm(t.word())
> +
> +    # Create an ACL that will derive to a specific mode (0754)
> +    acl =3D [
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | AC=
E4_EXECUTE,
> +                b"OWNER@"),
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA | ACE4_EXECUTE,
> +                b"GROUP@"),
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA,
> +                b"EVERYONE@")
> +    ]
> +
> +    # Request a different mode (0640)
> +    requested_mode =3D 0o640
> +
> +    # Set both MODE and ACL together
> +    attrs =3D {FATTR4_MODE: requested_mode, FATTR4_ACL: acl}
> +    ops =3D c.use_obj(fh) + [c.setattr(attrs)]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR with MODE and ACL together")
> +
> +    # Check the attrsset bitmap
> +    attrsset =3D bitmap2list(res.resarray[-1].attrsset)
> +
> +    # Get the final attributes
> +    final_attrs =3D c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
> +    final_mode =3D final_attrs[FATTR4_MODE] & 0o777
> +
> +    # Both attributes were processed, so both must appear in attrsset
> +    if FATTR4_MODE not in attrsset:
> +        t.fail("MODE not in attrsset, but MODE was requested")
> +    if FATTR4_ACL not in attrsset:
> +        t.fail("ACL not in attrsset, but ACL was requested")
> +
> +    # Per RFC 8881 Section 6.4.1.3, ACL processing modifies the mode, so
> +    # the final mode matches the ACL derivation, not the requested mode
> +    acl_derived_mode =3D acl2mode_rfc8881(acl)
> +    if final_mode !=3D acl_derived_mode:
> +        t.fail("Final mode (0%o) does not match ACL-derived mode (0%o)" =
%
> +               (final_mode, acl_derived_mode))
> +
> +def testSetattrModeACLConflict(t, env):
> +    """SETATTR(MODE+ACL) when MODE and ACL would produce different permi=
ssions
> +
> +    Test the interaction when the requested MODE differs significantly f=
rom
> +    what the ACL would derive. Per RFC 8881 Section 6.4.1.3, MODE is app=
lied first,
> +    then ACL is applied (possibly changing the final mode).
> +
> +    FLAGS: setattr acl all
> +    DEPEND: MODE ACL0
> +    CODE: SATT31
> +    """
> +    from nfs4acl import acl2mode_rfc8881
> +    c =3D env.c1
> +    c.init_connection()
> +
> +    # Test multiple conflict scenarios
> +    test_cases =3D [
> +        # (requested_mode, ACL, description)
> +        (0o777, [  # Request all permissions
> +            nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                    ACE4_READ_DATA,  # But ACL only grants read
> +                    b"OWNER@")
> +        ], "MODE=3D0777 but ACL grants only read"),
> +
> +        (0o000, [  # Request no permissions
> +            nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                    ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA =
| ACE4_EXECUTE,
> +                    b"OWNER@")  # But ACL grants everything
> +        ], "MODE=3D0000 but ACL grants rwx"),
> +
> +        (0o644, [  # Request read for all, write for owner
> +            nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                    ACE4_EXECUTE,  # But ACL only grants execute
> +                    b"OWNER@")
> +        ], "MODE=3D0644 but ACL grants only execute"),
> +    ]
> +
> +    for requested_mode, acl, description in test_cases:
> +        fh, stateid =3D c.create_confirm(t.word() + ("_%o" % requested_m=
ode).encode())
> +
> +        # Set both MODE and ACL together
> +        attrs =3D {FATTR4_MODE: requested_mode, FATTR4_ACL: acl}
> +        ops =3D c.use_obj(fh) + [c.setattr(attrs)]
> +        res =3D c.compound(ops)
> +        check(res, msg=3D"SETATTR MODE+ACL: %s" % description)
> +
> +        # Get final attributes
> +        final_attrs =3D c.do_getattrdict(fh, [FATTR4_MODE, FATTR4_ACL])
> +        final_mode =3D final_attrs[FATTR4_MODE] & 0o777
> +
> +        # Verify final mode matches derivation from the requested ACL
> +        expected_mode =3D acl2mode_rfc8881(acl)
> +
> +        if final_mode !=3D expected_mode:
> +            t.fail("Test case '%s': final mode (0%o) doesn't match "
> +                   "ACL-derived mode (0%o). Per RFC 8881 Section 6.4.1.3=
, "
> +                   "ACL should be set as given and mode derived from it.=
" %
> +                   (description, final_mode, expected_mode))
> +
> +def testSetattrACLNamedPrincipals(t, env):
> +    """SETATTR(ACL) with named principals should preserve them
> +
> +    Per RFC 8881 Section 6.4.1.3: "the ACL attribute is set as given."
> +    When an ACL contains named principals (not OWNER@/GROUP@/EVERYONE@),
> +    the server must preserve those exact principals in the stored ACL,
> +    not convert them to special identifiers. For SETATTR(ACL) alone,
> +    Section 6.4.1.2 makes this a SHOULD, so that case only warns.
> +
> +    FLAGS: setattr acl all
> +    DEPEND: MODE ACL0
> +    CODE: SATT32
> +    """
> +    c =3D env.c1
> +    c.init_connection()
> +
> +    # First create a file and get its owner and group
> +    temp_fh, temp_stateid =3D c.create_confirm(t.word() + b"_temp")
> +    attrs =3D c.do_getattrdict(temp_fh, [FATTR4_OWNER, FATTR4_OWNER_GROU=
P])
> +    current_owner =3D attrs[FATTR4_OWNER]
> +    current_group =3D attrs[FATTR4_OWNER_GROUP]
> +
> +    # Test 1: SETATTR(ACL) with named principals only
> +    fh1, stateid1 =3D c.create_confirm(t.word() + b"_acl_only")
> +
> +    acl =3D [
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA,
> +                current_owner),  # Named principal, not OWNER@
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, ACE4_IDENTIFIER_GROUP,
> +                ACE4_READ_DATA,
> +                current_group)  # Named principal, not GROUP@
> +    ]
> +
> +    ops =3D c.use_obj(fh1) + [c.setattr({FATTR4_ACL: acl})]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR ACL with named principals")
> +
> +    # Verify ACL was preserved with named principals. Setting the ACL as
> +    # given is a SHOULD in RFC 8881 Section 6.4.1.2, so hold the warning
> +    # until test 2 has run.
> +    returned_attrs =3D c.do_getattrdict(fh1, [FATTR4_ACL])
> +    acl_only_warning =3D None
> +    try:
> +        nfs4acl.verify_acl(returned_attrs[FATTR4_ACL], acl)
> +    except AssertionError as e:
> +        acl_only_warning =3D ("%s. Server did not set the ACL as given "
> +                            "(RFC 8881 Section 6.4.1.2: SHOULD)" % e)
> +
> +    # Test 2: SETATTR(MODE+ACL) with named principals
> +    fh2, stateid2 =3D c.create_confirm(t.word() + b"_mode_acl")
> +
> +    mode =3D 0o755
> +    acl =3D [
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA | ACE4_WRITE_DATA | ACE4_APPEND_DATA | AC=
E4_EXECUTE,
> +                current_owner),  # Named principal
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, ACE4_IDENTIFIER_GROUP,
> +                ACE4_READ_DATA | ACE4_EXECUTE,
> +                current_group),  # Named principal
> +        nfsace4(ACE4_ACCESS_ALLOWED_ACE_TYPE, 0,
> +                ACE4_READ_DATA,
> +                b"EVERYONE@")  # Special identifier is fine
> +    ]
> +
> +    ops =3D c.use_obj(fh2) + [c.setattr({FATTR4_MODE: mode, FATTR4_ACL: =
acl})]
> +    res =3D c.compound(ops)
> +    check(res, msg=3D"SETATTR MODE+ACL with named principals")
> +
> +    # Verify ACL was preserved
> +    returned_attrs =3D c.do_getattrdict(fh2, [FATTR4_ACL])
> +    try:
> +        nfs4acl.verify_acl(returned_attrs[FATTR4_ACL], acl)
> +    except AssertionError as e:
> +        t.fail("%s. Server did not set the ACL as given, "
> +               "violating RFC 8881 Section 6.4.1.3" % e)
> +
> +    if acl_only_warning:
> +        t.pass_warn(acl_only_warning)
>
> --
> 2.54.0
>


--=20
Aur=C3=A9lien Couderc <aurelien.couderc2002@gmail.com>
Big Data/Data mining expert, chess enthusiast
