Received: from mail-ed1-f50.google.com (mail-ed1-f50.google.com [209.85.208.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8C0D8266581
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 11:45:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.50
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787744741; cv=pass; b=ggnaumBqmXe/pUSd7uyy2H+wGpXfKLI+M8n9jib5XYEFfmft5XQqogS78cz6Vmnb/QPzKKGk0xSxUdz3pPIe8UURl07JOnj9/3mVBt3kpMqwXBKKXJoXQ3JVLUZ3Jn3iwac7FMenWcGZoSQBp/s0lMdguLh85j5cO9KvZCMJ+yE=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787744741; c=relaxed/simple;
	bh=P/gW8VCdRxuvei7jvHSdmaF9YehYw1Nvg7bZ/M9tvlc=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=LN1Pe91i8lVZps/cxQUBd7gyaMvAYV1MStk9ErVI2+eFG/gm4Hwn2mfOLFs5CNxFzFiTVX+hOQ4c3nMEmeWCLKj7OfX5owS6aCDXAVi57Pdi1oKrsxgQfYoSlkxiYsbAL2K2c9P7GuYNKVhB7P1Nye0j7+YmidQ6+j31Jto7P24=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Benw2RHB; arc=pass smtp.client-ip=209.85.208.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Benw2RHB"
Received: by mail-ed1-f50.google.com with SMTP id 4fb4d7f45d1cf-6a051b737d8so1064331a12.1
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 04:45:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787744737; cv=none;
        d=google.com; s=arc-20260327;
        b=fcI3NNtUG3FzGZN4TzjNUOXVw0VLAXJbgeCTUF2dYgxm0e6sMpJj1qWA0ld1wWlu8o
         RA3JlPTES1N1CeakM2VY2QWC0t7K5np0dnEWTyEbypc57n1B2QJAqMoDzG3dB9IL0CKO
         wi2tWabdUmn6urEflMdpuy/TQXo+ntPA57uTtwKRpEIAdiliT5ilerv0B62bmPhHGGth
         NcPQ6tQ6gxvAhDJoXw1wesDeY2T78WeB5Z+OPW5LE9gUWbUHyHnaTQ9pS+/7h8iKbfyb
         rv7ALOob2sxe2bMsYvO5zhqTOYgiqw9mLq29McfWB4XYwRw6TVAFQ7fAl/6B2b+rUj1M
         pDjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=EL3Qhu24ra+ZVTEf/c57lcIZ395PIysc4X3HnqGdH/o=;
        fh=Oo0cRX1Wl8XwbSKONt+in7LVnDgT62SqlEYgcS1Lel0=;
        b=YJHWFBRls6GJXRTUzhX8OYMCAgpilrKzIvlH1bDW+5vCAcMwcir2MCXjEiOGHqkeVw
         DrtiZMsiKExYvQUItUIOYGYVkpsVh8LtUsMLY5/RY1QA26SS1S40NU/vgMahpvIHBeGn
         /Cjb0Tm7R5a3ce5zngVobRFWCmtG+qDaou/5UCMfUbnku5HmSNRUWOehm7rNjfx2xI7g
         KvakNn9a9uO3cYjn189uIxyp78YZCPr3uBRGpsxx7txGJLDrdBpIfM1XUP6JDo5g+Y7H
         Yv2g/u8k3WQPu5oX0UFMA+PrY+X832AOwW6Kp2n+b6tqopQlzUUwBjde1piibbWOOC9Q
         uNmg==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787744737; x=1788349537; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=EL3Qhu24ra+ZVTEf/c57lcIZ395PIysc4X3HnqGdH/o=;
        b=Benw2RHB7lbbo41u2imHv1Qyc1te18mX7cNy1o4OLdqTbAkeu8SZDuHoR3FZzHhend
         cnojKJnWdozY7mOcI7EvzweL+uT/aNuSbLpKCmlMJC5WQ40B58YV7PRD/17+vMDSJYTl
         TQCZXBnLkQy6goUUvP19xo/ck7OL562HfRloSLggXovdILSANp5I8f8T+DxF3JpEzcK+
         elo0YzYNfettEOPO2wOX7kIDHyJ5VTVOmU+TFEK2JR1aModt8qO1dU9IYbQJYkeHkaSM
         CT0Zmdo+idrRP69SVyDT89uoxkc2daMXgCmDryHMsM93ZNK7pqRTp6OKDaCubNP/b/v4
         FksQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787744737; x=1788349537;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=EL3Qhu24ra+ZVTEf/c57lcIZ395PIysc4X3HnqGdH/o=;
        b=pQo4IhAqFnyjxfeDrNA3h4nlCzACLIId684uK444L7aoE/Yitp8plFCTNhnqIWOEtl
         xGz+RpoU1VHJsfnwvXfUUmRa07aLomHEuBhrNX8RTmSfprNTpwCzbpbLs6JTFIScAf/m
         vswoOK/fHodsW4OOFtHoWteDdAeyX7xYejCv77ovkO6+J3W6Vf8ZGXewGGnsixnRO4hB
         CSaHb1rlKcHmzfnK8dCsLMhvyx1kgbHUDJcchM8rjqAVhDrr935kPwoPNRZ117AKysLh
         epg9kk4DxMzT+5TGFUhCiUYbAeiMbasgQj17iTn+vc++9LcaRI9ubgMxDlAEsmxENy/x
         OCSQ==
X-Forwarded-Encrypted: i=1; AHgh+RpFrH8PLfJZpI8Vi0iSYgabXrU0K4pOL1C6JVFjQeQ4mV64Sj6/d3qg1QBsCOCMcbPnKttbNcmGjY0=@vger.kernel.org
X-Gm-Message-State: AFuF++nVMk2yuYIT1W207nF9+0QVirYGk6H4XuIpdB0QhsfcbdWNiRrL
	aHuhkANoNBvsXY7S44dPaFA30cWmAD8qaDsKczfW/tKPMi06TlsIwSOveb276pLGoKRRa1uC70m
	dJc86UycdCDyPwDoQ8wblXiHowXcjGf8=
X-Gm-Gg: AR+sD12RD/pnkhaiTYiqJKKKQWEaU/wOWpzdFERWJr5f8UmNQRUmtQOs8ehJcAUo2K0
	n4BCVWXIyqRgps2hpjetRvaodGV69IE5qFOpJ1x/aYC8+61YgsTm1gj7SHlNBDaYV0Bp2J4WSC2
	vwLLq3IHdmvtH9UtwHqaSs3F2sXi+40p7ljGw6c/X/nMMO1RzU3W/pf5OU6LtvAcVNwjyUDd+/T
	zsxqsfZnBA0o+lOex8gzAEQTQxjdyvgMJ4SPhqK8kYUU2+oxfDMVts5magdNQhKJQAE/mynJMx4
	4u2PpW/VXMXg2dMKcodk0fNnIbk/UF0U6/jx7ewsWpLk3g==
X-Received: by 2002:a05:6402:a0d7:b0:6a0:8885:e6e2 with SMTP id
 4fb4d7f45d1cf-6a5df64d135mr8524688a12.9.1787744736594; Wed, 26 Aug 2026
 04:45:36 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260803012648.2195405-1-neilb@ownmail.net> <20260803012648.2195405-4-neilb@ownmail.net>
 <CAJfpegs-k3skRGiwZvQLzD7OrAK4KL8zwmpmJKyjRHSQ-rqX+Q@mail.gmail.com>
 <178642552869.2852630.11443303758249822243@noble.neil.brown.name>
 <178675372176.2852630.1305553887009521382@noble.neil.brown.name>
 <oh2lg2agqxwqopecacq6sfdnky5faxidwsybkvbwbq24r6tw6o@4swfog5ocwwb>
 <CAOQ4uxgtKvKmPaK8rPAZDSwu0Hr9JAmqJi0a1VX_Rg7jDo8HrQ@mail.gmail.com>
 <178709583480.2852630.4575326968116183366@noble.neil.brown.name>
 <CAOQ4uxj6O8Ukbn-vWU-o+zOAYyofokCTAGnSifSDh9-PACCTdg@mail.gmail.com> <178744808383.3510150.4744569341920131567@noble.neil.brown.name>
In-Reply-To: <178744808383.3510150.4744569341920131567@noble.neil.brown.name>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 26 Aug 2026 13:45:24 +0200
X-Gm-Features: AcwNN1UwTnVyolJOeI93hI1vksiKbaXlH0pS9IhozP61tRhaaPYyHaqK6gsXgow
Message-ID: <CAOQ4uxi-pLMyN3WGUhN_uKgj9KbyRTepp5mcFFDuMr=eGOMkgw@mail.gmail.com>
Subject: Re: [PATCH v1 03/12] fsnotify: don't hold a spin_lock across
 fsnotify_recalc_mask() calls.
To: NeilBrown <neil@brown.name>
Cc: Jan Kara <jack@suse.cz>, Miklos Szeredi <miklos@szeredi.hu>, Ian Kent <raven@themaw.net>, 
	Chuck Lever <cel@kernel.org>, Jake Edge <jake@lwn.net>, Ilya Dryomov <idryomov@gmail.com>, 
	Alex Markuze <amarkuze@redhat.com>, Viacheslav Dubeyko <slava@dubeyko.com>, 
	Jan Harkes <jaharkes@cs.cmu.edu>, coda@cs.cmu.edu, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Miklos Szeredi <mszeredi@redhat.com>, autofs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, ceph-devel@vger.kernel.org, 
	codalist@coda.cs.cmu.edu, linux-fsdevel@vger.kernel.org, 
	linux-nfs@vger.kernel.org
Content-Type: multipart/mixed; boundary="000000000000f9b52a0659f1c1f9"

--000000000000f9b52a0659f1c1f9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, Aug 23, 2026 at 3:21=E2=80=AFAM NeilBrown <neilb@ownmail.net> wrote=
:
>
> On Wed, 19 Aug 2026, Amir Goldstein wrote:
> > On Wed, Aug 19, 2026 at 1:30=E2=80=AFAM NeilBrown <neilb@ownmail.net> w=
rote:
> > > --- a/fs/notify/dnotify/dnotify.c
> > > +++ b/fs/notify/dnotify/dnotify.c
> > > @@ -75,7 +75,7 @@ static void dnotify_recalc_inode_mask(struct fsnoti=
fy_mark *fsn_mark)
> > >                 return;
> > >         fsn_mark->mask =3D new_mask;
> > >
> > > -       fsnotify_recalc_mask(fsn_mark->connector);
> > > +       fsnotify_recalc_mask_inatomic(fsn_mark->connector);
> >
> > I don't think skipping update_children is correct when called
> > from fcntl_dirnotify().
>
> Thanks for catching that.
> I agree we shouldn't skip here, but also we mustn't call
> fsnotify_conn_set_children_dentry_flags() at this point because
> a spinlock is held.
> In fcntl_dirnotify() is it safe to delay that call until after the
> lock is dropped because fsnotify_group_lock() is still held.
>
> So I would like to keep that part of my patch - the part where
> fsnotify_recalc_mask() (and dnotify_recalc_inode_mask()) returns the
> "update_children" flag and the caller is responsible for calling
> fsnotify_conn_set_children_dentry_flags().

It's just a bit over complicated for my taste.
We do not need to optimize the dnotify case this much.
See my v2 patch, which addresses your concern and keeps
our internal API simpler (to my taste).

There is nothing technically wrong with your patch.
It's just my preference is different and Jan seems to be on the same page.

>
> Some callers call fsnotify_conn_set_children_dentry_flags() immediately,
> some wait until a spinlock is dropped, dnotify_handle_event() wouldn't
> call it at all.

There are 3 categories and my patch handles them by explicitly
requesting update_children or explicitly calling the children walk
outside of spinlock in the single special case.

>
> Your patch might be a good addition but it doesn't block the d_children
> walk in all cases where a spinlock is held, so it doesn't help my
> immediate need.

v2 should be ok?

Thanks,
Amir.

--000000000000f9b52a0659f1c1f9
Content-Type: text/x-patch; charset="US-ASCII"; 
	name="v2-0001-fsnotify-update-children-flags-only-when-adding-m.patch"
Content-Disposition: attachment; 
	filename="v2-0001-fsnotify-update-children-flags-only-when-adding-m.patch"
Content-Transfer-Encoding: base64
Content-ID: <f_mta0psh50>
X-Attachment-Id: f_mta0psh50

RnJvbSBiODVjNmM1MjliNmZmOTJkZDNkMWM1M2M4ZGU5NWM5YmI0YjEzZThkIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBbWlyIEdvbGRzdGVpbiA8YW1pcjczaWxAZ21haWwuY29tPgpE
YXRlOiBXZWQsIDE5IEF1ZyAyMDI2IDEwOjU2OjQwICswMjAwClN1YmplY3Q6IFtQQVRDSCB2Ml0g
ZnNub3RpZnk6IHVwZGF0ZSBjaGlsZHJlbiBmbGFncyBvbmx5IHdoZW4gYWRkaW5nIG1hc2sgYml0
cwoKU2luY2Ugd2Ugb25seSBldmVyIHNldCB0aGUgUEFSRU5UX1dBVENIRUQgZmxhZyBmcm9tCmZz
bm90aWZ5X3JlY2FsY19tYXNrKCksIHRoZXJlIGlzIG5ldmVyIGEgbmVlZCB0byB1cGRhdGUgY2hp
bGRyZW4gZmxhZ3MKd2hlbiByZW1vdmluZyBtYXJrIG1hc2sgYml0cyBvbmx5IHdoZW4gYWRkaW5n
IHRoZW0uCgpBbHNvIGF2b2lkIHVwZGF0ZSBjaGlsZHJlbiB3aXRoIG1hcmsgc3BpbmxvY2sgaGVs
ZC4KVGhpcyB3YXMgb25seSBkb25lIGJ5IGRub3RpZnkgYW5kIGNhbiBiZSBlYXNpbHkgYXZvaWRl
ZC4KCkZpeGVzOiAxNzJlNDIyZmZlYTIwICgiZnNub3RpZnk6IGNsZWFyIFBBUkVOVF9XQVRDSEVE
IGZsYWdzIGxhemlseSIpClNpZ25lZC1vZmYtYnk6IEFtaXIgR29sZHN0ZWluIDxhbWlyNzNpbEBn
bWFpbC5jb20+Ci0tLQogZnMvbm90aWZ5L2Rub3RpZnkvZG5vdGlmeS5jICAgICAgICB8ICAzICsr
LQogZnMvbm90aWZ5L2Zhbm90aWZ5L2Zhbm90aWZ5X3VzZXIuYyB8ICA0ICsrLS0KIGZzL25vdGlm
eS9pbm90aWZ5L2lub3RpZnlfdXNlci5jICAgfCAgMiArLQogZnMvbm90aWZ5L21hcmsuYyAgICAg
ICAgICAgICAgICAgICB8IDIyICsrKysrKysrKysrKy0tLS0tLS0tLS0KIGluY2x1ZGUvbGludXgv
ZnNub3RpZnlfYmFja2VuZC5oICAgfCAxMCArKysrKysrKy0tCiA1IGZpbGVzIGNoYW5nZWQsIDI1
IGluc2VydGlvbnMoKyksIDE2IGRlbGV0aW9ucygtKQoKZGlmZiAtLWdpdCBhL2ZzL25vdGlmeS9k
bm90aWZ5L2Rub3RpZnkuYyBiL2ZzL25vdGlmeS9kbm90aWZ5L2Rub3RpZnkuYwppbmRleCA5ZmI3
M2JhZmQ0MWQyLi4wNzZiYTQxMjMyODBjIDEwMDY0NAotLS0gYS9mcy9ub3RpZnkvZG5vdGlmeS9k
bm90aWZ5LmMKKysrIGIvZnMvbm90aWZ5L2Rub3RpZnkvZG5vdGlmeS5jCkBAIC03NSw3ICs3NSw3
IEBAIHN0YXRpYyB2b2lkIGRub3RpZnlfcmVjYWxjX2lub2RlX21hc2soc3RydWN0IGZzbm90aWZ5
X21hcmsgKmZzbl9tYXJrKQogCQlyZXR1cm47CiAJZnNuX21hcmstPm1hc2sgPSBuZXdfbWFzazsK
IAotCWZzbm90aWZ5X3JlY2FsY19tYXNrKGZzbl9tYXJrLT5jb25uZWN0b3IpOworCWZzbm90aWZ5
X3JlY2FsY19tYXNrKGZzbl9tYXJrLT5jb25uZWN0b3IsIGZhbHNlKTsKIH0KIAogLyoKQEAgLTM4
MCw2ICszODAsNyBAQCBpbnQgZmNudGxfZGlybm90aWZ5KGludCBmZCwgc3RydWN0IGZpbGUgKmZp
bHAsIHVuc2lnbmVkIGludCBhcmcpCiAJZG5vdGlmeV9yZWNhbGNfaW5vZGVfbWFzayhmc25fbWFy
ayk7CiBvdXQ6CiAJc3Bpbl91bmxvY2soJmZzbl9tYXJrLT5sb2NrKTsKKwlmc25vdGlmeV9jb25u
X3NldF9jaGlsZHJlbl9kZW50cnlfZmxhZ3MoZnNuX21hcmstPmNvbm5lY3Rvcik7CiAKIAlpZiAo
ZGVzdHJveSkKIAkJZnNub3RpZnlfZGV0YWNoX21hcmsoZnNuX21hcmspOwpkaWZmIC0tZ2l0IGEv
ZnMvbm90aWZ5L2Zhbm90aWZ5L2Zhbm90aWZ5X3VzZXIuYyBiL2ZzL25vdGlmeS9mYW5vdGlmeS9m
YW5vdGlmeV91c2VyLmMKaW5kZXggYTMyYzY2MzRkNTkyNy4uNzAwZTM1M2M0MjVhNiAxMDA2NDQK
LS0tIGEvZnMvbm90aWZ5L2Zhbm90aWZ5L2Zhbm90aWZ5X3VzZXIuYworKysgYi9mcy9ub3RpZnkv
ZmFub3RpZnkvZmFub3RpZnlfdXNlci5jCkBAIC0xMjY0LDcgKzEyNjQsNyBAQCBzdGF0aWMgaW50
IGZhbm90aWZ5X3JlbW92ZV9tYXJrKHN0cnVjdCBmc25vdGlmeV9ncm91cCAqZ3JvdXAsCiAJcmVt
b3ZlZCA9IGZhbm90aWZ5X21hcmtfcmVtb3ZlX2Zyb21fbWFzayhmc25fbWFyaywgbWFzaywgZmxh
Z3MsCiAJCQkJCQkgdW1hc2ssICZkZXN0cm95X21hcmspOwogCWlmIChyZW1vdmVkICYgZnNub3Rp
ZnlfY29ubl9tYXNrKGZzbl9tYXJrLT5jb25uZWN0b3IpKQotCQlmc25vdGlmeV9yZWNhbGNfbWFz
ayhmc25fbWFyay0+Y29ubmVjdG9yKTsKKwkJZnNub3RpZnlfcmVjYWxjX21hc2soZnNuX21hcmst
PmNvbm5lY3RvciwgZmFsc2UpOwogCWlmIChkZXN0cm95X21hcmspCiAJCWZzbm90aWZ5X2RldGFj
aF9tYXJrKGZzbl9tYXJrKTsKIAlmc25vdGlmeV9ncm91cF91bmxvY2soZ3JvdXApOwpAQCAtMTUz
OCw3ICsxNTM4LDcgQEAgc3RhdGljIGludCBmYW5vdGlmeV9hZGRfbWFyayhzdHJ1Y3QgZnNub3Rp
ZnlfZ3JvdXAgKmdyb3VwLAogCiAJcmVjYWxjID0gZmFub3RpZnlfbWFya19hZGRfdG9fbWFzayhm
c25fbWFyaywgbWFzaywgZmFuX2ZsYWdzKTsKIAlpZiAocmVjYWxjKQotCQlmc25vdGlmeV9yZWNh
bGNfbWFzayhmc25fbWFyay0+Y29ubmVjdG9yKTsKKwkJZnNub3RpZnlfcmVjYWxjX21hc2soZnNu
X21hcmstPmNvbm5lY3RvciwgdHJ1ZSk7CiAKIG91dDoKIAlmc25vdGlmeV9ncm91cF91bmxvY2so
Z3JvdXApOwpkaWZmIC0tZ2l0IGEvZnMvbm90aWZ5L2lub3RpZnkvaW5vdGlmeV91c2VyLmMgYi9m
cy9ub3RpZnkvaW5vdGlmeS9pbm90aWZ5X3VzZXIuYwppbmRleCA1ZjE5YzI0ZWMxODdmLi42ZDg0
YzUxMTY3NDlkIDEwMDY0NAotLS0gYS9mcy9ub3RpZnkvaW5vdGlmeS9pbm90aWZ5X3VzZXIuYwor
KysgYi9mcy9ub3RpZnkvaW5vdGlmeS9pbm90aWZ5X3VzZXIuYwpAQCAtNTYyLDcgKzU2Miw3IEBA
IHN0YXRpYyBpbnQgaW5vdGlmeV91cGRhdGVfZXhpc3Rpbmdfd2F0Y2goc3RydWN0IGZzbm90aWZ5
X2dyb3VwICpncm91cCwKIAlmc25fbWFyay0+ZmxhZ3MgfD0gaW5vdGlmeV9hcmdfdG9fZmxhZ3Mo
YXJnKTsKIAlzcGluX3VubG9jaygmZnNuX21hcmstPmxvY2spOwogCi0JZnNub3RpZnlfcmVjYWxj
X21hc2soZnNuX21hcmstPmNvbm5lY3Rvcik7CisJZnNub3RpZnlfcmVjYWxjX21hc2soZnNuX21h
cmstPmNvbm5lY3RvciwgdHJ1ZSk7CiAKIAkvKiByZXR1cm4gdGhlIHdkICovCiAJcmV0ID0gaV9t
YXJrLT53ZDsKZGlmZiAtLWdpdCBhL2ZzL25vdGlmeS9tYXJrLmMgYi9mcy9ub3RpZnkvbWFyay5j
CmluZGV4IGIyNjQwZDgzNmE3MTIuLjU2NGU4ZjkzMThhMTcgMTAwNjQ0Ci0tLSBhL2ZzL25vdGlm
eS9tYXJrLmMKKysrIGIvZnMvbm90aWZ5L21hcmsuYwpAQCAtMzA3LDcgKzMwNyw3IEBAIHN0YXRp
YyBib29sIGZzbm90aWZ5X2Nvbm5fd2F0Y2hlc19jaGlsZHJlbigKIAlyZXR1cm4gZnNub3RpZnlf
aW5vZGVfd2F0Y2hlc19jaGlsZHJlbihmc25vdGlmeV9jb25uX2lub2RlKGNvbm4pKTsKIH0KIAot
c3RhdGljIHZvaWQgZnNub3RpZnlfY29ubl9zZXRfY2hpbGRyZW5fZGVudHJ5X2ZsYWdzKAordm9p
ZCBmc25vdGlmeV9jb25uX3NldF9jaGlsZHJlbl9kZW50cnlfZmxhZ3MoCiAJCQkJCXN0cnVjdCBm
c25vdGlmeV9tYXJrX2Nvbm5lY3RvciAqY29ubikKIHsKIAlpZiAoY29ubi0+dHlwZSAhPSBGU05P
VElGWV9PQkpfVFlQRV9JTk9ERSkKQEAgLTMxNywyMCArMzE3LDIyIEBAIHN0YXRpYyB2b2lkIGZz
bm90aWZ5X2Nvbm5fc2V0X2NoaWxkcmVuX2RlbnRyeV9mbGFncygKIH0KIAogLyoKLSAqIENhbGN1
bGF0ZSBtYXNrIG9mIGV2ZW50cyBmb3IgYSBsaXN0IG9mIG1hcmtzLiBUaGUgY2FsbGVyIG11c3Qg
bWFrZSBzdXJlCi0gKiBjb25uZWN0b3IgYW5kIGNvbm5lY3Rvci0+b2JqIGNhbm5vdCBkaXNhcHBl
YXIgdW5kZXIgdXMuICBDYWxsZXJzIGFjaGlldmUKLSAqIHRoaXMgYnkgaG9sZGluZyBhIG1hcmst
PmxvY2sgb3IgbWFyay0+Z3JvdXAtPm1hcmtfbXV0ZXggZm9yIGEgbWFyayBvbiB0aGlzCi0gKiBs
aXN0LgorICogQ2FsY3VsYXRlIG1hc2sgb2YgZXZlbnRzIGZvciBhIGxpc3Qgb2YgbWFya3MuCisg
KiBJZiBAdXBkYXRlX2NoaWxkcmVuIGlzIHRydWUsIHVwZGF0ZSBjaGlsZHJlbiBkZW50cnkgZmxh
Z3MgaWYgbmVlZGVkLgorICogVGhlIGNhbGxlciBtdXN0IG1ha2Ugc3VyZSBjb25uZWN0b3IgYW5k
IGNvbm5lY3Rvci0+b2JqIGNhbm5vdCBkaXNhcHBlYXIgdW5kZXIKKyAqIHVzLiAgQ2FsbGVycyBh
Y2hpZXZlIHRoaXMgYnkgaG9sZGluZyBhIG1hcmstPmxvY2sgb3IgbWFyay0+Z3JvdXAtPm1hcmtf
bXV0ZXgKKyAqIGZvciBhIG1hcmsgb24gdGhpcyBsaXN0LgorICogV2hlbiBAdXBkYXRlX2NoaWxk
cmVuIGlzIHRydWUsIG1hcmstPmxvY2sgbXVzdCBub3QgYmUgaGVsZCBieSB0aGUgY2FsbGVyLgog
ICovCi12b2lkIGZzbm90aWZ5X3JlY2FsY19tYXNrKHN0cnVjdCBmc25vdGlmeV9tYXJrX2Nvbm5l
Y3RvciAqY29ubikKK3ZvaWQgZnNub3RpZnlfcmVjYWxjX21hc2soc3RydWN0IGZzbm90aWZ5X21h
cmtfY29ubmVjdG9yICpjb25uLAorCQkJICBib29sIHVwZGF0ZV9jaGlsZHJlbikKIHsKLQlib29s
IHVwZGF0ZV9jaGlsZHJlbjsKIAogCWlmICghY29ubikKIAkJcmV0dXJuOwogCiAJc3Bpbl9sb2Nr
KCZjb25uLT5sb2NrKTsKLQl1cGRhdGVfY2hpbGRyZW4gPSAhZnNub3RpZnlfY29ubl93YXRjaGVz
X2NoaWxkcmVuKGNvbm4pOworCXVwZGF0ZV9jaGlsZHJlbiAmPSAhZnNub3RpZnlfY29ubl93YXRj
aGVzX2NoaWxkcmVuKGNvbm4pOwogCWZzbm90aWZ5X3JlY2FsY19tYXNrX3NldF9pcmVmKGNvbm4p
OwogCXVwZGF0ZV9jaGlsZHJlbiAmPSBmc25vdGlmeV9jb25uX3dhdGNoZXNfY2hpbGRyZW4oY29u
bik7CiAJc3Bpbl91bmxvY2soJmNvbm4tPmxvY2spOwpAQCAtMzY4LDcgKzM3MCw3IEBAIHZvaWQg
ZnNub3RpZnlfbW9kaWZ5X21hcmtfbWFzayhzdHJ1Y3QgZnNub3RpZnlfbWFyayAqbWFyaywgdTMy
IHNldCwgdTMyIGNsZWFyKQogCXNwaW5fdW5sb2NrKCZtYXJrLT5sb2NrKTsKIAogCWlmIChyZWNh
bGMpCi0JCWZzbm90aWZ5X3JlY2FsY19tYXNrKG1hcmstPmNvbm5lY3Rvcik7CisJCWZzbm90aWZ5
X3JlY2FsY19tYXNrKG1hcmstPmNvbm5lY3RvciwgISFzZXQpOwogfQogRVhQT1JUX1NZTUJPTF9H
UEwoZnNub3RpZnlfbW9kaWZ5X21hcmtfbWFzayk7CiAKQEAgLTk5OCw3ICsxMDAwLDcgQEAgaW50
IGZzbm90aWZ5X2FkZF9tYXJrX2xvY2tlZChzdHJ1Y3QgZnNub3RpZnlfbWFyayAqbWFyaywKIAlp
ZiAocmV0KQogCQlnb3RvIGVycjsKIAotCWZzbm90aWZ5X3JlY2FsY19tYXNrKG1hcmstPmNvbm5l
Y3Rvcik7CisJZnNub3RpZnlfcmVjYWxjX21hc2sobWFyay0+Y29ubmVjdG9yLCB0cnVlKTsKIAog
CXJldHVybiByZXQ7CiBlcnI6CmRpZmYgLS1naXQgYS9pbmNsdWRlL2xpbnV4L2Zzbm90aWZ5X2Jh
Y2tlbmQuaCBiL2luY2x1ZGUvbGludXgvZnNub3RpZnlfYmFja2VuZC5oCmluZGV4IDYxOGVlZDRk
NmQ3MjQuLmU5MGNlZWViY2ViNWQgMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbGludXgvZnNub3RpZnlf
YmFja2VuZC5oCisrKyBiL2luY2x1ZGUvbGludXgvZnNub3RpZnlfYmFja2VuZC5oCkBAIC04ODUs
OCArODg1LDE0IEBAIHN0YXRpYyBpbmxpbmUgX191MzIgZnNub3RpZnlfY2FsY19tYXNrKHN0cnVj
dCBmc25vdGlmeV9tYXJrICptYXJrKQogCiAvKiBHZXQgbWFzayBvZiBldmVudHMgZm9yIGEgbGlz
dCBvZiBtYXJrcyAqLwogZXh0ZXJuIF9fdTMyIGZzbm90aWZ5X2Nvbm5fbWFzayhzdHJ1Y3QgZnNu
b3RpZnlfbWFya19jb25uZWN0b3IgKmNvbm4pOwotLyogQ2FsY3VsYXRlIG1hc2sgb2YgZXZlbnRz
IGZvciBhIGxpc3Qgb2YgbWFya3MgKi8KLWV4dGVybiB2b2lkIGZzbm90aWZ5X3JlY2FsY19tYXNr
KHN0cnVjdCBmc25vdGlmeV9tYXJrX2Nvbm5lY3RvciAqY29ubik7CisvKgorICogQ2FsY3VsYXRl
IG1hc2sgb2YgZXZlbnRzIGZvciBhIGxpc3Qgb2YgbWFya3MgYW5kIHVwZGF0ZSBjaGlsZHJlbiBk
ZW50cnkKKyAqIGZsYWcgaXMgbmVlZGVkLgorICovCitleHRlcm4gdm9pZCBmc25vdGlmeV9yZWNh
bGNfbWFzayhzdHJ1Y3QgZnNub3RpZnlfbWFya19jb25uZWN0b3IgKmNvbm4sCisJCQkJIGJvb2wg
dXBkYXRlX2NoaWxkcmVuKTsKK2V4dGVybiB2b2lkIGZzbm90aWZ5X2Nvbm5fc2V0X2NoaWxkcmVu
X2RlbnRyeV9mbGFncygKKwkJCQkJc3RydWN0IGZzbm90aWZ5X21hcmtfY29ubmVjdG9yICpjb25u
KTsKIGV4dGVybiB2b2lkIGZzbm90aWZ5X2luaXRfbWFyayhzdHJ1Y3QgZnNub3RpZnlfbWFyayAq
bWFyaywKIAkJCSAgICAgICBzdHJ1Y3QgZnNub3RpZnlfZ3JvdXAgKmdyb3VwKTsKIC8qIEZpbmQg
bWFyayBiZWxvbmdpbmcgdG8gZ2l2ZW4gZ3JvdXAgaW4gdGhlIGxpc3Qgb2YgbWFya3MgKi8KLS0g
CjIuNTUuMAoK
--000000000000f9b52a0659f1c1f9--
