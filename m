Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59949 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752818AbbG0Uk0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Jul 2015 16:40:26 -0400
Date: Mon, 27 Jul 2015 16:40:26 -0400
To: Andrew W Elble <aweits@rit.edu>
Cc: linux-nfs@vger.kernel.org, Anna Schumaker <schumakeranna@gmail.com>
Subject: Re: list_del corruption / unhash_ol_stateid()
Message-ID: <20150727204026.GB20951@fieldses.org>
References: <m23809zl8z.fsf@discipline.rit.edu>
 <m2zj2hwk4e.fsf@discipline.rit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <m2zj2hwk4e.fsf@discipline.rit.edu>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This looks a lot like the same thing Anna's been hitting, which I
haven't been able to reliably reproduce yet.  How are you hitting this?

--b.

On Mon, Jul 27, 2015 at 02:06:25PM -0400, Andrew W Elble wrote:
> 
> > [12492.273425] WARNING: CPU: 0 PID: 32238 at fs/nfsd/nfs4state.c:3937
> > nfsd4_process_open2+0x120d/0x1230 [nfsd]()
> 
> 3931          fl = nfs4_alloc_init_lease(fp, NFS4_OPEN_DELEGATE_READ);
> 3932          if (!fl)
> 3933                  return -ENOMEM;
> 3934          filp = find_readable_file(fp);
> 3935          if (!filp) {
> 3936                  /* We should always have a readable file here */
> 3937                  WARN_ON_ONCE(1);
> 3938                  return -EBADF;
> 3939          }
>           
> We're at least leaking fl on return @3938 here? Can't yet speak to the
> trigger from find_readable_file().
> 
> 1007  static void unhash_ol_stateid(struct nfs4_ol_stateid *stp)
> 1008  {
> 1009          struct nfs4_file *fp = stp->st_stid.sc_file;
> 1010
> 1011          lockdep_assert_held(&stp->st_stateowner->so_client->cl_lock);
> 1012
> 1013          spin_lock(&fp->fi_lock);
> 1014          list_del(&stp->st_perfile);
> 1015          spin_unlock(&fp->fi_lock);
> 1016          list_del(&stp->st_perstateowner);
> 1017  }
> 
> The list_del corruption warning is triggered from here:
> 
> 1014          list_del(&stp->st_perfile);
> 
> Actual crash looks like so:
> 
> PID: 32237  TASK: ffff881f391cdef0  CPU: 22  COMMAND: "nfsd"
>  #0 [ffff881f48ed36f0] machine_kexec at ffffffff8105bf3b
>  #1 [ffff881f48ed3760] crash_kexec at ffffffff81109b52
>  #2 [ffff881f48ed3830] oops_end at ffffffff81019768
>  #3 [ffff881f48ed3860] no_context at ffffffff8167e502
>  #4 [ffff881f48ed38c0] __bad_area_nosemaphore at ffffffff8167e5ed
>  #5 [ffff881f48ed3910] bad_area_nosemaphore at ffffffff8167e759
>  #6 [ffff881f48ed3920] __do_page_fault at ffffffff810687e6
>  #7 [ffff881f48ed3990] do_page_fault at ffffffff81068bb0
>  #8 [ffff881f48ed39d0] page_fault at ffffffff8168d398
>     [exception RIP: __kmalloc+150]
>     RIP: ffffffff811dab66  RSP: ffff881f48ed3a88  RFLAGS: 00010286
>     RAX: 0000000000000000  RBX: 000000000000000a  RCX: 00000000009f26fa
>     RDX: 00000000009f26f9  RSI: 0000000000000000  RDI: ffffffff8124cfc0
>     RBP: ffff881f48ed3ac8   R8: 000000000001ab00   R9: 0000000000000000
>     R10: ffff881f48ed3918  R11: ffffffffa0852070  R12: 0000000000000050
>     R13: 0000000000000068  R14: ffff881fff403900  R15: 00000000ffffffff
>     ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
>  #9 [ffff881f48ed3ad0] posix_acl_alloc at ffffffff8124cfc0
> #10 [ffff881f48ed3af0] posix_acl_from_xattr at ffffffff8124da44
> #11 [ffff881f48ed3b40] gfs2_get_acl at ffffffffa0852064 [gfs2]
> #12 [ffff881f48ed3b70] get_acl at ffffffff8124d557
> #13 [ffff881f48ed3b90] generic_permission at ffffffff811fb4a2
> #14 [ffff881f48ed3bd0] gfs2_permission at ffffffffa086d98d [gfs2]
> #15 [ffff881f48ed3c70] __inode_permission at ffffffff811fb572
> #16 [ffff881f48ed3ca0] inode_permission at ffffffff811fb5e8
> #17 [ffff881f48ed3cb0] nfsd_permission at ffffffffa05f6552 [nfsd]
> #18 [ffff881f48ed3ce0] nfsd_access at ffffffffa05f77a8 [nfsd]
> #19 [ffff881f48ed3d40] nfsd4_access at ffffffffa06022ec [nfsd]
> #20 [ffff881f48ed3d50] nfsd4_proc_compound at ffffffffa0604147 [nfsd]
> #21 [ffff881f48ed3db0] nfsd_dispatch at ffffffffa05efff3 [nfsd]
> #22 [ffff881f48ed3df0] svc_process_common at ffffffffa019d483 [sunrpc]
> #23 [ffff881f48ed3e60] svc_process at ffffffffa019d833 [sunrpc]
> #24 [ffff881f48ed3e90] nfsd at ffffffffa05ef9ff [nfsd]
> #25 [ffff881f48ed3ec0] kthread at ffffffff8109c8d8
> #26 [ffff881f48ed3f50] ret_from_fork at ffffffff8168b7a2
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
