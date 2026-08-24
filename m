Received: from mail-ed1-f51.google.com (mail-ed1-f51.google.com [209.85.208.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EFF53F5BE6
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 17:19:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.208.51
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787591975; cv=pass; b=gdYYi70yys7L7GaJ1t3ocY/26I0d7WtKNxgpNxvsYcvvSPvEOc3xA2HJ1mnQeMfiHdzkV4a8r7EuGPBmjyuzezfqBzoeailVj5otNoKv37kJcqIBm4G1HGaX5FPbMz+qXw1J+GL8NfxW3m+zUGL+q3Ni5N8QDycz1JcVkmVXz5I=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787591975; c=relaxed/simple;
	bh=9szRXNz+1rbQ1qPmMhoZClR1R6MTvny3zRZAdVoNZ9A=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=MlirxVxLqe8MkPr0p/Pr1w5AnJolD6WnWac4Af6HUT4izCBqhnX+zcbrlz7cJw2iReoQUsseAsUl74/xp9RePYvWp0K3hKcrR1QEXEtHnKSK0gtEPzShJyG945REBdIRSyYDrA6nFgvbuNPTQ+QjmUvX3tp52d5Cb6WlcN1WqaE=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=XjWU3A/h; arc=pass smtp.client-ip=209.85.208.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XjWU3A/h"
Received: by mail-ed1-f51.google.com with SMTP id 4fb4d7f45d1cf-6a051b737d8so4698247a12.1
        for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 10:19:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787591971; cv=none;
        d=google.com; s=arc-20260327;
        b=gtu5bGJPsyMwx7KpBlpnu8QZrmPgwAsNeVoFBYwM/y7I6n6JaNDrD5i8rIRyoMNznk
         /59ElepAlJiJH8/T/O0r6wBu7nSiue8vgOK4K72F0HgOuZcCLDBXw5rjGGfhyZJQqYVb
         dAlLTp7AxjXQ3XJdC28vm1DrMaEJ8h2W7yQ2S2sBZhUaCz98KAnMO2/SGoghZZ9n25hP
         sw7Tf39Hwo+Cm4wfC2o1WYLEvO647np1bUO7ecb6EBdAoNH1v8+u22bIk5mfjrgY3XJ5
         wQ0kz8EdjjENjualnbAeLAoXi76ClurfUkcmxvjzVTu3SMw/o1D+A0ftF6hc/GPsUL5K
         mH1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=hAvzxihNiFtM0K3Wr9CDqWroU4/ZmBDLBIfShjTV4Pc=;
        fh=+23kccuru2GfULYo+iabYjgZJrPbkIxsAcLNcONAgw4=;
        b=lRGPd88jyvlZi9fLomj1Vo7YxjXeEZnU6H4RCLJ1UsgSp+SGcFsxhEm9VTcNeybTJv
         jVe0biANGJiaof7iFtiYaXvsk0vJwCmSCTwgz6wK5t2n9OohEaYr1Lw6QD/XT90aSXDy
         6h0FnUQwcTe85tz8OVo66lNPdJV40xk0NSvE/3g9gJS2ZGHQTu0AR0Df+KyylCu0Dp17
         M+NS65OyI0lwtUg3Pm0YItL2LqNX+cWHwScGAIc2QIyNRo5FiYSK+uUzawbeX78SK+9I
         7XfmI72GOSDPTyLSSER+fYaaWHHhZPFXeO9nmU4yzFnTUWfp2oGvBrV4tgxAZbQo3w3T
         lgjw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787591971; x=1788196771; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=hAvzxihNiFtM0K3Wr9CDqWroU4/ZmBDLBIfShjTV4Pc=;
        b=XjWU3A/h1HLrhHE0fJyK2MiRDzpMsGWp3NL710HfYjL73Kmdpax/vm9J6Cvd6JAsPE
         sNYrbGvcGbR5nJ7eZOzdnwZ6AF7XqjSB/BJ1S/wBSJSxvzUVMVj2j6u0NKhZrX6mY9SD
         5ITO3kHgfu2U3B/6LAz3wkaJRscUHlr4q328dIaCyIDWx7BG6jN61znD8eFwrUMHmG9I
         Rezk53FSU2/gMkv8hD1OTGJru+D33imEOeT9wenjEriIc4v3La7SPvYvQE+b6M2T5JBz
         XRN3NeNBd0j3gufKoivC9AI99XtdYxg1jmP/9cfWPCXmpurp9gBDC5CJFrPoUsJl5H5r
         0Iyg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787591971; x=1788196771;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=hAvzxihNiFtM0K3Wr9CDqWroU4/ZmBDLBIfShjTV4Pc=;
        b=ZH1S1PdijOmZv4VZTha8qEtuMMuq4EZ2mLXyfuIOS8wu7Ujv6o2W4gvK8LZ4GrAUBy
         OAVlL+HWuB96is12pRHzTedyZfHgaLuWTKmk0FU3viKuVULjnhFzqYGMqIYP/f4CYp7H
         M5YK+QCRO7sswKistIwW0UqCI92ispyFTsr6nXdkvLlRs0GcQw/SY4d0sXQyCQIu44pA
         ryx3AZ20n8fvsy5iX+fSPNPQ6r66TDHhdeS7pnh0xJdBbNPuNwBG74HMoGHzuTUC2RKP
         4buQVUkNIge/acsA8R2Yb48h18zntKDDsm5wt8AeyVccECm+pXYipuVGLSCeHbwivFaN
         hSpA==
X-Forwarded-Encrypted: i=1; AHgh+RpikBILeTyXGL9vbIa7zABVtRA0dr1JSNMj4GmC5dyA/7f44r++bT7W2tZL95mDP/uhB6mhw3Jnt+o=@vger.kernel.org
X-Gm-Message-State: AFuF++k/lmzKv51T8cRBBQgP8VOLLy8GtAK5/vRNQPJkj7uCr4P/+VLi
	81uKH6Z0fbKtxN9yVvzuiZ1lrrLRrXQVkyCao5XcpfZjbrcfPtQIdlQPzCY4VtKQLoLU7MNPQ8W
	dXDiNLVSOPjpaykezzdu60QBR7+Rac6o=
X-Gm-Gg: AR+sD10qPD2vXL6mupIJfq+Ofnm2QeMt57Ltxz/uSJOYKTw2ER7+xu1aq7kAn0LPPpc
	uXXEjxeMGoW2VAhYM+xPR2MjnWiVwsWSqJKtVfY8n4tqsc3pr4gfqh2xTXftfRRVt/me28TO1Zt
	BNGB33mXXcPaau87bzf2UFnebJuUV4QpJy2LSi51ekZW5rPT1waWtYAXIS9U0vGI0Auui7E0G8y
	SsZ+nzVmkklFw0SUB6XQNcG+6wxYhj8vOe4/x0bdaLr6RtowAJVRCPXGT9Aeom3bzxU+Q97lJDq
	yTFJNKYXUfQ55WYpec2df61gSlt+f38rGk/KhimmTDRJWJbJtAC8VvkK
X-Received: by 2002:a05:6402:254f:b0:6a0:9c84:ce0e with SMTP id
 4fb4d7f45d1cf-6a5c414f08bmr300600a12.14.1787591971270; Mon, 24 Aug 2026
 10:19:31 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260824161021.245575-1-cel@kernel.org>
In-Reply-To: <20260824161021.245575-1-cel@kernel.org>
From: Amir Goldstein <amir73il@gmail.com>
Date: Mon, 24 Aug 2026 19:19:19 +0200
X-Gm-Features: AcwNN1W_Jkk999mAIT6mTotVsZn7LO3MMN0Ci3O6rzFYDCFOV23BjVOjeaFyHYI
Message-ID: <CAOQ4uxgCrwDCX88uC=cDr16hQVHOkaPJBppLk740vmGpA4Ya8w@mail.gmail.com>
Subject: Re: [PATCH v1] splice: emit a single fsnotify access event per NFSD READ
To: Chuck Lever <cel@kernel.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, 
	Ameer Hamza <ameer.hamza@truenas.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 24, 2026 at 6:10=E2=80=AFPM Chuck Lever <cel@kernel.org> wrote:
>
> nfsd_finish_read() calls fsnotify_access() on both NFSD read paths,
> because splice_direct_to_actor() does not emit the event itself. The
> iterator path reaches nfsd_finish_read() from vfs_iocb_iter_read(),
> which has already emitted one. A READ served without splice therefore
> emits two access events.
>
> NFSD does not use splice for the GSS integrity and privacy services, so
> a READ on a sec=3Dkrb5i or sec=3Dkrb5p mount takes the iterator. An inoti=
fy
> watch on that file sees the READ twice.
>
> Reported-by: Ameer Hamza <ameer.hamza@truenas.com>
> Closes: https://lore.kernel.org/linux-nfs/20260818225715.572140-1-ameer.h=
amza@truenas.com/
> Suggested-by: Amir Goldstein <amir73il@gmail.com>
> Link: https://lore.kernel.org/linux-nfs/CAOQ4uxgUOqFv6pVmdT_+4DjA0KQoQDCz=
N2Xz=3Dxm1FyumewHZXg@mail.gmail.com/
> Signed-off-by: Chuck Lever <cel@kernel.org>

Reviewed-by: Amir Goldstein <amir73il@gmail.com>
> ---
>  fs/nfsd/vfs.c          |  7 ++----
>  fs/splice.c            | 56 +++++++++++++++++++++++++++++++-----------
>  include/linux/splice.h |  4 +--
>  3 files changed, 45 insertions(+), 22 deletions(-)
>
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index f9131827d391..c134064a1c79 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1046,7 +1046,6 @@ static __be32 nfsd_finish_read(struct svc_rqst *rqs=
tp, struct svc_fh *fhp,
>                 nfsd_stats_io_read_add(nn, fhp->fh_export, host_err);
>                 *eof =3D nfsd_eof_on_read(file, offset, host_err, *count)=
;
>                 *count =3D host_err;
> -               fsnotify_access(file);
>                 trace_nfsd_read_io_done(rqstp, fhp, offset, *count);
>                 return 0;
>         } else {
> @@ -1080,10 +1079,8 @@ __be32 nfsd_splice_read(struct svc_rqst *rqstp, st=
ruct svc_fh *fhp,
>         ssize_t host_err;
>
>         trace_nfsd_read_splice(rqstp, fhp, offset, *count);
> -       host_err =3D rw_verify_area(READ, file, &offset, *count);
> -       if (!host_err)
> -               host_err =3D splice_direct_to_actor(file, &sd,
> -                                                 nfsd_direct_splice_acto=
r);
> +       host_err =3D vfs_splice_direct_to_actor(file, &sd,
> +                                             nfsd_direct_splice_actor);
>         return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, hos=
t_err);
>  }
>
> diff --git a/fs/splice.c b/fs/splice.c
> index 9d8f63e2fd1a..42ad712a0f4d 100644
> --- a/fs/splice.c
> +++ b/fs/splice.c
> @@ -1009,21 +1009,14 @@ ssize_t vfs_splice_read(struct file *in, loff_t *=
ppos,
>  }
>  EXPORT_SYMBOL_GPL(vfs_splice_read);
>
> -/**
> - * splice_direct_to_actor - splices data directly between two non-pipes
> - * @in:                file to splice from
> - * @sd:                actor information on where to splice to
> - * @actor:     handles the data splicing
> - *
> - * Description:
> - *    This is a special case helper to splice directly between two
> - *    points, without requiring an explicit pipe. Internally an allocate=
d
> - *    pipe is cached in the process, and reused during the lifetime of
> - *    that process.
> - *
> +/*
> + * This is a special case helper to splice directly between two
> + * points, without requiring an explicit pipe. Internally an allocated
> + * pipe is cached in the process, and reused during the lifetime of
> + * that process.
>   */
> -ssize_t splice_direct_to_actor(struct file *in, struct splice_desc *sd,
> -                              splice_direct_actor *actor)
> +static ssize_t splice_direct_to_actor(struct file *in, struct splice_des=
c *sd,
> +                                     splice_direct_actor *actor)
>  {
>         struct pipe_inode_info *pipe;
>         ssize_t ret, bytes;
> @@ -1147,7 +1140,40 @@ ssize_t splice_direct_to_actor(struct file *in, st=
ruct splice_desc *sd,
>
>         goto done;
>  }
> -EXPORT_SYMBOL(splice_direct_to_actor);
> +
> +/**
> + * vfs_splice_direct_to_actor - splice from a file through a caller's ac=
tor
> + * @in:                file to splice from; must be seekable (FMODE_LSEE=
K)
> + * @sd:                splice parameters. The caller sets @sd->pos and
> + *             @sd->total_len. @sd->pos advances as data is consumed,
> + *             and @sd->total_len is overwritten with the length of
> + *             each read.
> + * @actor:     consumes each pipe-full and returns the number of
> + *             bytes taken
> + *
> + * Description:
> + *    Splice from @in through @actor, for a caller that consumes
> + *    the data itself rather than sending it to a second file.
> + *    This helper verifies the read and emits the fsnotify access
> + *    event. do_splice_direct() leaves both to its callers.
> + *
> + * Return: The number of bytes spliced, or a negative errno.
> + */
> +ssize_t vfs_splice_direct_to_actor(struct file *in, struct splice_desc *=
sd,
> +                                  splice_direct_actor *actor)
> +{
> +       ssize_t ret;
> +
> +       ret =3D rw_verify_area(READ, in, &sd->pos, sd->total_len);
> +       if (ret < 0)
> +               return ret;
> +
> +       ret =3D splice_direct_to_actor(in, sd, actor);
> +       if (ret >=3D 0)
> +               fsnotify_access(in);
> +       return ret;
> +}
> +EXPORT_SYMBOL(vfs_splice_direct_to_actor);
>
>  static int direct_splice_actor(struct pipe_inode_info *pipe,
>                                struct splice_desc *sd)
> diff --git a/include/linux/splice.h b/include/linux/splice.h
> index 9dec4861d09f..4e91d03ed645 100644
> --- a/include/linux/splice.h
> +++ b/include/linux/splice.h
> @@ -79,8 +79,8 @@ ssize_t add_to_pipe(struct pipe_inode_info *pipe, struc=
t pipe_buffer *buf);
>  ssize_t vfs_splice_read(struct file *in, loff_t *ppos,
>                         struct pipe_inode_info *pipe, size_t len,
>                         unsigned int flags);
> -ssize_t splice_direct_to_actor(struct file *file, struct splice_desc *sd=
,
> -                              splice_direct_actor *actor);
> +ssize_t vfs_splice_direct_to_actor(struct file *file, struct splice_desc=
 *sd,
> +                                  splice_direct_actor *actor);
>  ssize_t do_splice(struct file *in, loff_t *off_in, struct file *out,
>                   loff_t *off_out, size_t len, unsigned int flags);
>  ssize_t do_splice_direct(struct file *in, loff_t *ppos, struct file *out=
,
> --
> 2.54.0
>
