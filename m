Received: from mail-oa1-f47.google.com (mail-oa1-f47.google.com [209.85.160.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C09B11A683E
	for <linux-nfs@vger.kernel.org>; Sat,  1 Aug 2026 19:32:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.160.47
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785612751; cv=pass; b=G7YhXM9bTwIYqwvKlGnkWj8kAz/APVjNQzsGxe5JBZi0Tbf2PK9JAf3JpFFV7OGqf41qb3p85wWqqbudgcmTMZ6DZTr0tTDdLcBVY6z9LL0S9DqnMuzrpvJLZVkxsiPwikVcNmpO8g9jb6/T7FlyCK+qM1LrjVNEC3B+Gf2hqMc=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785612751; c=relaxed/simple;
	bh=fHYz/2DPNU61xKzZgqP7l0T7/wVuyWtaFFH7260Fhzg=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Cc:Content-Type; b=jk8OIUvpyiur/+1XA+0LGLwXiz+D4Ac6KcXV08CCMGszdyBzUkzJi9CsqzwwY4PAlHxF6Ykj1LLn1fLhV/mGeeJvIKyoOXkUA0+cyrH/wDA3ODa1Oxgb6a2NYFKUjuWtXJFGC/8bqLa5WfwWZ8xhQbX3Sw8c2gTKzhkkyZ9h3dw=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=YvAzbN5f; arc=pass smtp.client-ip=209.85.160.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YvAzbN5f"
Received: by mail-oa1-f47.google.com with SMTP id 586e51a60fabf-448b69cfc6dso1920046fac.3
        for <linux-nfs@vger.kernel.org>; Sat, 01 Aug 2026 12:32:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1785612748; cv=none;
        d=google.com; s=arc-20260327;
        b=oY8NqUwo+14j0sk/qFWVzm+xZorccj4G6Xf97t3Cyx7uGDsrTF2ir7Jf/UqiXZMXkf
         ASd5gi102h6l2orq+wjB2yZRdSJ6m3qG511ZoUmJjljiL4BFrju1egrllbMs79Jm8AMS
         l5OjPjwcne00pKcaHJhPR+zZvusRrj9S3zrYBHraUQMEvpxfjxTJ0J+yyf2+8VEImwTE
         2ZIDYkHzFmDdiSrV9KUdEK5yt9ivVYM9JaF7QK2Wfa1jiP6OcMX9injWEiteo+lFJycM
         QYiWxzbGCNft0aahhGjpid+pLoCYlcVqF+wfSKE/90QPopsGfvmykY1mkoTmNu4qwLs8
         p99Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=aVplGJiVgE5hgydpOSpQU2ZjiY71I2JFcwP8wi4CEkg=;
        fh=NM3iaLE3kBVomrJtDhexfe2NuZcbJHXlHGjbKSm6qH8=;
        b=SVMXompe1qYhxGmBZYTYzpQ1mb8ju97HUvDIzNUKdAFOvZVxCXuKNdVHj3N1cPKeFC
         wFt/RD92TpmBsAoQNfBKTfLid+NauEnpDZ7oESb8VZUJHAJPouPpN7k0jNhNaiFPuYKI
         UoajIx0sCverAxErb3B9rF6zH4sgGS1LDAxdMyjvOXpd9U6AAfepQrFchQJHGxHebJwV
         RpGNIoilFqdHjz0re5ctPQquwN/lZZTMKTpEBQqrx4XcTYqxz893xVGbnYDSLcYJkW7+
         Kyw96aC5Z8dYWAUZnP2OAagYFdmNqOGlIfqRc/SFrbS45UjOX4hiFjrQQFBeDKLUwmjF
         UU6Q==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1785612748; x=1786217548; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:mime-version:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=aVplGJiVgE5hgydpOSpQU2ZjiY71I2JFcwP8wi4CEkg=;
        b=YvAzbN5fGlVbAeaki/MMSywYSyDEX3/Uj0xofcYS8X3HMaCdJKGPCpNBU82OuYY3la
         qNo8ZOITFxK9UKGN6hbJw1cGJuuZWcEm4YWq8ghZT2xNmBRVcDz46LA8E2ThsG0R/ZOk
         pRL1tytmgyY0/GKzGC5nfE6IDfJUWpJa3HscaIPZIB2c2lMW0euG/DnGq26poEx+tJ7F
         bx9fY3m2HS7FsN2zoes+GgaSWOS8gk6Xexy7A925p2+QiR06cqk5ypP7qoxcB6lfY7Ks
         GAoh+x9K2saT/VS7K+WnlSapN/3mo9UakgdCA4Vwk4EhYL+HGaLQVA9wkgcxHFLu6BY+
         kwhg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1785612748; x=1786217548;
        h=content-type:cc:to:subject:message-id:date:from:mime-version
         :x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=aVplGJiVgE5hgydpOSpQU2ZjiY71I2JFcwP8wi4CEkg=;
        b=korYHo4CorkXeAw3glpFhQ7zDLgtq5i1WV3tZ35WSoo3O6uMMu+bmQyjq4I4xergBQ
         git7CdHLNvbpNf8n7iBxT110hyJGbWKVPFOXtpjc339YUymHwrC19ucSB6lte8m2xHwB
         H4uRjTvnvjk1kKGDSPlY/Yrv9VsV98GO9QM8wlU5rKS7kl9JiNGXQgimuI1zpR9ig+lB
         SgjRNw6AVQDbLAO8U6z6s6eECf59MtH5tbUmZrHpD59aqbjzuUmYvTkAPXcIVpIi23Dt
         e+vAaWCxFI5BlMdkhXTZ3UTI6ii2DuurQtiZP94ZTmACjqnnhsMEFgHw1o5x5je2KYmv
         qIiw==
X-Gm-Message-State: AOJu0Yyqns1h39HbsfqVIysQeArsANTa60IsixHFsWj7SbXpfi/19gwk
	GqhbUKACpTUeMTIJqkqZqQwi7uqGjzw93lUnpvf51gOhVRkrPGI5yFxcAL79BHOOFWcU6kIcAip
	SMmRhi1sQrf7Zr8agu3HLpZsGSo7CuvFZ18Wf
X-Gm-Gg: AR+sD11Kx+9NkftcF6yIoeDOouanZ9W1k/tvsIZ3fn1GF4MWPNdumvyxbbzUTQdIvus
	2A0kZ63j1KuglyJbklcwZQGlpX4zfm3rv3CJ4+XeFA1WA72VefSkIUue83kRyfIpjFEiaNRdXQW
	t2ZQocZL458KNgcgzls3sYRiZ1yB793rGCnJhyYLlnsHtv7BOXt1MVpNd6abyFAPIWwqCSPFYpP
	B1HAzactClX2164/h3qT0KkU19z+CvBdSlc2NvXZsns7Fvajk+cdysEMUn6O7Ty99/ElXTjCeih
	aEdOp6e2bCWtRczA+KSfk7z1eAD/KvvyYbW9VT8h5r2OcCtkff9yjw==
X-Received: by 2002:a05:6871:6005:b0:455:9a0a:f40f with SMTP id
 586e51a60fabf-45905d32498mr8204875fac.12.1785612748421; Sat, 01 Aug 2026
 12:32:28 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: George Chapman <gchapmancontact@gmail.com>
Date: Sat, 1 Aug 2026 20:32:16 +0100
X-Gm-Features: AUfX_mwivypgExt2TUUtyowXH3B3hEy2EGydOx92OpS5twU6iILlPpHkLgmrGK4
Message-ID: <CADjmrE=0LVQxWaodOXFyRpCSoJAShifsjJQ_VcqQXyAC-edJDw@mail.gmail.com>
Subject: [BUG] NFSD: write_unlock_fs() has the same pre-shutdown-check UAF
 that 92ea163c773c just fixed for the netlink command
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Content-Type: multipart/mixed; boundary="0000000000009398e30658015d3a"

--0000000000009398e30658015d3a
Content-Type: multipart/alternative; boundary="0000000000009398e20658015d38"

--0000000000009398e20658015d38
Content-Type: text/plain; charset="UTF-8"

Hi all,

Bit of context, my name is George Chapman and I'm a cyber security
researcher from the UK.
I'm sure you get a lot of these but recently I've been exploring
AI-assisted tooling as part of my own security research, using it alongside
manual code review to look for bugs on local Linux builds.

I've recently found something and want to raise it with you please,
essentially this report is a product of that process, an LLM helped me
trace through the code under my direction, with everything checked by hand
before sending.

I want to mention this upfront in case it's useful to know, and happy
to adjust how I send these if there's a channel you'd prefer.

After reading through recent NFSD fixes and came across *92ea163c773c*
("NFSD: Prevent post-shutdown use-after-free in
NFSD_CMD_UNLOCK_FILESYSTEM"), which fixes nfsd_nl_unlock_filesystem_doit()
calling nfsd4_cancel_copy_by_sb() before nfsd_mutex is held and before
nn->nfsd_serv is confirmed set.

The commit message says this directly: "the same pre-mutex ordering the
procfs unlock_filesystem path carried" That's describing write_unlock_fs()
in fs/nfsd/nfsctl.c, the handler behind /proc/fs/nfsd/unlock_filesystem
(same operation, older interface).

Checking the current tree, the fix's diff only
touched nfsd_nl_unlock_filesystem_doit(); write_unlock_fs() itself, a few
hundred lines above it in the same file, still has exactly the ordering the
commit describes as unsafe:

fs/nfsd/nfsctl.c:299 (mainline as of 0c452fbdf413, 2026-07-24):
   error = kern_path(fo_path, 0, &path);
    if (error)
        return error;
    ...
    nfsd4_cancel_copy_by_sb(netns(file), path.dentry->d_sb);
    error = nlmsvc_unlock_all_by_sb(path.dentry->d_sb);
    mutex_lock(&nfsd_mutex);
    nn = net_generic(netns(file), nfsd_net_id);
    if (nn->nfsd_serv)
        nfsd4_revoke_states(nn, path.dentry->d_sb);
    else
        error = -EINVAL;
    mutex_unlock(&nfsd_mutex);

nfsd4_cancel_copy_by_sb() walks nn->conf_id_hashtbl unconditionally, with
no lock held and no check that NFSD is running:

    spin_lock(&nn->client_lock);
    for (idhashval = 0; idhashval < CLIENT_HASH_SIZE; idhashval++) {
        struct list_head *head = &nn->conf_id_hashtbl[idhashval];
        list_for_each_entry(clp, head, cl_idhash) {
            spin_lock(&clp->async_lock);
            ...

*nfs4_state_destroy_net() (fs/nfsd/nfs4state.c:9184,* called from
*nfs4_state_shutdown_net()
on server stop)* does "kfree(nn->conf_id_hashtbl);" as part of the same
shutdown sequence which sets *nn->nfsd_serv* back to NULL.

So after a stop, *conf_id_hashtbl *is dangling while *nfsd_serv == NULL *sits
right there unchecked a few lines later in write_unlock_fs().

Writing to /proc/fs/nfsd/unlock_filesystem after stopping NFSD in that net
namespace looks like it would walk freed memory as a list and take
a spinlock on whatever bogus pointer falls out of it, the
same use-after-free shape as the bug 92ea163c773c just fixed, just reached
through the older procfs interface instead of the netlink one.

I reproduced this locally under a KASAN kernel built from this tree
(CONFIG_NFSD=y, no export or NFS client needed): mount nfsd, start
threads, stop threads, then write "/" to unlock_filesystem. Crashed on the
first attempt, no timing needed since the hash table is freed synchronously
in the thread-stop path:

    Oops: general protection fault, probably for non-canonical address
    0xdffffc0000000000: 0000 [#1] KASAN
    KASAN: null-ptr-deref in range [0x0000000000000000-0x0000000000000007]
    RIP: 0010:nfsd4_cancel_copy_by_sb+0x1ca/0x9c0
    RAX: 0000000000000000 RBX: 0000000000000000 ...
    Call Trace:
     write_unlock_fs+0x20c/0x760
     nfsctl_transaction_write+0xd5/0x140
     vfs_write+0x24e/0x1050
     ksys_write+0xfe/0x1e0

RAX/RBX reading 0 in the [0x0-0x7] range matches head
= &nn->conf_id_hashtbl[idhashval] off a freed (and zeroed-on-free on this
debug config) array pointer, exactly the mechanism above.
This needs local write access to that file (owner-only, effectively root or
a process specifically granted it), same access level as the already-fixed
netlink command required, so it's not remotely triggerable as far as I can
tell.

This hasn't been through upstream triage, just my own local repro and
source reading.

I reproduced it again today (2026-08-01) against current mainline
(2d2338c93da79b3bfe4b6099a931d9468d539952), same crash signature,
same RIP, same call chain, confirming this is still open 8 days
after 92ea163c773c fixed the sibling and called out this exact ordering.

Fuller writeup attached
(*advisory-linux-nfsd-write-unlock-fs-cancel-copy-uaf.md*), including
a rough sketch of a fix mirroring 92ea163c773c's shape, offered as a
starting point rather than a tested patch.

I know this isn't a finished exploit, and I'm happy to help in whatever way
would be useful from here.

Thank you for your time, and for maintaining this code.

Best wishes,

George C

--0000000000009398e20658015d38
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hi all,<br><br>Bit of context, my name is George Chap=
man and I&#39;m a cyber security researcher from the UK.=C2=A0</div><div>I&=
#39;m sure you get a lot of these but recently I&#39;ve been exploring AI-a=
ssisted tooling as part of my own security research, using it alongside man=
ual code=C2=A0review to look for bugs on local Linux builds.=C2=A0</div><di=
v><br></div><div>I&#39;ve recently found something and want to raise it wit=
h you please, essentially t<span style=3D"background-color:transparent">his=
 report is a=C2=A0product of that process, an LLM helped me trace through t=
he code under my direction, with everything checked by hand before sending.=
</span></div><div><br></div><div>I want to mention this upfront in case it&=
#39;s useful to know, and happy to=C2=A0adjust how I send these if there&#3=
9;s a channel you&#39;d prefer.<br><br>After reading through recent NFSD fi=
xes and came across <b>92ea163c773c</b><br>(&quot;NFSD: Prevent post-shutdo=
wn use-after-free in<br>NFSD_CMD_UNLOCK_FILESYSTEM&quot;), which fixes nfsd=
_nl_unlock_filesystem_doit()<br>calling nfsd4_cancel_copy_by_sb() before nf=
sd_mutex is held and before<br>nn-&gt;nfsd_serv is confirmed set.=C2=A0</di=
v><div><span style=3D"background-color:transparent"><br>The commit message =
says this directly:=C2=A0&quot;the same pre-mutex ordering the procfs unloc=
k_filesystem path carried&quot;=C2=A0</span><span style=3D"background-color=
:transparent">That&#39;s describing write_unlock_fs() in fs/nfsd/nfsctl.c, =
the handler behind /proc/fs/nfsd/unlock_filesystem (same operation, older i=
nterface).=C2=A0</span></div><div><br></div><div>Checking the current tree,=
 the fix&#39;s diff only touched=C2=A0nfsd_nl_unlock_filesystem_doit(); wri=
te_unlock_fs() itself, a few hundred lines above it in the same file, still=
 has exactly the=C2=A0ordering the commit describes as unsafe:<br><br>fs/nf=
sd/nfsctl.c:299 (mainline as of 0c452fbdf413, 2026-07-24):<br>=C2=A0 =C2=A0=
<span style=3D"background-color:transparent">error =3D kern_path(fo_path, 0=
, &amp;path);</span></div><div>=C2=A0 =C2=A0 if (error)<br>=C2=A0 =C2=A0 =
=C2=A0 =C2=A0 return error;<br>=C2=A0 =C2=A0 ...<br>=C2=A0 =C2=A0 nfsd4_can=
cel_copy_by_sb(netns(file), path.dentry-&gt;d_sb);<br>=C2=A0 =C2=A0 error =
=3D nlmsvc_unlock_all_by_sb(path.dentry-&gt;d_sb);<br>=C2=A0 =C2=A0 mutex_l=
ock(&amp;nfsd_mutex);<br>=C2=A0 =C2=A0 nn =3D net_generic(netns(file), nfsd=
_net_id);<br>=C2=A0 =C2=A0 if (nn-&gt;nfsd_serv)<br>=C2=A0 =C2=A0 =C2=A0 =
=C2=A0 nfsd4_revoke_states(nn, path.dentry-&gt;d_sb);<br>=C2=A0 =C2=A0 else=
<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 error =3D -EINVAL;<br>=C2=A0 =C2=A0 mutex_u=
nlock(&amp;nfsd_mutex);<br><br>nfsd4_cancel_copy_by_sb() walks nn-&gt;conf_=
id_hashtbl unconditionally, with no lock held and no check that NFSD is run=
ning:<br><br>=C2=A0 =C2=A0 spin_lock(&amp;nn-&gt;client_lock);<br>=C2=A0 =
=C2=A0 for (idhashval =3D 0; idhashval &lt; CLIENT_HASH_SIZE; idhashval++) =
{<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 struct list_head *head =3D &amp;nn-&gt;con=
f_id_hashtbl[idhashval];<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 list_for_each_entry=
(clp, head, cl_idhash) {<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_=
lock(&amp;clp-&gt;async_lock);<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 ...<br><br><i>nfs4_state_destroy_net() (fs/nfsd/nfs4state.c:9184,</i> call=
ed from=C2=A0<i>nfs4_state_shutdown_net() on server stop)</i> does=C2=A0&qu=
ot;kfree(nn-&gt;conf_id_hashtbl);&quot; as part of the same shutdown sequen=
ce=C2=A0which sets <i>nn-&gt;nfsd_serv</i> back to NULL.=C2=A0</div><div><b=
r></div><div>So after a stop, <i>conf_id_hashtbl </i>is dangling while <i>n=
fsd_serv =3D=3D NULL </i>sits right there unchecked a few=C2=A0lines later =
in write_unlock_fs().=C2=A0=C2=A0</div><div><br></div><div>Writing to /proc=
/fs/nfsd/unlock_filesystem after stopping NFSD in that net namespace looks =
like it would walk freed memory as a list and take a=C2=A0spinlock on whate=
ver bogus pointer falls out of it, the same=C2=A0use-after-free shape as th=
e bug 92ea163c773c just fixed, just reached through the older procfs interf=
ace instead of the netlink one.<br><br>I reproduced this locally under a KA=
SAN kernel built from this tree (CONFIG_NFSD=3Dy, no export or NFS client n=
eeded): mount nfsd, start<br>threads, stop threads, then write &quot;/&quot=
; to unlock_filesystem. Crashed=C2=A0on the first attempt, no timing needed=
 since the hash table is freed synchronously in the thread-stop path:<br><b=
r>=C2=A0 =C2=A0 Oops: general protection fault, probably for non-canonical =
address<br>=C2=A0 =C2=A0 0xdffffc0000000000: 0000 [#1] KASAN<br>=C2=A0 =C2=
=A0 KASAN: null-ptr-deref in range [0x0000000000000000-0x0000000000000007]<=
br>=C2=A0 =C2=A0 RIP: 0010:nfsd4_cancel_copy_by_sb+0x1ca/0x9c0<br>=C2=A0 =
=C2=A0 RAX: 0000000000000000 RBX: 0000000000000000 ...<br>=C2=A0 =C2=A0 Cal=
l Trace:<br>=C2=A0 =C2=A0 =C2=A0write_unlock_fs+0x20c/0x760<br>=C2=A0 =C2=
=A0 =C2=A0nfsctl_transaction_write+0xd5/0x140<br>=C2=A0 =C2=A0 =C2=A0vfs_wr=
ite+0x24e/0x1050<br>=C2=A0 =C2=A0 =C2=A0ksys_write+0xfe/0x1e0<br><br>RAX/RB=
X reading 0 in the [0x0-0x7] range matches head =3D=C2=A0&amp;nn-&gt;conf_i=
d_hashtbl[idhashval] off a freed (and zeroed-on-free on this debug config) =
array pointer, exactly the mechanism above.=C2=A0</div><div>This needs loca=
l write access to that file (owner-only, effectively root or a process spec=
ifically granted it), same access level as the already-fixed netlink comman=
d required, so it&#39;s not remotely=C2=A0triggerable as far as I can tell.=
=C2=A0</div><div><br></div><div>This hasn&#39;t been through upstream triag=
e, just my own local repro and source reading.<br><br>I reproduced it again=
 today (2026-08-01) against current mainline (2d2338c93da79b3bfe4b6099a931d=
9468d539952), same crash signature,<br>same RIP, same call chain, confirmin=
g this is still open 8 days after=C2=A092ea163c773c fixed the sibling and c=
alled out this exact ordering.<br><br>Fuller writeup attached<br>(<b>adviso=
ry-linux-nfsd-write-unlock-fs-cancel-copy-uaf.md</b>), including a=C2=A0rou=
gh sketch of a fix mirroring 92ea163c773c&#39;s shape, offered as a startin=
g point rather than a tested patch.<br><br>I know this isn&#39;t a finished=
 exploit, and I&#39;m happy to help in whatever way would be useful from he=
re.<br><br>Thank you for your time, and for maintaining this code.<br><br>B=
est wishes,<br><br>George C</div></div>

--0000000000009398e20658015d38--
--0000000000009398e30658015d3a
Content-Type: text/markdown; charset="US-ASCII"; 
	name="advisory-linux-nfsd-write-unlock-fs-cancel-copy-uaf.md"
Content-Disposition: attachment; 
	filename="advisory-linux-nfsd-write-unlock-fs-cancel-copy-uaf.md"
Content-Transfer-Encoding: base64
Content-ID: <f_msarmndc0>
X-Attachment-Id: f_msarmndc0

IyBTZWN1cml0eSBBZHZpc29yeTogTGludXgga2VybmVsIE5GU0Q6IGB3cml0ZV91bmxvY2tfZnMo
KWAgY2FsbHMgYG5mc2Q0X2NhbmNlbF9jb3B5X2J5X3NiKClgIGJlZm9yZSBjaGVja2luZyBgbm4t
Pm5mc2Rfc2VydmAsIHVzZS1hZnRlci1mcmVlIG9uIGEgc3RvcHBlZCBzZXJ2ZXIKCi0gKipQcm9k
dWN0OioqIExpbnV4IGtlcm5lbCwgYGZzL25mc2QvbmZzY3RsLmNgIChgL3Byb2MvZnMvbmZzZC91
bmxvY2tfZmlsZXN5c3RlbWAgcHJvY2ZzIHdyaXRlIGhhbmRsZXIpCi0gKipUZXN0ZWQgYWdhaW5z
dCBjb21taXQ6KiogYDBjNDUyZmJkZjQxMzc0ZmY0MThjYjA2OWU1OWQxNDFlYjczZjM3NGFgICht
YWlubGluZSwgMjAyNi0wNy0yNCkuIGBmcy9uZnNkL25mc2N0bC5jYCBpdHNlbGYgbGFzdCB0b3Vj
aGVkIGJ5IGA5MmVhMTYzYzc3M2NgICgyMDI2LTA3LTA1KTsgbm8gY29tbWl0cyB0byB0aGUgZmls
ZSBzaW5jZS4KCiMjIFN0YXR1cyB1cCBmcm9udAoKTGl2ZS1yZXByb2R1Y2VkIHVuZGVyIGEgS0FT
QU4taW5zdHJ1bWVudGVkIFFFTVUga2VybmVsIGJ1aWx0IGZyb20gY3VycmVudCBtYWlubGluZSAo
c2VlICJMaXZlIHJlcHJvZHVjdGlvbiIgYmVsb3cpLiBJdCBpcyBzdWJtaXR0ZWQgd2l0aCBoaWdo
IGNvbmZpZGVuY2UgYm90aCBiZWNhdXNlIHRoZSBjcmFzaCB3YXMgb2J0YWluZWQgZGlyZWN0bHkg
YW5kIGJlY2F1c2UgdGhlIG1haW50YWluZXIncyBvd24gZml4IGNvbW1pdCBkZXNjcmliZXMgdGhp
cyBleGFjdCBjb2RlIHBhdGggYXMgc2hhcmluZyB0aGUgYnVnIGl0IGZpeGVkLCBpbiBpdHMgb3du
IGNvbW1pdCBtZXNzYWdlLCB3aXRob3V0IHRoZSBmaXggaXRzZWxmIHRvdWNoaW5nIGl0LiBUaGlz
IGhhcyBub3QgZ29uZSB0aHJvdWdoIHVwc3RyZWFtIHRyaWFnZSBvciBtYWludGFpbmVyIHJldmll
dzsgdGhlIGFuYWx5c2lzIGFuZCByZXByb2R1Y3Rpb24gYmVsb3cgYXJlIG9mZmVyZWQgYXMtaXMs
IG9uIHRoZSBzdHJlbmd0aCBvZiB0aGUgbG9jYWwgcmVwcm8gYW5kIHNvdXJjZSByZWFkaW5nLCBu
b3QgYXMgYSBtYWludGFpbmVyLWNvbmZpcm1lZCBmaW5kaW5nLgoKIyMgTGl2ZSByZXByb2R1Y3Rp
b24KCkJ1aWx0IGEga2VybmVsIGZyb20gdGhpcyBwcm9qZWN0J3MgbG9jYWwgbWFpbmxpbmUgY2hl
Y2tvdXQgd2l0aCBgQ09ORklHX05GU0Q9eWAsIGBDT05GSUdfTkZTRF9WND15YCwgS0FTQU4gKGdl
bmVyaWMsIGlubGluZSkgYWxyZWFkeSBlbmFibGVkIGluIHRoZSB3b3JraW5nIGNvbmZpZywgYm9v
dGVkIHVuZGVyIFFFTVUvVENHLiBObyBORlMgZXhwb3J0IG9yIE5GUyBjbGllbnQgaXMgbmVlZGVk
OyB0aGUgc2VxdWVuY2UgYmVsb3cgaXMgZW50aXJlbHkgbG9jYWwgdG8gdGhlIG1hY2hpbmUgcnVu
bmluZyB0aGUga2VybmVsOgoKYGBgCm1vdW50IC10IG5mc2QgbmZzZCAvcHJvYy9mcy9uZnNkICAg
ICAjIGlmIG5vdCBhbHJlYWR5IG1vdW50ZWQKZWNobyA0ID4gL3Byb2MvZnMvbmZzZC90aHJlYWRz
ICAgICAgICMgc3RhcnQgbmZzZAplY2hvIDAgPiAvcHJvYy9mcy9uZnNkL3RocmVhZHMgICAgICAg
IyBzdG9wIG5mc2Q7IGZyZWVzIG5uLT5jb25mX2lkX2hhc2h0YmwKcHJpbnRmICcvXG4nID4gL3By
b2MvZnMvbmZzZC91bmxvY2tfZmlsZXN5c3RlbQpgYGAKClRoaXMgcmVwcm9kdWNlZCBvbiB0aGUg
Zmlyc3QgYXR0ZW1wdCwgd2l0aCBubyBkZWxheSBiZXR3ZWVuIHRoZSBzdG9wIGFuZCB0aGUgd3Jp
dGUsIHdoaWNoIGlzIGNvbnNpc3RlbnQgd2l0aCB0aGUgYnVnIGJlaW5nIGRldGVybWluaXN0aWMg
cmF0aGVyIHRoYW4gYSBuYXJyb3cgdGltaW5nIHJhY2U6IHRoZSBoYXNoIHRhYmxlIGlzIGZyZWVk
IHN5bmNocm9ub3VzbHkgaW4gdGhlIHRocmVhZC1zdG9wIHBhdGgsIHNvIGFueSB3cml0ZSB0byBg
dW5sb2NrX2ZpbGVzeXN0ZW1gIGFmdGVyd2FyZCBoaXRzIGl0LgoKUGFuaWMgKEtBU0FOLCBnZW5l
cmFsIHByb3RlY3Rpb24gZmF1bHQgcHJlc2VudGluZyBhcyBhIG51bGwtcG9pbnRlciBkZXJlZmVy
ZW5jZSwgY29uc2lzdGVudCB3aXRoIHRoaXMgYmVpbmcgYW4gYGluaXRfb25fZnJlZWAtc3R5bGUg
ZGVidWcga2VybmVsIHdoZXJlIGZyZWVkIHNsYWIgbWVtb3J5IHJlYWRzIGJhY2sgYXMgemVybyBy
YXRoZXIgdGhhbiBhcmJpdHJhcnkgcG9pc29uIGJ5dGVzKToKCmBgYApPb3BzOiBnZW5lcmFsIHBy
b3RlY3Rpb24gZmF1bHQsIHByb2JhYmx5IGZvciBub24tY2Fub25pY2FsIGFkZHJlc3MgMHhkZmZm
ZmMwMDAwMDAwMDAwOiAwMDAwIFsjMV0gS0FTQU4KS0FTQU46IG51bGwtcHRyLWRlcmVmIGluIHJh
bmdlIFsweDAwMDAwMDAwMDAwMDAwMDAtMHgwMDAwMDAwMDAwMDAwMDA3XQpDUFU6IDAgVUlEOiAw
IFBJRDogMjUwIENvbW06IGJhc2ggTm90IHRhaW50ZWQgNy4yLjAtcmM0KyAjMSBQUkVFTVBUTEFa
WQpSSVA6IDAwMTA6bmZzZDRfY2FuY2VsX2NvcHlfYnlfc2IrMHgxY2EvMHg5YzAKUkFYOiAwMDAw
MDAwMDAwMDAwMDAwIFJCWDogMDAwMDAwMDAwMDAwMDAwMCAuLi4KQ2FsbCBUcmFjZToKIDxUQVNL
Pgogd3JpdGVfdW5sb2NrX2ZzKzB4MjBjLzB4NzYwCiBuZnNjdGxfdHJhbnNhY3Rpb25fd3JpdGUr
MHhkNS8weDE0MAogdmZzX3dyaXRlKzB4MjRlLzB4MTA1MAoga3N5c193cml0ZSsweGZlLzB4MWUw
CiBfX3g2NF9zeXNfd3JpdGUrMHg3Ni8weGIwCiBkb19zeXNjYWxsXzY0KzB4OTEvMHg0ZjAKIGVu
dHJ5X1NZU0NBTExfNjRfYWZ0ZXJfaHdmcmFtZSsweDRiLzB4NTMKYGBgCgpgUkFYYC9gUkJYYCBy
ZWFkaW5nIGAwYCBhbmQgdGhlIGNyYXNoIGFkZHJlc3MgZmFsbGluZyBpbiBgWzB4MC0weDddYCBt
YXRjaGVzIGBoZWFkID0gJm5uLT5jb25mX2lkX2hhc2h0YmxbaWRoYXNodmFsXWAgYmVpbmcgY29t
cHV0ZWQgZnJvbSBhIGZyZWVkIChhbmQsIG9uIHRoaXMgZGVidWcgY29uZmlnLCB6ZXJvZWQtb24t
ZnJlZSkgYXJyYXkgcG9pbnRlciwgZXhhY3RseSB0aGUgbWVjaGFuaXNtIGRlc2NyaWJlZCBiZWxv
dy4gVGhlIHRyYWNlIG5hbWVzIGB3cml0ZV91bmxvY2tfZnNgIGFuZCBgbmZzZDRfY2FuY2VsX2Nv
cHlfYnlfc2JgIGRpcmVjdGx5LCB3aXRoIG5vIG90aGVyIGNvZGUgaW4gYmV0d2Vlbiwgd2hpY2gg
aXMgYWJvdXQgYXMgZGlyZWN0IGEgY29uZmlybWF0aW9uIG9mIHRoZSB0cmFjZWQgY2FsbCBjaGFp
biBhcyBhIGNyYXNoIHRyYWNlIGNhbiBnaXZlLgoKIyMgRmluZGluZzogYHdyaXRlX3VubG9ja19m
cygpYCByYWNlcyBORlNEIHNodXRkb3duLCB1c2UtYWZ0ZXItZnJlZSBvZiBgbm4tPmNvbmZfaWRf
aGFzaHRibGAKCi0gKipMb2NhdGlvbjoqKiBgZnMvbmZzZC9uZnNjdGwuYzoyNjgtMzEwYCwgZnVu
Y3Rpb24gYHdyaXRlX3VubG9ja19mcygpYCAodGhlIGhhbmRsZXIgYmVoaW5kIGAvcHJvYy9mcy9u
ZnNkL3VubG9ja19maWxlc3lzdGVtYCwgcmVnaXN0ZXJlZCBhdCBgZnMvbmZzZC9uZnNjdGwuYzox
MzAyLTEzMDNgIHdpdGggbW9kZSBgU19JV1VTUnxTX0lSVVNSYCwgaS5lLiB3cml0YWJsZSBvbmx5
IGJ5IHRoZSBmaWxlJ3Mgb3duZXIsIG5vcm1hbGx5IHJvb3QpLgotICoqQ1dFOioqIENXRS00MTYg
KFVzZSBBZnRlciBGcmVlKSwgQ1dFLTM2MiAocmFjZSBjb25kaXRpb24gLyBUT0NUT1UpLgoKYGBg
YwpzdGF0aWMgc3NpemVfdCB3cml0ZV91bmxvY2tfZnMoc3RydWN0IGZpbGUgKmZpbGUsIGNoYXIg
KmJ1Ziwgc2l6ZV90IHNpemUpCnsKCXN0cnVjdCBwYXRoIHBhdGg7CgljaGFyICpmb19wYXRoOwoJ
aW50IGVycm9yOwoJc3RydWN0IG5mc2RfbmV0ICpubjsKCS4uLgoJZXJyb3IgPSBrZXJuX3BhdGgo
Zm9fcGF0aCwgMCwgJnBhdGgpOwoJaWYgKGVycm9yKQoJCXJldHVybiBlcnJvcjsKCS4uLgoJbmZz
ZDRfY2FuY2VsX2NvcHlfYnlfc2IobmV0bnMoZmlsZSksIHBhdGguZGVudHJ5LT5kX3NiKTsKCWVy
cm9yID0gbmxtc3ZjX3VubG9ja19hbGxfYnlfc2IocGF0aC5kZW50cnktPmRfc2IpOwoJbXV0ZXhf
bG9jaygmbmZzZF9tdXRleCk7CglubiA9IG5ldF9nZW5lcmljKG5ldG5zKGZpbGUpLCBuZnNkX25l
dF9pZCk7CglpZiAobm4tPm5mc2Rfc2VydikKCQluZnNkNF9yZXZva2Vfc3RhdGVzKG5uLCBwYXRo
LmRlbnRyeS0+ZF9zYik7CgllbHNlCgkJZXJyb3IgPSAtRUlOVkFMOwoJbXV0ZXhfdW5sb2NrKCZu
ZnNkX211dGV4KTsKCglwYXRoX3B1dCgmcGF0aCk7CglyZXR1cm4gZXJyb3I7Cn0KYGBgCgpgbmZz
ZDRfY2FuY2VsX2NvcHlfYnlfc2IoKWAgKGBmcy9uZnNkL25mczRwcm9jLmM6MTU2NmApIGlzIGNh
bGxlZCBoZXJlIHdpdGggbm8gbG9jayBoZWxkIGFuZCB3aXRoIG5vIGNoZWNrIHRoYXQgTkZTRCBp
cyBldmVuIHJ1bm5pbmcuIEl0IHdhbGtzIHRoZSBmdWxsIGNsaWVudCBJRCBoYXNoIHRhYmxlOgoK
YGBgYwp2b2lkIG5mc2Q0X2NhbmNlbF9jb3B5X2J5X3NiKHN0cnVjdCBuZXQgKm5ldCwgc3RydWN0
IHN1cGVyX2Jsb2NrICpzYikKewoJc3RydWN0IG5mc2RfbmV0ICpubiA9IG5ldF9nZW5lcmljKG5l
dCwgbmZzZF9uZXRfaWQpOwoJLi4uCglzcGluX2xvY2soJm5uLT5jbGllbnRfbG9jayk7Cglmb3Ig
KGlkaGFzaHZhbCA9IDA7IGlkaGFzaHZhbCA8IENMSUVOVF9IQVNIX1NJWkU7IGlkaGFzaHZhbCsr
KSB7CgkJc3RydWN0IGxpc3RfaGVhZCAqaGVhZCA9ICZubi0+Y29uZl9pZF9oYXNodGJsW2lkaGFz
aHZhbF07CgoJCWxpc3RfZm9yX2VhY2hfZW50cnkoY2xwLCBoZWFkLCBjbF9pZGhhc2gpIHsKCQkJ
c3Bpbl9sb2NrKCZjbHAtPmFzeW5jX2xvY2spOwoJCQkuLi4KYGBgCgpXaGVuIE5GU0QgaXMgc3Rv
cHBlZCBpbiBhIG5ldCBuYW1lc3BhY2UsIGBuZnM0X3N0YXRlX3NodXRkb3duX25ldCgpYCBjYWxs
cyBgbmZzNF9zdGF0ZV9kZXN0cm95X25ldCgpYCAoYGZzL25mc2QvbmZzNHN0YXRlLmM6OTE2Mi05
MTg2YCksIHdoaWNoIGZyZWVzIHRoZSBhcnJheSB0aGUgaGFzaCB0YWJsZSBsaXZlcyBpbiBhbmQg
bnVsbHMgdGhlICJzZXJ2ZXIgcnVubmluZyIgZmxhZyBhcyBwYXJ0IG9mIHRoZSBzYW1lIHNodXRk
b3duIHNlcXVlbmNlOgoKYGBgYwpzdGF0aWMgdm9pZApuZnM0X3N0YXRlX2Rlc3Ryb3lfbmV0KHN0
cnVjdCBuZXQgKm5ldCkKewoJLi4uCglrZnJlZShubi0+c2Vzc2lvbmlkX2hhc2h0YmwpOwoJa2Zy
ZWUobm4tPnVuY29uZl9pZF9oYXNodGJsKTsKCWtmcmVlKG5uLT5jb25mX2lkX2hhc2h0YmwpOyAg
IC8qIGZzL25mc2QvbmZzNHN0YXRlLmM6OTE4NCAqLwoJcHV0X25ldChuZXQpOwp9CmBgYAoKYG5u
LT5uZnNkX3NlcnZgIGlzIHNldCBiYWNrIHRvIGBOVUxMYCBpbiB0aGUgc2FtZSBzaHV0ZG93biBw
YXRoIChgZnMvbmZzZC9uZnNzdmMuYzo1MTBgLCBgZnMvbmZzZC9uZnNjdGwuYzoyNDQ2YCkuIEFm
dGVyIHNodXRkb3duLCBgbm4tPmNvbmZfaWRfaGFzaHRibGAgaXMgYSBkYW5nbGluZyBwb2ludGVy
IGludG8gZnJlZWQgc2xhYiBtZW1vcnksIGFuZCBgbm4tPm5mc2Rfc2VydiA9PSBOVUxMYCBpcyB0
aGUgZG9jdW1lbnRlZCwgYWxyZWFkeS11c2VkIHNpZ25hbCB0aGF0IGl0IGlzIHVuc2FmZSB0byB0
b3VjaCBORlN2NCBzdGF0ZS4KCmB3cml0ZV91bmxvY2tfZnMoKWAgbmV2ZXIgY2hlY2tzIGBubi0+
bmZzZF9zZXJ2YCBiZWZvcmUgY2FsbGluZyBgbmZzZDRfY2FuY2VsX2NvcHlfYnlfc2IoKWAuIElm
IGEgY2FsbGVyIHdpdGggd3JpdGUgYWNjZXNzIHRvIGAvcHJvYy9mcy9uZnNkL3VubG9ja19maWxl
c3lzdGVtYCAocm9vdCwgb3IgYW55IHByb2Nlc3MgZ3JhbnRlZCB0aGF0IHNwZWNpZmljIGZpbGUn
cyB3cml0ZSBwZXJtaXNzaW9uKSBpc3N1ZXMgdGhlIHdyaXRlIGFmdGVyIE5GU0QgaGFzIGJlZW4g
c3RvcHBlZCBpbiB0aGF0IG5ldCBuYW1lc3BhY2UsIGBuZnNkNF9jYW5jZWxfY29weV9ieV9zYigp
YCByZWFkcyBgbm4tPmNvbmZfaWRfaGFzaHRibFtpZGhhc2h2YWxdYCBvdXQgb2YgZnJlZWQgbWVt
b3J5LCBpbnRlcnByZXRzIHdoYXRldmVyIGJ5dGVzIGFyZSB0aGVyZSBhcyBhIGBzdHJ1Y3QgbGlz
dF9oZWFkYCwgYW5kIGBsaXN0X2Zvcl9lYWNoX2VudHJ5KGNscCwgaGVhZCwgY2xfaWRoYXNoKWAg
d2Fsa3MgaXQsIHRha2luZyBgc3Bpbl9sb2NrKCZjbHAtPmFzeW5jX2xvY2spYCBvbiBhIGJvZ3Vz
IGBjbHBgIHBvaW50ZXIgZGVyaXZlZCBmcm9tIGZyZWVkL3JldXNlZCBtZW1vcnkuIFRoaXMgaXMg
YSBzdHJhaWdodGZvcndhcmQgc2xhYiB1c2UtYWZ0ZXItZnJlZSB3aXRoIGF0dGFja2VyLWluZmx1
ZW5jZWQgdGltaW5nIChzdG9wIHRoZSBzZXJ2ZXIsIHRoZW4gd3JpdGUgdGhlIGZpbGUpLgoKIyMg
V2h5IHRoaXMgaXNuJ3QgYSBkdXBsaWNhdGU6IHRoZSBtYWludGFpbmVyJ3Mgb3duIGZpeCBuYW1l
cyB0aGlzIGV4YWN0IHBhdGgKCkNvbW1pdCBgOTJlYTE2M2M3NzNjYCAoIk5GU0Q6IFByZXZlbnQg
cG9zdC1zaHV0ZG93biB1c2UtYWZ0ZXItZnJlZSBpbiBORlNEX0NNRF9VTkxPQ0tfRklMRVNZU1RF
TSIsIDIwMjYtMDctMDUsIGBGaXhlczogMzI3YzUxNjhlZmYyYCkgZml4ZWQgdGhlIGlkZW50aWNh
bCBidWcgaW4gdGhlIG5ldGxpbmstYmFzZWQgc2libGluZyBjb21tYW5kLCBgbmZzZF9ubF91bmxv
Y2tfZmlsZXN5c3RlbV9kb2l0KClgLiBCZWZvcmUgdGhlIGZpeCwgdGhhdCBmdW5jdGlvbiBoYWQg
ZXhhY3RseSB0aGlzIHNoYXBlOiBjYWxsIGBuZnNkNF9jYW5jZWxfY29weV9ieV9zYigpYCBiZWZv
cmUgdGFraW5nIGBuZnNkX211dGV4YCBvciBjaGVja2luZyBgbm4tPm5mc2Rfc2VydmAuIFRoZSBm
aXggbW92ZWQgdGhlIGBuZnNkNF9jYW5jZWxfY29weV9ieV9zYigpYCBjYWxsIHRvIGluc2lkZSB0
aGUgbXV0ZXgtaGVsZCwgYG5uLT5uZnNkX3NlcnZgLWNvbmZpcm1lZCBibG9jay4KClRoZSBjb21t
aXQgbWVzc2FnZSBzdGF0ZXMgcGxhaW5seToKCj4gIlRoZSBORlNEX0NNRF9VTkxPQ0tfRklMRVNZ
U1RFTSBuZXRsaW5rIGNvbW1hbmQgcnVucyBuZnNkNF9jYW5jZWxfY29weV9ieV9zYigpIGJlZm9y
ZSBuZnNkX211dGV4IGlzIGhlbGQgYW5kIGJlZm9yZSBubi0+bmZzZF9zZXJ2IGlzIGNvbmZpcm1l
ZCBzZXQsICoqdGhlIHNhbWUgcHJlLW11dGV4IG9yZGVyaW5nIHRoZSBwcm9jZnMgdW5sb2NrX2Zp
bGVzeXN0ZW0gcGF0aCBjYXJyaWVkKiouIgoKVGhhdCBzZW50ZW5jZSBpcyBkZXNjcmliaW5nIGB3
cml0ZV91bmxvY2tfZnMoKWAsIHRoZSBwcm9jZnMgaGFuZGxlciBmb3IgdGhlIHNhbWUgb3BlcmF0
aW9uIChgL3Byb2MvZnMvbmZzZC91bmxvY2tfZmlsZXN5c3RlbWAsIHJlZ2lzdGVyZWQgYXQgYGZz
L25mc2QvbmZzY3RsLmM6MTMwMi0xMzAzYCwgYm90aCBoYW5kbGVycyB1bHRpbWF0ZWx5IHJlYWNo
YWJsZSB0aHJvdWdoIGBuZnNkX2ZzLmNgJ3MgYG5mc2Rmc2AgYW5kIHRoZSBuZXRsaW5rIGZhbWls
eSBmb3IgdGhlIHNhbWUgbG9naWNhbCBjb21tYW5kKS4gVGhlIGZpeCdzIGRpZmYgb25seSB0b3Vj
aGVzIGBmcy9uZnNkL25mc2N0bC5jYCdzIGBuZnNkX25sX3VubG9ja19maWxlc3lzdGVtX2RvaXQo
KWA7IGB3cml0ZV91bmxvY2tfZnMoKWAsIGEgZmV3IGh1bmRyZWQgbGluZXMgYWJvdmUgaXQgaW4g
dGhlIHNhbWUgZmlsZSwgaXMgdW50b3VjaGVkIGFuZCBzdGlsbCBoYXMgdGhlIG9yZGVyaW5nIHRo
ZSBjb21taXQgbWVzc2FnZSBkZXNjcmliZXMgYXMgdW5zYWZlLgoKQ29uZmlybWVkIHZpYSBgZ2l0
IGxvZyAtLW9uZWxpbmUgOTJlYTE2M2M3NzNjLi5IRUFEIC0tIGZzL25mc2QvbmZzY3RsLmNgOiBl
bXB0eSBvdXRwdXQsIG5vIGNvbW1pdHMgdG8gdGhpcyBmaWxlIHNpbmNlIHRoZSBmaXggbGFuZGVk
IG9uIDIwMjYtMDctMDUsIHRocm91Z2ggY3VycmVudCBIRUFEIChgMGM0NTJmYmRmNDEzYCwgMjAy
Ni0wNy0yNCkuCgojIyBTdWdnZXN0ZWQgZml4CgpNaXJyb3IgdGhlIHNoYXBlIG9mIHRoZSBhbHJl
YWR5LWFwcGxpZWQgZml4OiBtb3ZlIGBuZnNkNF9jYW5jZWxfY29weV9ieV9zYigpYCBpbnNpZGUg
dGhlIGBtdXRleF9sb2NrKCZuZnNkX211dGV4KWAgLyBgaWYgKG5uLT5uZnNkX3NlcnYpYCBibG9j
aywgYWZ0ZXIgYG5uYCBpcyByZXNvbHZlZCBhbmQgY29uZmlybWVkLiBSb3VnaCBza2V0Y2gsIG5v
dCB0ZXN0ZWQ6CgpgYGBjCgllcnJvciA9IG5sbXN2Y191bmxvY2tfYWxsX2J5X3NiKHBhdGguZGVu
dHJ5LT5kX3NiKTsKCW11dGV4X2xvY2soJm5mc2RfbXV0ZXgpOwoJbm4gPSBuZXRfZ2VuZXJpYyhu
ZXRucyhmaWxlKSwgbmZzZF9uZXRfaWQpOwoJaWYgKG5uLT5uZnNkX3NlcnYpIHsKCQluZnNkNF9j
YW5jZWxfY29weV9ieV9zYihuZXRucyhmaWxlKSwgcGF0aC5kZW50cnktPmRfc2IpOwoJCW5mc2Q0
X3Jldm9rZV9zdGF0ZXMobm4sIHBhdGguZGVudHJ5LT5kX3NiKTsKCX0gZWxzZSB7CgkJZXJyb3Ig
PSAtRUlOVkFMOwoJfQoJbXV0ZXhfdW5sb2NrKCZuZnNkX211dGV4KTsKYGBgCgpUaGlzIGlzIG9m
ZmVyZWQgYXMgYSBzdGFydGluZyBwb2ludCBmb3IgdGhlIG1haW50YWluZXJzIHRvIGFkYXB0LCBu
b3QgYSBkcm9wLWluIHBhdGNoOyB0aGVyZSBtYXkgYmUgcmVhc29ucyBzcGVjaWZpYyB0byB0aGlz
IG9sZGVyIHByb2NmcyBpbnRlcmZhY2UgdGhhdCBjYWxsIGZvciBzb21ldGhpbmcgc2xpZ2h0bHkg
ZGlmZmVyZW50IGZyb20gdGhlIG5ldGxpbmsgZml4J3Mgc2hhcGUuCgojIyBTY29wZSBhbmQgaW1w
YWN0CgpUaGlzIHJlcXVpcmVzIGxvY2FsIHdyaXRlIGFjY2VzcyB0byBgL3Byb2MvZnMvbmZzZC91
bmxvY2tfZmlsZXN5c3RlbWAgKG93bmVyLW9ubHksIGVmZmVjdGl2ZWx5IHJvb3Qgb3IgYSBwcm9j
ZXNzIHNwZWNpZmljYWxseSBncmFudGVkIHRoYXQgY2FwYWJpbGl0eSkgYW5kIGEgc3RvcHBlZCBO
RlNEIHNlcnZlciBpbiB0aGUgcmVsZXZhbnQgbmV0IG5hbWVzcGFjZSwgbWF0Y2hpbmcgdGhlIGFj
Y2VzcyBsZXZlbCB0aGUgYWxyZWFkeS1maXhlZCBuZXRsaW5rIHNpYmxpbmcgcmVxdWlyZWQuIE5v
dCByZW1vdGVseSB0cmlnZ2VyYWJsZS4gSW1wYWN0IGlzIGEga2VybmVsIHNsYWIgdXNlLWFmdGVy
LWZyZWUsIHBsYXVzaWJseSBhIGNyYXNoIGFuZCBwb3RlbnRpYWxseSBmdXJ0aGVyIGNvcnJ1cHRp
b24gZGVwZW5kaW5nIG9uIHdoYXQgcmVvY2N1cGllcyB0aGUgZnJlZWQgYGNvbmZfaWRfaGFzaHRi
bGAgYWxsb2NhdGlvbiBieSB0aGUgdGltZSBpdCdzIHdhbGtlZC4K
--0000000000009398e30658015d3a--
