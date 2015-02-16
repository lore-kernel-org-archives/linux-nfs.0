Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f177.google.com ([209.85.220.177]:51103 "EHLO
	mail-vc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbbBPE2N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Feb 2015 23:28:13 -0500
Received: by mail-vc0-f177.google.com with SMTP id hy10so9806665vcb.8
        for <linux-nfs@vger.kernel.org>; Sun, 15 Feb 2015 20:28:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150216134628.773e3347@notabene.brown>
References: <87iofju9ht.fsf@spindle.srvr.nix>
	<20150203195333.GQ22301@fieldses.org>
	<87egq6lqdj.fsf@spindle.srvr.nix>
	<87r3u58df2.fsf@spindle.srvr.nix>
	<20150205112641.60340f71@notabene.brown>
	<87zj8l7j3z.fsf@spindle.srvr.nix>
	<20150210183200.GB11226@fieldses.org>
	<87vbj4ljjn.fsf@spindle.srvr.nix>
	<20150216134628.773e3347@notabene.brown>
Date: Sun, 15 Feb 2015 23:28:12 -0500
Message-ID: <CAHQdGtRZP2wYeLozY5pzrD-GALKqV8g1tjV2orotZuTcug2v3A@mail.gmail.com>
Subject: Re: what on earth is going on here? paths above mountpoints turn into "(unreachable)"
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: Nix <nix@esperi.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>,
        NFS list <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Feb 15, 2015 at 9:46 PM, NeilBrown <neilb@suse.de> wrote:
> On Sat, 14 Feb 2015 13:17:00 +0000 Nix <nix@esperi.org.uk> wrote:
>
>> On 10 Feb 2015, J. Bruce Fields outgrape:
>>
>> > It might be interesting to see output from
>> >
>> >     rpc.debug -m rpc -s cache
>> >     cat /proc/net/rpc/nfsd.export/content
>> >     cat /proc/net/rpc/nfsd.fh/content
>> >
>> > especially after the problem manifests.
>>
>> So the mount has vanished again. I couldn't make it happen with
>> nordirplus in the mount options, so that might provide you with a clue.
>
> Yup.  It does.
>
> There is definitely something wrong in nfs_prime_dcache.  I cannot quite
> trace through from cause to effect, but maybe I don't need to.
>
> Can you try the following patch and see if that makes the problem disappear?
>
> When you perform a READDIRPLUS request on a directory that contains
> mountpoints, the the Linux NFS server doesn't return a file-handle for
> those names which are mountpoints (because doing so is a bit tricky).
>
> nfs3_decode_dirent notices and decodes as a filehandle with zero length.
>
> The "nfs_same_file()" check in nfs_prime_dcache() determines that isn't
> the same as the filehandle it has, and tries to invalidate it and make a new
> one.
>
> The invalidation should fail (probably does).
> The creating of a new one ... might succeed.  Beyond that, it all gets a bit
> hazy.
>
> Anyway, please try:
>
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 9b0c55cb2a2e..a460669dc395 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -541,7 +541,7 @@ int nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *en
>
>                 count++;
>
> -               if (desc->plus != 0)
> +               if (desc->plus != 0 && entry->fh.size)
>                         nfs_prime_dcache(desc->file->f_path.dentry, entry);
>
>                 status = nfs_readdir_add_to_array(entry, page);
>
>
> which you might have to apply by hand.

Doesn't that check ultimately belong in nfs_fget()? It would seem to
apply to all filehandles, irrespective of provenance.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
