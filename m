Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47561 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750795Ab0G1LJw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jul 2010 07:09:52 -0400
Message-ID: <4C500FFD.4000206@panasas.com>
Date: Wed, 28 Jul 2010 14:09:49 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Andy Adamson <andros@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: pNFS client structure and function rename suggestions
References: <DD09EF29-A704-4F17-B917-C01051355CA3@netapp.com>
In-Reply-To: <DD09EF29-A704-4F17-B917-C01051355CA3@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/27/2010 06:37 PM, Andy Adamson wrote:
> *********
> include/linux/nfs_fs.h
> 
> struct pnfs_layout_type => pnfs_layout

I must disagree. Sorry.

The layout4 type in the standard is defined as:
struct layout4 {
           offset4                 lo_offset;
           length4                 lo_length;
           layoutiomode4           lo_iomode;
           layout_content4         lo_content;
};

Which is what we use as layout_segment. All the "LAYOUT" operations
operate on an embedded concept of the above layout (seg) and or
the LAYOUTGET actually returns a layout4.

Calling something else pnfs_layout, will totally confuse. (And it seems
it has already confused the best of us ;-) )

The above, former struct pnfs_layout_type, is a collection of "layout"s
and governing state, plus general LD based IO management stuff.

For me it is just the "nfs inode extension for pnfs", embedded inside the
"LD inode extension"

Call it what you like. But the concept of "layout" was invented by the
rfc5661. Please don't overload it to mean something else.

> fields:
>     refcount => lo_refcount
>     segs => lo_segs
>     roc_iomode => lo_roc_iomode
>     seqlock => lo_seqlock
>     stateid => lo_stateid
>     pnfs_layout_state => lo_state
>     pnfs_write_begin_pos => lo_write_begin
>     pnfs_write_end_pos => lo_write_end
> 

Maybe just call it:
struct nfs_inode {
	...
	struct pnfs_info *pnfs;

If the "layout" name is dropped then by naming convention the "lo_" is not
appropriate as well.

> *********
> include/linux/pnfs_xdr.h
> 
> NOTE: consider removing and adding to include/linux/nfs_xdr.h where the other
> nfsv4.1 xdr structs are declared.
> 
> struct nfs4_pnfs_layout => remove, inline in nfs4_layoutget_args.
> 
> struct nfs4_pnfs_layout_segment => pnfs_layout_range

Isn't this a struct layout4 above?
(And what an ugly reorder from the STD's fields, with these double
miss alignment inside the nfs4_pnfs_layoutget_arg)

I don't see why we have to invent new names (and structures) that translate
to yet other names and concepts in the standard. (And a dictionary that
translates one to the other). Why can't we just use the STDs names and structures
directly? Is there not to many already?

> 
> struct nfs4_pnfs_layoutget_arg => nfs4_layoutget_args
> fields:
>     lseg => range
>     layout: remove. inline with:
> 	add: layout_len
>         add: layout_buf
> 
> struct nfs4_pnfs_layoutget_res => nfs4_layoutget_res
> fields:
>     lseg => range
> 

All these lsegs above and below are layouts

> struct nfs4_pnfs_layoutget => nfs4_layoutget
> 

OMG, yes!

Boaz

> struct pnfs_layoutcommit_arg => nfs4_layoutcommit_args
> fields:
>     lseg => range
> 
> struct pnfs_layoutcommit_res => nfs4_layoutcommit_res
> 
> struct pnfs_layoutcommit_data => nfs4_layoutcommit_data
> 
> struct nfs4_pnfs_layoutreturn_arg => nfs4_layoutreturn_args
> fields:
>     lseg => range
> 
> struct nfs4_pnfs_layoutreturn_res => nfs4_layoutreturn_res
> 
> struct nfs4_pnfs_layoutreturn => nfs4_layoutreturn
> 
> struct nfs4_pnfs_getdeviceinfo_arg => nfs4_getdeviceinfo_args
> 
> struct nfs4_pnfs_getdeviceinfo_res => nfs4_getdeviceinfo_res
> 
> *********
> include/linux/nfs4.h
> 
> NFSPROC4_CLNT_PNFS_LAYOUTGET => NFSPROC4_CLNT_LAYOUTGET
> NFSPROC4_CLNT_PNFS_LAYOUTCOMMIT => NFSPROC4_CLNT_LAYOUTCOMMIT
> NFSPROC4_CLNT_PNFS_LAYOUTRETURN => NFSPROC4_CLNT_LAYOUTRETURN
> NFSPROC4_CLNT_PNFS_GETDEVICEINFO => NFSPROC4_CLNT_GETDEVICEINFO
> 
> *********
> 
> fs/nfs/nfs4proc.c
> 
> nfs4_pnfs_layoutget_prepare => nfs4_layoutget_prepare
> nfs4_pnfs_layoutget_done => nfs4_layoutget_done
> nfs4_pnfs_layoutget_release => nfs4_layoutget_release
> 
> _pnfs4_proc_layoutget => _nfs4_proc_layoutget
> pnfs4_proc_layoutget => nfs4_proc_layoutget
> 
> 
> pnfs_layoutcommit_prepare => nfs4_layoutcommit_prepare
> pnfs_layoutcommit_done => nfs4_layoutcommit_done
> pnfs_layoutcommit_release => nfs4_layoutcommit_release
> 
> _pnfs4_proc_layoutcommit => _nfs4_proc_layoutcommit
> pnfs4_proc_layoutcommit => nfs4_proc_layoutcommit
> 
> nfs4_pnfs_layoutreturn_prepare => nfs4_layoutreturn_prepare
> nfs4_pnfs_layoutreturn_done => nfs4_layoutreturn_done
> nfs4_pnfs_layoutreturn_release => nfs4_layoutreturn_release
> 
> _pnfs4_proc_layoutreturn => _nfs4_proc_layoutreturn
> pnfs4_proc_layoutreturn => nfs4_proc_layoutreturn
> 
> nfs4_pnfs_getdeviceinfo => nfs4_proc_getdeviceinfo
> 
