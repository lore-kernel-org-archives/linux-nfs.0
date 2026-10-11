Received: from mail-wm1-f48.google.com (mail-wm1-f48.google.com [209.85.128.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B79363CA4AD
	for <linux-nfs@vger.kernel.org>; Sun, 11 Oct 2026 05:29:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791696595; cv=none; b=b83LY7St5Sf/OSCIDD161eXnWrd8qwr+l1jms2V9eLlO6HAzO6CBpTjJmC6fRELNn/AjXDQ/stfsBUFTuU4SIvgAqk622q/FqkQlwI8JQzBnjoUr5zsPGtzzD428GhcqMiMHlLxA5K2J556MCmutNGz0vCXCuXIWcPv5ESiNN7o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791696595; c=relaxed/simple;
	bh=1haV4dNMWDdQWqZsUuA0TFAZtQMdcpLXPmSnhiji0ao=;
	h=From:To:Cc:Subject:Message-ID:In-Reply-To:References:Date:
	 MIME-Version:Content-Type; b=uPyiX0RYcdQe7v9Hwq1SRHNoIKOcCUa22e7aUOGAFqWKNOm6BUqejwdF5t8oIp6mwVa45ZeBokndgB9i7ALAOkUc1juid4rNepjijq8QTqQ1UAx/B+HXe7MoIfYf1ne4KNzxj2gXFWZ5SnjH3fsb/XgQe1TbDmUBmi+LLSFPz+Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=innovatrics.com; spf=pass smtp.mailfrom=innovatrics.com; dkim=pass (1024-bit key) header.d=innovatrics.com header.i=@innovatrics.com header.b=sG+ClBZE; arc=none smtp.client-ip=209.85.128.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=innovatrics.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=innovatrics.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=innovatrics.com header.i=@innovatrics.com header.b="sG+ClBZE"
Received: by mail-wm1-f48.google.com with SMTP id 5b1f17b1804b1-4a166199820so5244305e9.1
        for <linux-nfs@vger.kernel.org>; Sat, 10 Oct 2026 22:29:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=innovatrics.com; s=google; t=1791696592; x=1792301392; darn=vger.kernel.org;
        h=content-type:mime-version:date:references:in-reply-to:message-id
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=q2LSr6tsQNBQXJylfG8nOPgyPFtDzDbVgLjnyN+NvOY=;
        b=sG+ClBZEZshyYL12WpUA8gi5U4p3Lf2TUW5h8eG3RZVknGgosp9xUBym2Jg7on3Bti
         u3YWy87k/lf3MT3ptjbhL28yBia/RGwBWim2B6spsjnWSKbqf/PRWIODLjHoWquV6rf6
         lWE+oxJb1L+70J2GVpC844oToN87Xc7V4+zzg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791696592; x=1792301392;
        h=content-type:mime-version:date:references:in-reply-to:message-id
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=q2LSr6tsQNBQXJylfG8nOPgyPFtDzDbVgLjnyN+NvOY=;
        b=EGzycpyveyLWqKpaTewKgIdS69jYKIgQ5gzAjewTX8EWV1d5sm+WdoyocvJn0DoZHk
         PYQcI0ZYtXwB8GaNN/juoX1WzC9ltF5C1VPuTQfAH6YxcI4JuXo7FnarI1sgGFufYpXB
         1l7QyRCCWKAu0TOCiHF9nwclgFjMdeIVla9d0wkgpYaMR/YyT6vdLxKTb+xaYZnVUHNs
         6vPVQldKXrQZrnCco49RDAg1R4GPrJXJE+oLF6+q/oyA1wrw8/M49HIaMf4ygdg2Fmuk
         /qB5CVVHrDVHsbqtYuF/KqRr/GH4GDOcta+w93jMrYonEEET9tLhBCfdrnc8/aKbJPGr
         VMEQ==
X-Forwarded-Encrypted: i=1; AKwUvBxWpL8dAmoWxleXHQz3AVoWGce77ydnWA9iIgkpdxSod/gxPXHVN4RIWcnOjs9u7DAB3ogTaENxaKI=@vger.kernel.org
X-Gm-Message-State: AFq9FYItjUAk227rMh30imdPmZywzgTJMx0YwwvoH+sxZn+41rvpVjPX
	/rwrnpg1Z9w6MQsM6Q253gCUpJrixPlxTtjtJ/yjAY68igI1lBwHilct+eLviEa+bg==
X-Gm-Gg: AYBFou3w2a1+v6DQxI+Xc+BUxvydOnPDIbaKG8A4RQMGJ5MT/vznNCL8pvx/MGNYDCy
	IcbO/yEtgtmvdIA0uzSGukhqstlUU5fdL8wlAuZC2muMqepp9v/3mMZcw5wBMnIErwMMcKuHsQe
	LMz7O7xX+DgM/wiZQ3kUxrjLM+EyM5+earp2eUaF+2ibfQyFR1uHlT/xVSQ+w2Ou9a5VvbB5qH3
	cT/eUNdR2DiieJ5BibXe4LrXe9VBxARzblu+djowKZDehsyRpNJeFrWeGCbFNVXO+6kNqEvrfRy
	N59Xl6d9JxqbvUvAmO2qj8xCyh/Rv45T92gVc082w9Ha1beD7qLIHThNaQdoLRKZJFdr2oVpgzT
	sZDrafEOD6yyvfumkbBTcD+mzg8XZAN1k0mXxNpt4pbT4Ug/scVpZfg7dYho0lMGSKLFcHmdliD
	9HKKZFrJ3bDlx0o3Z794+qCz8DuEHlGAPIiv0jjQebupU5lUsBqbHLf+iuvXTUUzubr7oFsO9J5
	nMtEhtuH7dMBzfmQA8pJUfHq5zc7WJtcOx6u7PTQdsrmsYwwFCi8u3gXywaE/C41snrLwr9L8Pu
	vTdq6IL0A62+i5/7NFlTHeiz59Nf0cg=
X-Received: by 2002:a05:600c:3146:b0:4a0:34a:588c with SMTP id 5b1f17b1804b1-4a18e4a7cb9mr117216165e9.14.1791696591843;
        Sat, 10 Oct 2026 22:29:51 -0700 (PDT)
Received: from [10.11.72.5] (bip-static-148.213-81-147.telecom.sk. [213.81.147.148])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4a18bea0f1csm277235065e9.9.2026.10.10.22.29.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 10 Oct 2026 22:29:51 -0700 (PDT)
From: Petr Chmelar <petr.chmelar@innovatrics.com>
To: David Howells <dhowells@redhat.com>
Cc: Christian Brauner <christian@brauner.io>,
    Paulo Alcantara <pc@manguebit.org>,
    Matthew Wilcox <willy@infradead.org>,
    Namjae Jeon <linkinjeon@kernel.org>,
    Marc Dionne <marc.dionne@auristor.com>,
    Stefan Metzmacher <metze@samba.org>,
    Eric Van Hensbergen <ericvh@kernel.org>,
    Dominique Martinet <asmadeus@codewreck.org>,
    Ilya Dryomov <idryomov@gmail.com>,
    netfs@lists.linux.dev,
    linux-afs@lists.infradead.org,
    linux-cifs@vger.kernel.org,
    linux-nfs@vger.kernel.org,
    ceph-devel@vger.kernel.org,
    v9fs@lists.linux.dev,
    linux-fsdevel@vger.kernel.org,
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH v12 0/5] netfs, cachefiles: Changes for next, primarily
 occupancy tracking-related
Message-ID: <20261011.cachefiles-seek-hole-walk.pchmelar@innovatrics.com>
In-Reply-To: <20260910220242.2165023-1-dhowells@redhat.com>
References: <20260910220242.2165023-1-dhowells@redhat.com>
Date: Sun, 11 Oct 2026 05:29:50 +0000
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"

Hi David,

The cover letter leaves non-contiguous objects, which still use
SEEK_DATA/SEEK_HOLE, for a later series.  We hit that case badly in
production, so here are numbers in case they help with its priority.

Objects get into that state when a large file is read at random
offsets, as training jobs do with data sets on NFS.  Each read is
copied to the cache at its own offset, and with other files being
cached at the same time most pieces end up in separate XFS extents.  The
object is BACKFS_MAP from the first discontiguous write and stays so
once it has filled in.

SEEK_HOLE has no upper bound.  On XFS, iomap_seek_hole() calls
xfs_seek_iomap_begin() once per extent until it finds a hole, and in a
fully populated object the only hole is EOF.  cachefiles probes the
occupancy at least once per read request, so a sequential read of such
an object walks the rest of its extent list for every readahead batch.

On our NFS clients (Ubuntu, v6.8, cache on XFS), a sequential read of a
fully cached 184 GB object with 1,080,732 extents ran at 0.4 MB/s.  In
a 15 s trace of one of the affected readers, each SEEK_HOLE took 64 ms
to 1 s, XFS did 58.5 million extent lookups, and nothing was read from
the server.  After xfs_fsr brought the object down to a few hundred
extents, a traced read of it ran at 369 MB/s from the cache.  On
another machine, v6.14 does the same walk at about 220 ns per extent,
against 520 ns on v6.8.

It's the same on vfs-7.4.netfs (9f8b64f66).  In QEMU (TCG, 4 vCPUs),
over an NFSv4.2 loopback mount with fsc and the cache on XFS, a 1 GiB
object filled by random 64 KiB reads, while a second file is filled
the same way, ends up with about 16,300 extents.  A sequential read of
it after dropping the page cache makes 4,098 SEEK_HOLE calls that take
176 s in total, and runs at 4.3 MiB/s.

To confirm that the walk is the whole problem, I wrote a naive
workaround with LLM assistance.  I don't know the cachefiles and netfs
internals well, so take it as a probe rather than a proposal:

 - Each cachefiles_object remembers the last region that SEEK_DATA/
   SEEK_HOLE found to be contiguous data.  cachefiles_query_occupancy()
   answers a query that starts inside that region without seeking, and
   overlapping or abutting regions merge.  A sequential read then pays
   for one walk instead of one per request.

 - The region is forgotten after every place where cachefiles removes
   data from a backing file: the punch on low space in
   __cachefiles_prepare_write(), the padding clear and the truncation in
   cachefiles_collect_write(), cachefiles_shorten_object() and
   invalidation.  A sequence number sampled before the seeks stops a
   query that raced with a removal from recording what it saw, and
   cookie->inval_counter ties the region to the backing file.

In the same test, the workaround makes one SEEK_HOLE call taking 61 ms,
and the read runs at 17 MiB/s.  A debug build that checked every
remembered answer against a fresh SEEK_DATA/SEEK_HOLE saw no mismatch in
more than 7,000 checks over NFS and 9p.  It only helps fully or mostly
populated objects read in order; random reads of a partly cached object
still seek.

I expect the right fix is for cachefiles to track what it has written
itself, as CONTENT_ALL now does for contiguous files, rather than
something like the above.  I can send the workaround if it's useful as
a reference, and I'm happy to test whatever you plan for this case on
our workload.

While testing it I hit a data corruption on partly cached objects that
bisects to patch 4/5 of this series and reproduces without the
workaround; I've reported it in a reply to that patch:

  https://lore.kernel.org/r/20261011.cachefiles-partial-zeros.pchmelar@innovatrics.com

The numbers on vfs-7.4.netfs and the debug cross-check were also
produced with LLM assistance.

Thanks,
Petr
