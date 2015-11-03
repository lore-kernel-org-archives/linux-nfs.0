Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41780 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964975AbbKCWGZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2015 17:06:25 -0500
Date: Tue, 3 Nov 2015 17:06:24 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Andrew W Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, jlayton@poochiereds.net
Subject: Re: Update and questions.
Message-ID: <20151103220624.GB1096@fieldses.org>
References: <m21tc8l5as.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m21tc8l5as.fsf@discipline.rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 02, 2015 at 11:44:27AM -0500, Andrew W Elble wrote:
> 
> I've been busy patching in things to observe what's going on with my
> delegation issues.
> 
> I implemented a seq_file interface on the server to walk the
> file_hashtbl, and some interesting things have popped up:

Zowie.

So you're waiting for the problem to reproduce itself, and then dumping
this information?

(And if I remember correctly the problem was that the server was
attempting to recall delegations that the client claimed not to have any
knowledge of?)

> This is a nfs4_file that has two open stateids allocated to the same client:
> 
> file fh: 82369f70 R:2 F:4 FP:ffff881f24286b58 I:ffff881f6f6a91d0 D:ffff881febf08b40 /home/<stuff>
>   Deleg: Linux NFSv4.1 <hosta> : 2292335602000000d89e0700 120317
>   Deleg: Linux NFSv4.1 <hostb> : 2292335607000000437f0700 148262
>   Stateid: Linux NFSv4.1 <hosta> : 2292335602000000d69e0700/1
>   Stateid: Linux NFSv4.1 <hosta> : 2292335602000000d79e0700/1
> 
> This one has four:
> 
> file fh: 6ecdd5f8 R:4 F:4 FP:ffff88083e2974a0 I:ffff881f6c9349d0 D:ffff883f4ad1e780 /home/<stuff>
>   Stateid: Linux NFSv4.1 <hosta> : 2292335602000000f1620800/1
>   Stateid: Linux NFSv4.1 <hosta> : 2292335602000000f0620800/1
>   Stateid: Linux NFSv4.1 <hosta> : 2292335602000000c64c0800/1
>   Stateid: Linux NFSv4.1 <hosta> : 2292335602000000c74c0800/1

I believe stateid's are per client,openowner,file.  So multiple
stateid's per file should be OK if there are multiple openowners.

> These are nfs4_files that have elevated fi_ref counts but are
> essentially "empty":
> (note: fi_had_conflict is seemingly always nonzero on entries like these)
> 
> file fh: ee23414c F:1 FP:ffff88087fc52318 I:0000000000000000
> file fh: 5a8e8c86 F:2 FP:ffff881f5e872318 I:0000000000000000

So if I understand correctly, there's neither a delegated file nor
anything in the fi_fds[] array?  Hm.

I'll have to stare at the code to figure out what that means.

fi_had_conflict means a delegation was recalled on this file at some
point.

--b.

> 
> ======================
> 
> for clarity:
> 
> +static int nfs4_file_hash_list_show(struct seq_file *seq, void *v)
> +{
> +       char *name = __getname();
> +       char *p;
> +       int i;
> +       struct dentry *dentry;
> +       struct inode *inode = NULL;
> +       struct nfs4_delegation *dp;
> +       struct nfs4_ol_stateid *stp;
> +       if (!name)
> +               goto out;
> +
> +       if (v != SEQ_START_TOKEN) {
> +               struct nfs4_file *fp = (struct nfs4_file *) v;
> +               spin_lock(&fp->fi_lock);
> +               seq_printf(seq, "file fh: %08x",nfsd_fhandle_hash(&fp->fi_fhandle));
> +               for (i = 0; i < 3; i++) {
> +                       if (fp->fi_fds[i]) {
> +                               if (!inode)
> +                                       inode = (fp->fi_fds[i])->f_inode;
> +                               dentry = (fp->fi_fds[i])->f_path.dentry;
> +                               if (dentry)
> +                                       break;
> +                       }
> +               }
> +               if (atomic_read(&fp->fi_access[O_RDONLY]) > 0)
> +                       seq_printf(seq, " R:%d",
> +                               atomic_read(&fp->fi_access[O_RDONLY]));
> +               if (atomic_read(&fp->fi_access[O_WRONLY]) > 0)
> +                       seq_printf(seq, " W:%d",
> +                               atomic_read(&fp->fi_access[O_WRONLY]));
> +               seq_printf(seq, " F:%d",
> +                       atomic_read(&fp->fi_ref));
> +               seq_printf(seq, " FP:%pK", fp);
> +               if ((!dentry) && fp->fi_deleg_file)
> +                       dentry = fp->fi_deleg_file->f_path.dentry;
> +               if ((!inode) && fp->fi_deleg_file)
> +                       inode = (fp->fi_deleg_file)->f_inode;
> +               seq_printf(seq, " I:%pK", inode);
> +               if (dentry) {
> +                       p = dentry_path_raw(dentry, name, PATH_MAX);
> +                       seq_printf(seq, " D:%pK %s\n", dentry, p);
> +               } else {
> +                       seq_printf(seq, "\n");
> +               }
> +               list_for_each_entry(dp, &fp->fi_delegations, dl_perfile) {
> +                       seq_printf(seq, "  Deleg: %.*s : %*phN %lu\n",
> +                               (int)dp->dl_recall.cb_clp->cl_name.len,
> +                               dp->dl_recall.cb_clp->cl_name.data,
> +                               12,
> +                               &dp->dl_stid.sc_stateid.si_opaque,
> +                               get_seconds() - dp->dl_alloctime);
> +               }
> +               list_for_each_entry(stp, &fp->fi_stateids, st_perfile) {
> +                       seq_printf(seq, "  Stateid: %.*s : %*phN/%x\n",
> +                               (int)stp->st_stid.sc_client->cl_name.len,
> +                               stp->st_stid.sc_client->cl_name.data,
> +                               12,
> +                               &stp->st_stid.sc_stateid.si_opaque,
> +                               stp->st_stid.sc_stateid.si_generation);
> +               }
> +               spin_unlock(&fp->fi_lock);
> +       }
> +       __putname(name);
> +out:
> +       return 0;
> +}
> 
> Thanks,
> 
> Andy
> 
> -- 
> Andrew W. Elble
> aweits@discipline.rit.edu
> Infrastructure Engineer, Communications Technical Lead
> Rochester Institute of Technology
> PGP: BFAD 8461 4CCF DC95 DA2C B0EB 965B 082E 863E C912
