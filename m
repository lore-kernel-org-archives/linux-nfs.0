Received: from mail-qv1-f42.google.com (mail-qv1-f42.google.com [209.85.219.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 378063AF66E
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 14:05:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.219.42
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786370713; cv=pass; b=F9tGFSPE2/n+oa0ApvRsEWlVqECWJKV+AyKbuksI76LnOO04WnmuBg1XGgWwY6tAKS6MiVeLWh3PgsPqAo3NfTLzYZfELIy/toLDkgHaTBk6LU0cXfeLKqtEOviSk/AOktG10pa0VcrprGXVhGi0ux71NkTr9VVXf8w0gaICHCU=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786370713; c=relaxed/simple;
	bh=wQK4iC+iVboZVQ0TbBvuUd5c8pU8uXP8R69wO9Cbm1Q=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=q12wFt6TLku69jXxYpaTaqaZGGFd+V2ejZ8/DhRKtGH/lbr0WqZMnuT113fGjyR6ohLKD6tjRtv5pIk0PJK2SysC/WUlcH/jfOH6XoutRvxK7bf1C2WNJl+kBXNkg5+F4mELJ7mWp74cGP2654l7ocezK0w5cOytqCwxusJBk38=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu; spf=pass smtp.mailfrom=szeredi.hu; dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b=myhmKgHT; arc=pass smtp.client-ip=209.85.219.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=szeredi.hu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="myhmKgHT"
Received: by mail-qv1-f42.google.com with SMTP id 6a1803df08f44-8efec2c28f8so11392756d6.2
        for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 07:05:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1786370710; cv=none;
        d=google.com; s=arc-20260327;
        b=JXa4eXLS4i3OZoPJlQzi359n1kyTeISgTLPHl02VM00/5iuyMC/5RTlHmk6MxgzT4b
         EOhmpHZfG5yJAd8+Eg+1g+YypGUbKjcl/KUVPp6+j/OTcIUYRnzeuOlMbUDVLahh/F0W
         pWVH/faNKUoHYYG/UkYsgVqWm0ZV2xU4etCHvz4enmk+oCqUoZ2RKOSM5rE4CG+jFM4B
         ayECAuEfYCP27cM6TqsDNxeRuM5NtzlI0NiptXd2p+dB64HMmec4OSdTijUV/fm5E5qo
         sZVF6RRaKeo/e3z/3jPI9UBopa9fIaVdM4nwD1ICFjd5cvpLZ4G/zbABjeyddL7B3bur
         9Xgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=NV+45oOv6d8nxP4iat2b7fdyPFUDUzYrSvuxe5NbF8Q=;
        fh=+6uOEDJWNWyNMZc8CfmpAEapJvcJgrgqfgZwek1uU1M=;
        b=EcI9ABtEmDf0AYxhdCPvitp1XGTRdoWdgFRVaJi3wBtKfgQNlI1Eshw5XaKUln6KMe
         17ycrUBZvFek3HaB2qdZNmPc6uzkRM/KgkarQHiyVfCkPMlmCTdRzofoDN+SB2YqAqZC
         SXurd+hHfX0q0a2b3oN/993DYUpvn9yZWd7X5oV22s7PFpJcxNOfQSN4BARSPzfqVuCv
         sxRW8LVpEyE4b2ONxH3rw9mEZNxWX5y5iXFLIm6HWG/7/OskalavO3Jf301nDx3lMOsU
         /QaVHZXuZGNUHcV7n9Mv9JX+StHWgQ2X1F6W71kye4cqMXcrmMxpR/FOnxEPvS02NT0v
         NDuw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google; t=1786370710; x=1786975510; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=NV+45oOv6d8nxP4iat2b7fdyPFUDUzYrSvuxe5NbF8Q=;
        b=myhmKgHTG1hXWp+ZWdXS/rOTTX/n2t2qUF8gwZnkEQrZniSCmin6lDe/80YepezVa6
         121u1I/avdUEU9WLXbOvUTKTDZnRMENu9eDMm34cdrmTSuVA63UMoNjjk1PYE/pAvemd
         YBbtcfpvyQ4CvlD5YmCvZn51m6vllAzMISc9c=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786370710; x=1786975510;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=NV+45oOv6d8nxP4iat2b7fdyPFUDUzYrSvuxe5NbF8Q=;
        b=XhJ0rKoghkWjFMjm71JWhMBcaq2tFo5K1aC2YbMNqTqOZ/OAf5/dtZPyWCHqEGDQI2
         Rof9sg1C+c+uaCTL9UgC/7AHJIE7dqW76hEJTPMA4vEwX0sE1euOwl/C6TNW4n6eH0lj
         NW+ept545n3yiC9PjDt0fpWGmBkHjKz8f+Wn7TwYF24c9fwKNNLpJf8YfBj/4ICfFQRh
         wiW7BSURLn9gnt6WsKP+US0gKE7+E/6kbnY0os/YTiT+n6f7R74HMPFuXZAKeEgqBplr
         8IqI25mlnpKGQQt33+DrOFq7jnqlKmZ11S4ybgnqnRBJxSfvQLXkESRWERAqIpv+Uou8
         hYBg==
X-Forwarded-Encrypted: i=1; AHgh+RpLsIOkhz5KaI0HoDUvD9dW27KePySWBzMUvLB1y9BTVeCpFwCN+c9H9EmlRXrKH1xUAvwvgpLgUDs=@vger.kernel.org
X-Gm-Message-State: AOJu0YyCRXotuoO0MF5SwiUDdoB/dFaO6cyFLNZYYde7UrxMqHx2WMVC
	BaYVDidtpUiI7s06vBnlRPvqPgZEOUvg8z+keBbBnUJoV2su1hdQjHRiI/x9RvxSCEYQpbchpdb
	y2QBGbP+VE6BW0MXIqMR2rtO/KFKCU+OQ3UG+HwmMIQ==
X-Gm-Gg: AR+sD137Ji7MuHsbkblp47UFBfzGaoDeIGftmfXkGyh0R7pZT6JyUXx3G/fkqyXkELu
	E7OS4FptA9NfgvPcvSqVpHSgZzuVcr1ZoZjmSFX1gfc6Sx3bPq4/MhMrVCw09L4AYoSWbbJV0kA
	cwBxFQnuGrXhevZ9EmBf28lhkfftKTEFA7fVbnyHvxjjSe7+yJs/DfU0syKnAZlX8AT+GdZ3jD3
	huDEs7x16owJMYHM5mN3+aPaujJjgUNh5Vr6pIpzwgwE5ocKR1h7hZlUldKxxGJ9CVr1NQKkSn7
	hnsiFIevjgmF8nMqy7zimZH0ATMmAtyOpHEqChYkV0grkwKpArw7zi55OwrjHW0nBtMdhYB0ZNE
	=
X-Received: by 2002:ac8:5cc5:0:b0:51c:207f:6524 with SMTP id
 d75a77b69052e-52d1919e59dmr254953691cf.37.1786370709751; Mon, 10 Aug 2026
 07:05:09 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260803012648.2195405-1-neilb@ownmail.net> <20260803012648.2195405-3-neilb@ownmail.net>
In-Reply-To: <20260803012648.2195405-3-neilb@ownmail.net>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 10 Aug 2026 16:04:56 +0200
X-Gm-Features: AUfX_mwOr6H9OqGZCernhbLrr_tuorcVZn-K7EOk-lg62vULXKmdHLNqnvpAUNY
Message-ID: <CAJfpegvTXG_kJHyFB115zdQvbyvDNtfqA_Mv9UKiEf9BE5qXwQ@mail.gmail.com>
Subject: Re: [PATCH v1 02/12] Add and use d_for_each_positive_child family of iterators
To: NeilBrown <neil@brown.name>
Cc: Ian Kent <raven@themaw.net>, Chuck Lever <cel@kernel.org>, Jake Edge <jake@lwn.net>, 
	Ilya Dryomov <idryomov@gmail.com>, Alex Markuze <amarkuze@redhat.com>, 
	Viacheslav Dubeyko <slava@dubeyko.com>, Jan Harkes <jaharkes@cs.cmu.edu>, coda@cs.cmu.edu, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>, 
	Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
	Amir Goldstein <amir73il@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Miklos Szeredi <mszeredi@redhat.com>, autofs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	ceph-devel@vger.kernel.org, codalist@coda.cs.cmu.edu, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Mon, 3 Aug 2026 at 03:38, NeilBrown <neilb@ownmail.net> wrote:

> coda_flag_children() doesn't need rcu_read_lock() as holding any
> spinlock prevents an RCU critical section from finishing.

I think prep changes should go in separate patches.

The conversion should be an equivalent transformation.

> nfs_clear_verifier_directory() is changed slightly so the parent lock is
> dropped and retaken between clearing the verifier on the parent and on
> all the children.  I think this is safe.

This can also be a prep patch.

> get_next_postive_dentry() in autofs now holds the parent lock a bit
> less.  The only non-trivial code that is no locked any more is
>    parent = p->d_parent
> This cannot need the lock as autofs doesn't support rename and
> a ref is held on a descendent of parent, so ->d_parent cannot
> change.  And if it could, the lock wouldn't help.

And this too.

> diff --git a/fs/autofs/expire.c b/fs/autofs/expire.c
> index 5c2d459e1e48..7b0a22629415 100644
> --- a/fs/autofs/expire.c
> +++ b/fs/autofs/expire.c
> @@ -70,12 +70,9 @@ static int autofs_mount_busy(struct vfsmount *mnt,
>         return status;
>  }
>
> -/* p->d_lock held */
>  static struct dentry *positive_after(struct dentry *p, struct dentry *child)

Move this primitive to libfs.c?

> --- a/fs/ceph/mds_client.c
> +++ b/fs/ceph/mds_client.c
> @@ -2182,14 +2182,10 @@ static bool drop_negative_children(struct dentry *dentry)
>         if (!d_is_dir(dentry))
>                 goto out;
>
> -       spin_lock(&dentry->d_lock);
> -       hlist_for_each_entry(child, &dentry->d_children, d_sib) {
> -               if (d_really_is_positive(child)) {
> -                       all_negative = false;
> -                       break;
> -               }
> +       d_for_each_positive_child(child, dentry) {
> +               all_negative = false;
> +               break;
>         }
> -       spin_unlock(&dentry->d_lock);

simple_empty()?

Thanks,
Miklos
