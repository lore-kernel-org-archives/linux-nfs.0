Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.218.44
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793309662;
	b=3TT/Ow2YAs0gztheHVHuemhVOD9JZ9NsBQHGYdV8Xqxx534K8tyDTHDYojUpNzwou0S7
	 76NCGvkp3WpC45NNG5D+H8JLIGdC/KqFlu/GjtNv0k2hldS5/2+A67VuND3UbmG7MecO1
	 Zf/rGKXkePezqncEGpvZrRkZi3ZiJ5m6GLOeblzTBH9RaMiUKPdin5jlBaB8ltIJqWkBB
	 MFa6TJGI2pq7eeSbmYhEPAY/R740EkqSp6OknjwUFaG7DQ2/zpToeTVe8ZYZhwGMR3MKs
	 Hs1fsVPmNKhzrlDUd1gmQqstYHKngpHlMUukrg32niKCujaay63E83LnPDNYtuwn4WQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793309662;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 Content-Type:MIME-Version:Content-Transfer-Encoding;
	bh=MILUqHNsqMeib6qd7G8v6uTbXNOk64aE06RXzgflgTs=;
	b=ii/f/N85qpy1cKc+APegtU+PY1S6tjU4PwRSodYDmcIC2+f2qZ8rOOqHlnVDQc7rtzaK
	 LJnj5c7oT94pWe29RlaGUWueoNaVQRQvUDKGJ113lX90OO++nVLpVWetvXuq9T0NFqwKA
	 qSYI6LOYaMfB2ZSKi1PEROInQlYMs5hxb70Xtha6/0cLfm0JxPLysNeSjc+MsNtWRkqYp
	 dLB7ZtwpRszhtzA/psPX0piEzCwWkyQyo54zhf1GjsjL9h/v7aQikanVPsfwBIek0Uswt
	 BqPVsefTaaW6VWfiYd9/BiKThF6P1TbFmD7gUSnxt2v+Ld0iVtw8SWPSeKQZGad3Qhw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=UnNtzvCA;
	arc=none smtp.remote-ip=209.85.218.44
Received: from mail-ej1-f44.google.com (mail-ej1-f44.google.com [209.85.218.44])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 16B19606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 21:34:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 16B19606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=UnNtzvCA
Received: by mail-ej1-f44.google.com with SMTP id a640c23a62f3a-c46822eefb6so344963466b.2
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 14:34:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793309660; x=1793914460; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:content-type:references
         :in-reply-to:message-id:date:subject:cc:to:from:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=MILUqHNsqMeib6qd7G8v6uTbXNOk64aE06RXzgflgTs=;
        b=UnNtzvCA97HHZGSUaahnPYByLv6/gMJwuud68cgF72V6bQ+fhMAi4f5DjrxquUmA6V
         Hhijze4yfCaL+dhqAdGgQfIKIKBrqZidyIBGPQZfePLse4b+3Yqsyu8mQqPZXVBeOKO2
         PcPkBmrADXp+sDynA3cYAcFGY9IF8ijW3++rCTW1USkpC63vkXkXYyFKYuZb4Kz3Fw/0
         VcgiG7+cebWY1O/czgqcgPxYfCIvOv27OBz13nuZcvu9mCQGnbEfw3MKEI84bp+rOOzQ
         lNK2Hy77xD0H4kgpKfaBDHnJ5twX5CAy1Sb0d0taCgOXSNcECKYC4Wc2ec4RhFxC8TM5
         D9tg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793309660; x=1793914460;
        h=content-transfer-encoding:mime-version:content-type:references
         :in-reply-to:message-id:date:subject:cc:to:from:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=MILUqHNsqMeib6qd7G8v6uTbXNOk64aE06RXzgflgTs=;
        b=WbkeGjD7igNI/wm4onQuNhlZ5iiZF8F1YNn8YukUGc46Gzjb0i+CmCbY6o0/hymrbb
         IcSQgVMRdMdE1Yt1XX3dP5Lys+TyK8PhKWOxFOOxVbm07Q+jPvH0L7GOp/P3PtaVZrN1
         AJoyDk8WGYszMDvrBKoZeojUlfqIvf4q/fYDyZCiinvKzEG10Kmz7qLt+mK266gItRmH
         6nrJJNA5HUiQNBaj/TxUBqj2CS1RcdLAssBFHEf513pDCgJKEAUpquIWZS9JPj8ZW0k5
         qfFgLgW7uNRARH1HkpQO/BhgfvpuJeo5QtcY8TP4W4fRNqYJ0qMtlZsx1+PMITc1m45l
         682A==
X-Forwarded-Encrypted: i=1; AKwUvBxz1CDPdR3g+TloiazU8IIfMTZuxTBY1CzxnyuSd3POOZRSWpTRWsRkGBYwqq75q9Rjst1zNhF//p8=@vger.kernel.org
X-Gm-Message-State: AFq9FYJaGG9Z5KltF0IOmT9AHBNbyMViQPIBQswTOHXObJ6F45E+ZBbH
	1AMzsgVXnfLJHpa1rri1gCIpDofOJH+0GXemjctdmqKErI47aLeIIKPm
X-Gm-Gg: AYBFou1wZ9t0sKBrS4qy4FjbdhrS/sH7V7G+7giHAB1ezT+8P/qsN1QWNkOujbaxHJ/
	MatEo5ciBr9dmgQ/JYKFcWUO42fGuYc1WWOU8WQRvlw5Kp0ZuAVXYSxa7eiIgTNlQq7wimrnIhN
	q/Zk2mh2dzIeUknE+uOHw8/HdjhjEMLkErnuiDzJuNVmbGBg9JV2e6kRfHISd0lBO0+U/M8acvq
	Yf5YJPcvWhrvjorXP1xJkurvSECH0XrhX1mRdlJiesoqBmePpmJOkxKU0qCTerf8EH9MWMSpyui
	9DStwTeJlxOins4Zdo81FIEkqk99of1bVG2fV/ogGSB6WDBgRz65w07yEuhNApQcxwGgClFs6rL
	+Q6Qib/DVHszHkt0QzQ0wrRTgLOrOhUEiD/8+IxdJSi4yxONnPI9PW3xH9sAryGvwKlBdKaj2zT
	nWKsDgVqpukbPG8sKXWP1rPEva0veISKh3HZblFaEb1XgRO73TcXKhk6AOJ0oKCR2EdELv8YZVv
	mKD/6KYKyfafoiRy6TG/506oSUXpiCR/d5cTHlCEckLq71jKkZBOuJAQ9q+sbLkoXo+0fksieeQ
	g/dSd9hrmom1DmNPlQPMluBX2RZjf1maKaJOHEAxtoCirnx3Ozz1YmGh060sQC3e2nIxdX0r
X-Received: by 2002:a17:906:fa12:b0:c46:7645:874 with SMTP id a640c23a62f3a-c4ca7ac00afmr20378366b.48.1793309660002;
        Thu, 29 Oct 2026 14:34:20 -0700 (PDT)
Received: from localhost.localdomain (173.242.112.181.16clouds.com. [173.242.112.181])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c4caa441ee9sm332366b.86.2026.10.29.14.34.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 14:34:19 -0700 (PDT)
From: VeroFess <coderzeng@gmail.com>
To: cel@kernel.org
Cc: jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4] nfsd: enforce export security for NFSv4 filehandles and stateids
Date: Fri, 30 Oct 2026 05:33:51 +0800
Message-ID: <20261029213351.259069-1-coderzeng@gmail.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <acef1e3e-8c3a-4b8b-9341-5ff0280efa19@slotpi15m67>
References: <20261029051430.96326-1-coderzeng@gmail.com> <20261029063917.138184-1-coderzeng@gmail.com> <acef1e3e-8c3a-4b8b-9341-5ff0280efa19@slotpi15m67>
Content-Type: text/plain; charset="utf-8"
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Chuck,

Thank you very much for offering to help develop the patches. I would
like to take you up on that: I am happy to run follow-up tests and
confirm the resulting series, but I am not in a position to develop
the split patches myself. I ran isolated tests to answer your
questions; results are inline below.

> The v4 revision of your patch appears to combine the original fix
> with several unrelated changes to SECINFO, READDIR, LOOKUP, and
> stateid processing. [...] Let's split the single patch into a series.

Agreed that it should be split.

> 1. The need_wrongsec_check() change by itself, with
>    "Fixes: 68d93184352f". [...] Please confirm that with your
>    reproducer on a kernel that has only this change.

Confirmed. I built the v4 parent plus only the need_wrongsec_check()
change, with no other NFSD change. Reusing a live krb5p OPEN stateid
over an AUTH_SYS connection, PUTFH; SAVEFH; READ and PUTFH; SAVEFH;
WRITE both returned NFS4ERR_WRONGSEC at PUTFH, the file was unchanged,
and the krb5p owner could still read it. That change alone is enough
for the reported sequence.

> 2. The check_nfsd_access() call in nfsd4_verify_copy(), which covers
>    both COPY and CLONE. [...] the source handle can reach COPY or
>    CLONE unchecked even after patch 1.

Reproduced on the patch-1-only kernel: AUTH_SYS direct READ of the
krb5p source returned WRONGSEC, but PUTFH; SAVEFH; PUTFH; COPY
completed and wrote the source bytes to the destination. Adding only
the nfsd4_verify_copy() check made COPY return NFS4ERR_ACCESS and left
the destination unchanged. CLONE is NFS4ERR_NOTSUPP on this ext4
fixture with or without the check, so I could not demonstrate a
reflink; its justification is the shared source-check path with COPY.
So this is a separate concern from patch 1.

> 3. Anything else, one change per patch, each with its own rationale
>    and only the Fixes: tags that match its code. These do not need
>    to go to stable.

Understood; I have kept each finding below as its own separate
concern.

> COPY_NOTIFY does not carry OP_HANDLES_WRONGSEC, so in PUTFH;
> COPY_NOTIFY the PUTFH already gets the deferred check_nfsd_access()
> call in nfsd4_proc_compound(). [...] How can READ be denied while
> COPY_NOTIFY succeeds? [...] Unless there is another path, I would
> drop the nfs4_check_file() and COPY_NOTIFY hunks.

You are right. That result came from an intermediate tree, before the
selected-export check on LOOKUP; both compounds used PUTROOTFH; LOOKUP,
and only READ took the nfs4_check_file() path. I rebuilt v4 with just
those two guards removed: with a retained stateid after the export
changed to krb5p, READ and COPY_NOTIFY were both rejected with
NFS4ERR_WRONGSEC before the operation, in the direct, SAVEFH, LOOKUP,
and RESTOREFH paths. I found no PUTFH; COPY_NOTIFY path that patch 1
misses, so those two hunks and the COPY_NOTIFY claim do not look
needed.

> With this change, a client using any flavor can learn whether a name
> exists in a directory on a sec=krb5p export. RFC 8881 Section
> 2.6.3.1.1.5 allows that, and your patch description should clarify
> that the code behavior is changed to conform with the spec.

Confirmed. With directory traversal permission, AUTH_SYS SECINFO on a
krb5p export returned OK for an existing name and NOENT for a missing
one; without traversal permission both returned NFS4ERR_ACCESS. I
agree the description should state this is an intentional,
spec-conforming part of security negotiation.

> Also, the new check_xprtsec_policy() call in nfsd_lookup_dentry()
> returns nfserr_wrongsec from SECINFO when it crosses into an export
> with a different xprtsec= policy. Is that not the NFS4ERR_WRONGSEC
> return from SECINFO that the description says is forbidden?

It is, and that is a real inconsistency in v4. Plaintext SECINFO
crossing into an xprtsec=tls child returned NFS4ERR_WRONGSEC on
NFSv4.0/4.1/4.2. I also tested a variant that maps a transport-policy
mismatch to NFS4ERR_ACCESS (RFC 8881 Section 18.29.3) at the starting
and selected-export checks: SECINFO then returned ACCESS instead of
WRONGSEC, while ordinary LOOKUP still returned WRONGSEC. That test
used a plaintext connection, not TLS. The unqualified "forbidden"
wording in my description is wrong either way.

> On a pseudo-root export, nfsd4_encode_entry4_fattr() always crosses
> into child exports. [...] Could the encoder fall back to returning
> the mountpoint's own attributes instead?

I tried that. The unrestricted fallback made size-only READDIR
succeed, but when the client requested FILEHANDLE it received the
covered mountpoint's handle and could then list the hidden underlay
(confirmed with a sentinel placed under the mount). So the
unrestricted fallback is not safe. A restricted variant that falls
back only when FILEHANDLE is not requested did behave: size-only
READDIR succeeded; a FILEHANDLE request still returned ACCESS; an
rdattr_error request reported WRONGSEC in the child entry; direct
LOOKUP stayed WRONGSEC.

> The new check_nfsd_access() call in nfsd_lookup() fixes a mount
> crossing that never checks the child export. The CREATE paths do the
> same crossing [...] If this check goes in, it probably belongs in
> nfsd_cross_mnt() so that every caller gets it.

Agreed, and the CREATE gap is real. On v4, AUTH_SYS NFSv2 CREATE and
NFSv3 CREATE UNCHECKED returned a filehandle from the stricter child
export (a bind-mounted single-file export); NFSv4.0/4.1/4.2 OPEN
UNCHECKED already returned WRONGSEC at OPEN. Moving the selected-export
check into nfsd_cross_mnt_common() made NFSv2/NFSv3 CREATE return
ACCESS while ordinary CREATE in the same parent still succeeded, so
the check does look like it belongs on the common mount-crossing path,
with the SECINFO exception preserved.

> Longer term, I would rather not keep adding check_nfsd_access()
> calls to individual operations. A filehandle whose security check
> PUTFH deferred could instead carry a "check pending" state [...]
> That can come later, it does not need to hold up these fixes.

That design makes sense to me, and I agree it need not block the
split.

Please go ahead and take things from here. I will confirm that the
resulting series addresses the issue and no longer reproduces, and run
any other tests you would like.

Thanks,
VeroFess
