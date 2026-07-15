Received: from mail-pj1-f44.google.com (mail-pj1-f44.google.com [209.85.216.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1955C3C10A6
	for <linux-nfs@vger.kernel.org>; Wed, 15 Jul 2026 20:41:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.216.44
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784148101; cv=pass; b=H1zkdhnory4+llOyd+IibiFv21CXLsoNoCMa3M6/qt9z5ZfY5No91n1L8EWf83UnDXopy4UC+fYYNa/mb/p4jU5JZDZFcLUmS5qUkm3/je6+uTKw0hsLV5wzHamBHV6mupX9/bgIeNCPYcMEFirOvPZa+t6tV5PDIdn/09lljZQ=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784148101; c=relaxed/simple;
	bh=WFUZsI+9mzM5h3Hu8cIqgWqx4bsjN+2caS2Ww8w777g=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=iYvoytUTz/d+ldIQYfLJ0iFTf/XPtP1XljfvdiqKnEGqugTc6y3yTl9HwAmx2Bk5K0uFG70vtzwvdgwRIsLLMtbN3H18UyfEccMWB5HkUt3XPL479AHtSKRA0M+Afa2h3UKwah7QSdraBymU0OeFDAyaN4gy66diuNsWa4P6fw4=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com; spf=pass smtp.mailfrom=paul-moore.com; dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b=fQL2VAxn; arc=pass smtp.client-ip=209.85.216.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=paul-moore.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b="fQL2VAxn"
Received: by mail-pj1-f44.google.com with SMTP id 98e67ed59e1d1-38e08baf860so3439942a91.2
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jul 2026 13:41:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1784148099; cv=none;
        d=google.com; s=arc-20260327;
        b=ieYEIkO52P70WixrXsc5P82ggZtiGBszfsl/5N/49DkKI086jyVqr2TZk/i9m4bgAX
         ExOwyMqtofQZ18xLYTR+TxCR9rb1oGStF9QNqDMX1uOfvztT0eQrTyOIaHlF0n40agNM
         HhNApuEOt5EwLuh4/qvO9facTzMdJqW9aEQnfewchhfetckWpktFG8znPL3acCjQEOza
         MGZkCSTVd6Yk/T0qIc3KgjAWqlJF31SsGqUScRiylbkINla8kbmLpIay7FjIQqVCRo76
         U9Bk27XIEyBZYjP7RJLh7L5iKnjuuqegC52SEx1PFudyi8Uxh9dYawYkAVA0vRDiTLic
         go0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Y4+6tUBvv9kkZdWXGDMO01Jh6FEAjGQaTiyDDZ/AJ9A=;
        fh=J+RlIPaLSZWsZm4dcAfu/nH6j0BynA1tKDQWXra57ZA=;
        b=cZ5Epvb3hSjiBgWrHjLu/x4LhHyDd1cB3Em4zmz/PlHFlLabwK8cN7IqhnhJ0Epa4I
         9M9aU95CW96welce9yswEAIiDpoG2Uv+IrPKf/VQpSoQFNcmHJS70YunigeqCwfGWSED
         cJ1kcLzYc6vlfJYHwnOCKb/Wodl6UiHISJFN93gFnSez0CU5quk4S54Ps5LSGTBS13uD
         dnQfnjCEZOEf+49hIcjCBRlWBTyxpiOADmRKLCMq8cYrOdoqp8hU/YNKhJGjeQAXCFe7
         TrtFsmBal66lY2JslpvhOBUh2uqH4RailZ8M7u+fyvNfTh0/wLuoeyI25NZqFWV9K56Q
         gQsA==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore.com; s=google; t=1784148099; x=1784752899; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=Y4+6tUBvv9kkZdWXGDMO01Jh6FEAjGQaTiyDDZ/AJ9A=;
        b=fQL2VAxnymU623YvOy/fm+gzOXjRmvV+oJOQ0q5D/1I0oITkZ8+rA7YjnvgQ32R2Gl
         Uzyh7mdGOKFDRt6GLMCT5awLnQTHPZm84tF0ZEz7BBIXHpekePgePIMNp4OVmvmfCwoi
         WdhK3nie2/FdH1+gFnk18zWkPXqb+FVJEyo0umeDv7OKfHMEKDuCbIj9j1i6S6AJiNCq
         Vhbiliy6g/iu/VMAntEyh69tHYdPTSPcsEhSDNUAImr6ERExNXSIPBYu8TPTOhfInp2W
         XdsSB4V0ve+1GZ900/ZOMk07MuWQ8MUM30Koxn+8XdLq++ubDgs7USBktF9IXDikSqUb
         xMpQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784148099; x=1784752899;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Y4+6tUBvv9kkZdWXGDMO01Jh6FEAjGQaTiyDDZ/AJ9A=;
        b=TYqDx2W86sMWJ8pVGazX1UJQM7eQ2TowtCU8PA6AUTsr+pVk42jjROmphbT80gwQRE
         kpFTPiVaHuUdBByiaaKH4S4WgtLYmS0a49xo+NOrJRc4RWBiEtJ3fNnprP6R0EdbxPRx
         b+LNP69AW2MWYN8dEbaHJQEd3ITLyvgYVhf4011KhfVHxfMSsLIjwkqmv17JzTRl2iJm
         MVIpz+yrNbGUABQew8tLc0D3UgWV722eLYs6DMOgOLrjY+JhUt63zLvbrukHXNnuNgdn
         ibsw+QYkpsbgjx801g1kilusxcLuc0Vf1c3yk/9V4UTlvk9wWu9ZHQ4mw23e5IjDmarH
         Sjrw==
X-Gm-Message-State: AOJu0YwdaEId9ktnsvDVPcsZvfZsswkdlwM91Z0b2dCiltKfiMqPFfkk
	k55Lp+URlykvV+RpylDi4sq6gwXtwsLvQqOt46aZpEyuMUfoWN40/DSuCt57P2hWu8TvHnWFt7V
	r1KeGjntrxFbEHaKsZ5cs5NiqkZIbH1ULzklPXoNt
X-Gm-Gg: AfdE7clJKsYP2Brh4rzmBGayZ5dgIfhKtqqC8zCr6k2NcvnnipwIkk2nBFFbeapX7SY
	rV32ZLHcIVSuYUI5iDr+i9P3jruv5jp3KlXKSLXHxCh/cuTJCx87HGfhi/eWKeqi2hAbv6qt9mW
	4QvYU8OJTMZf816U0SAZLTAFeVi3N1+YC64SmDs1uRrcrETCnizNNLBmZ8WWQa/xW7QCcXe9CtU
	KVhqr9CbzyfOQq5ZjTsyLf3vhu+M7CwUylBO8D4jAhRhXWJuhpMxGptXXLWN+xy9maG0SFd
X-Received: by 2002:a17:90b:1646:b0:38d:c834:24cf with SMTP id
 98e67ed59e1d1-38e2a01d044mr3677818a91.23.1784148099381; Wed, 15 Jul 2026
 13:41:39 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAHC9VhSWWhMjs282cOTT45gn0pa8bDSxD0H24_is7k4tXmGJxQ@mail.gmail.com>
 <ac4f209c-f465-4938-adae-ecd00ecab175@app.fastmail.com> <CAHC9VhQYjj3--K6KkDJBf6LfXqtj4TPh5LsMBpPYc0-Zz6wTMA@mail.gmail.com>
 <CAEjxPJ7dttPDxQDa_xXFd1H-QT_vkUwjtnH+=3cmG5dhSiaAXw@mail.gmail.com>
 <CAHC9VhSyCuiPBRWz_vUbx7+L5yLiXkjKX+7UyCLr82-_gAj2NQ@mail.gmail.com>
 <CAEjxPJ4+wgUDY3YxajZ=2D3WLzgat_Mqvr05VtJ4KrXW7_kuXA@mail.gmail.com>
 <CAHC9VhSxpAx+G35fbcMjJ1PfqJxDZYpTEu=qpO+0PQe=nkX5-g@mail.gmail.com>
 <CAHC9VhRq+Vth-4D4OHFAY_6hXqmj=MgTc_2G=3Ehr6bAQzp26Q@mail.gmail.com>
 <CAHC9VhQy4LOgQg0mk+s5sjHOzMe1sxPUgJ2W7vRT8ms4znZp+Q@mail.gmail.com>
 <CAHC9VhR+pWFnt=1pBJTky78br7NsfVcZE=V4UkfkfTbMvBo+mQ@mail.gmail.com> <alaxhbWbFMZyC8VQ@smayhew-thinkpadp1gen4i.remote.csb>
In-Reply-To: <alaxhbWbFMZyC8VQ@smayhew-thinkpadp1gen4i.remote.csb>
From: Paul Moore <paul@paul-moore.com>
Date: Wed, 15 Jul 2026 16:41:27 -0400
X-Gm-Features: AUfX_mzsfoszHbfyg2O-Br4gvumLi1bZDkqDuMmCQGdfP1UYUVx-vIZEGp6Qv2I
Message-ID: <CAHC9VhTAa7_tsWOuYELMnC+Zm2gW8PRT3sWvoN7Y=m5Q3UJBUQ@mail.gmail.com>
Subject: Re: [PATCH v2] NFSv4.2: fix nfs4_listxattr size accounting
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <anna@kernel.org>, jlayton@kernel.org, 
	chuck.lever@oracle.com, Stephen Smalley <stephen.smalley.work@gmail.com>, 
	Achilles Gaikwad <achillesgaikwad@gmail.com>, Trond Myklebust <trondmy@kernel.org>, 
	linux-security-module@vger.kernel.org, selinux@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 14, 2026 at 6:00=E2=80=AFPM Scott Mayhew <smayhew@redhat.com> w=
rote:
> On Tue, 14 Jul 2026, Paul Moore wrote:
> > On Fri, Jul 10, 2026 at 6:20=E2=80=AFPM Paul Moore <paul@paul-moore.com=
> wrote:
> > >
> > > ... and scratch that, the offending commit was that one.
> > >
> > >    commit 01c2305795a3b6b164df48e72b12022a68fd60c1
> > >    Author: Jeff Layton <jlayton@kernel.org>
> > >    Date:   Wed Mar 25 10:40:32 2026 -0400
> > >
> > >    nfsd: add netlink upcall for the nfsd.fh cache
> > >
> > >    Add netlink-based cache upcall support for the expkey (nfsd.fh) ca=
che,
> > >    following the same pattern as the existing svc_export netlink supp=
ort.
> > >
> > >    Add expkey to the cache-type enum, a new expkey attribute-set with
> > >    client, fsidtype, fsid, negative, expiry, and path fields, and the
> > >    expkey-get-reqs / expkey-set-reqs operations to the nfsd YAML spec
> > >    and generated headers.
> > >
> > >    Implement nfsd_nl_expkey_get_reqs_dumpit() which snapshots pending
> > >    expkey cache requests and sends each entry's seqno, client name,
> > >    fsidtype, and fsid over netlink.
> > >
> > >    Implement nfsd_nl_expkey_set_reqs_doit() which parses expkey cache
> > >    responses from userspace (client, fsidtype, fsid, expiry, and path
> > >    or negative flag) and updates the cache via svc_expkey_lookup() /
> > >    svc_expkey_update().
> > >
> > >    Wire up the expkey_notify() callback in svc_expkey_cache_template
> > >    so cache misses trigger NFSD_CMD_CACHE_NOTIFY multicast events wit=
h
> > >    NFSD_CACHE_TYPE_EXPKEY.
> > >
> > >    Signed-off-by: Jeff Layton <jlayton@kernel.org>
> > >    Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >
> > Playing around with it some this morning on a current Fedora Rawhide
> > system, I can reproduce the problem with a simple command line:
> >
> >  %  mount -t nfs localhost:/mnt/test /mnt/nfs_test
> >  mount.nfs: Connection refused for localhost:/mnt/test on /mnt/nfs_test
> >
> > ... adding an explicit "vers=3D{4,4.1,4.2}" has no effect; versions 2
> > and 3 are no supported on my kernel builds.  There is nothing obvious
> > in dmesg.  I've run with SELinux both in permissive mode and disabled
> > and encountered the same problem.  This doesn't appear to be related
> > to SELinux, it may simply be that we are the first ones to hit this.
> >
> > As there was some earlier discussion about this being a wonky
> > interaction with userspace, here are some of the relevant packages on
> > my system:
> >
> > nfs-common-utils-2.9.1-4.rc4.fc45.x86_64
> > nfs-client-utils-2.9.1-4.rc4.fc45.x86_64
> > nfsv4-client-utils-2.9.1-4.rc4.fc45.x86_64
> > nfs-utils-2.9.1-4.rc4.fc45.x86_64
> >
> > My next step is to try disabling portions of the NFS file handle cache
> > upcall to see if that is the issue, but it would be nice if the NFS
> > devs could take a look at this too.  I'm happy to test things out or
> > answer any questions about my test system.
>
> Pardon the dumb question, but are you positive your NFS server is
> running?

I'm slightly embarrassed to admit that your question wasn't as dumb as
one might have thought :)

While my bisection testing used the selinux-testsuite which ensures
the NFS server starts, when I tried to create a simple reproducer to
share with the non-SELinux crowd I neglected to verify that the NFS
server was running, the directory, was exported, etc.  My apologies
for the confusion.  However, the problem was real, even if my
reproducer and error message were junk.

> FWIW the netlink upcall requires CAP_NET_ADMIN, which is blocked by the
> current selinux-policy on rawhide (and I think it's a dontaudit rule)...

As a quick test I added a quick hack to my policy (allow rule below)
and everything appears to be working again.  Thanks for the pointer!

 allow nfsd_t nfsd_t:capability { net_admin };

--=20
paul-moore.com
