From: Fred Isaman <iisaman@umich.edu>
Subject: Re: pNFS client structure and function rename suggestions
Date: Wed, 28 Jul 2010 09:48:03 -0400
Message-ID: <AANLkTikf-9UDhi6_Jg0k8=wV64=JPGVm5T=scQk14xM1@mail.gmail.com>
References: <DD09EF29-A704-4F17-B917-C01051355CA3@netapp.com>
	<4C500FFD.4000206@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andy Adamson <andros@netapp.com>, linux-nfs@vger.kernel.org
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57978 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753945Ab0G1NsF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jul 2010 09:48:05 -0400
Received: by bwz1 with SMTP id 1so3958163bwz.19
        for <linux-nfs@vger.kernel.org>; Wed, 28 Jul 2010 06:48:03 -0700 (PDT)
In-Reply-To: <4C500FFD.4000206@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 28, 2010 at 7:09 AM, Boaz Harrosh <bharrosh@panasas.com> wr=
ote:
> On 07/27/2010 06:37 PM, Andy Adamson wrote:
>> *********
>> include/linux/nfs_fs.h
>>
>> struct pnfs_layout_type =3D> pnfs_layout
>
> I must disagree. Sorry.
>
> The layout4 type in the standard is defined as:
> struct layout4 {
> =A0 =A0 =A0 =A0 =A0 offset4 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lo_offset=
;
> =A0 =A0 =A0 =A0 =A0 length4 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lo_length=
;
> =A0 =A0 =A0 =A0 =A0 layoutiomode4 =A0 =A0 =A0 =A0 =A0 lo_iomode;
> =A0 =A0 =A0 =A0 =A0 layout_content4 =A0 =A0 =A0 =A0 lo_content;
> };
>
> Which is what we use as layout_segment. All the "LAYOUT" operations
> operate on an embedded concept of the above layout (seg) and or
> the LAYOUTGET actually returns a layout4.
>
> Calling something else pnfs_layout, will totally confuse. (And it see=
ms
> it has already confused the best of us ;-) )
>
> The above, former struct pnfs_layout_type, is a collection of "layout=
"s
> and governing state, plus general LD based IO management stuff.
>
> For me it is just the "nfs inode extension for pnfs", embedded inside=
 the
> "LD inode extension"
>
> Call it what you like. But the concept of "layout" was invented by th=
e
> rfc5661. Please don't overload it to mean something else.
>
>> fields:
>> =A0 =A0 refcount =3D> lo_refcount
>> =A0 =A0 segs =3D> lo_segs
>> =A0 =A0 roc_iomode =3D> lo_roc_iomode
>> =A0 =A0 seqlock =3D> lo_seqlock
>> =A0 =A0 stateid =3D> lo_stateid
>> =A0 =A0 pnfs_layout_state =3D> lo_state
>> =A0 =A0 pnfs_write_begin_pos =3D> lo_write_begin
>> =A0 =A0 pnfs_write_end_pos =3D> lo_write_end
>>
>
> Maybe just call it:
> struct nfs_inode {
> =A0 =A0 =A0 =A0...
> =A0 =A0 =A0 =A0struct pnfs_info *pnfs;
>
> If the "layout" name is dropped then by naming convention the "lo_" i=
s not
> appropriate as well.
>
>> *********
>> include/linux/pnfs_xdr.h
>>
>> NOTE: consider removing and adding to include/linux/nfs_xdr.h where =
the other
>> nfsv4.1 xdr structs are declared.
>>
>> struct nfs4_pnfs_layout =3D> remove, inline in nfs4_layoutget_args.
>>
>> struct nfs4_pnfs_layout_segment =3D> pnfs_layout_range
>
> Isn't this a struct layout4 above?

No, this is probably the most confusingly named structure of them all,
and one I would strongly urge be changed along the line of Andy's
suggestion.

=46red

> (And what an ugly reorder from the STD's fields, with these double
> miss alignment inside the nfs4_pnfs_layoutget_arg)
>
> I don't see why we have to invent new names (and structures) that tra=
nslate
> to yet other names and concepts in the standard. (And a dictionary th=
at
> translates one to the other). Why can't we just use the STDs names an=
d structures
> directly? Is there not to many already?
>
>>
>> struct nfs4_pnfs_layoutget_arg =3D> nfs4_layoutget_args
>> fields:
>> =A0 =A0 lseg =3D> range
>> =A0 =A0 layout: remove. inline with:
>> =A0 =A0 =A0 add: layout_len
>> =A0 =A0 =A0 =A0 add: layout_buf
>>
>> struct nfs4_pnfs_layoutget_res =3D> nfs4_layoutget_res
>> fields:
>> =A0 =A0 lseg =3D> range
>>
>
> All these lsegs above and below are layouts
>
>> struct nfs4_pnfs_layoutget =3D> nfs4_layoutget
>>
>
> OMG, yes!
>
> Boaz
>
>> struct pnfs_layoutcommit_arg =3D> nfs4_layoutcommit_args
>> fields:
>> =A0 =A0 lseg =3D> range
>>
>> struct pnfs_layoutcommit_res =3D> nfs4_layoutcommit_res
>>
>> struct pnfs_layoutcommit_data =3D> nfs4_layoutcommit_data
>>
>> struct nfs4_pnfs_layoutreturn_arg =3D> nfs4_layoutreturn_args
>> fields:
>> =A0 =A0 lseg =3D> range
>>
>> struct nfs4_pnfs_layoutreturn_res =3D> nfs4_layoutreturn_res
>>
>> struct nfs4_pnfs_layoutreturn =3D> nfs4_layoutreturn
>>
>> struct nfs4_pnfs_getdeviceinfo_arg =3D> nfs4_getdeviceinfo_args
>>
>> struct nfs4_pnfs_getdeviceinfo_res =3D> nfs4_getdeviceinfo_res
>>
>> *********
>> include/linux/nfs4.h
>>
>> NFSPROC4_CLNT_PNFS_LAYOUTGET =3D> NFSPROC4_CLNT_LAYOUTGET
>> NFSPROC4_CLNT_PNFS_LAYOUTCOMMIT =3D> NFSPROC4_CLNT_LAYOUTCOMMIT
>> NFSPROC4_CLNT_PNFS_LAYOUTRETURN =3D> NFSPROC4_CLNT_LAYOUTRETURN
>> NFSPROC4_CLNT_PNFS_GETDEVICEINFO =3D> NFSPROC4_CLNT_GETDEVICEINFO
>>
>> *********
>>
>> fs/nfs/nfs4proc.c
>>
>> nfs4_pnfs_layoutget_prepare =3D> nfs4_layoutget_prepare
>> nfs4_pnfs_layoutget_done =3D> nfs4_layoutget_done
>> nfs4_pnfs_layoutget_release =3D> nfs4_layoutget_release
>>
>> _pnfs4_proc_layoutget =3D> _nfs4_proc_layoutget
>> pnfs4_proc_layoutget =3D> nfs4_proc_layoutget
>>
>>
>> pnfs_layoutcommit_prepare =3D> nfs4_layoutcommit_prepare
>> pnfs_layoutcommit_done =3D> nfs4_layoutcommit_done
>> pnfs_layoutcommit_release =3D> nfs4_layoutcommit_release
>>
>> _pnfs4_proc_layoutcommit =3D> _nfs4_proc_layoutcommit
>> pnfs4_proc_layoutcommit =3D> nfs4_proc_layoutcommit
>>
>> nfs4_pnfs_layoutreturn_prepare =3D> nfs4_layoutreturn_prepare
>> nfs4_pnfs_layoutreturn_done =3D> nfs4_layoutreturn_done
>> nfs4_pnfs_layoutreturn_release =3D> nfs4_layoutreturn_release
>>
>> _pnfs4_proc_layoutreturn =3D> _nfs4_proc_layoutreturn
>> pnfs4_proc_layoutreturn =3D> nfs4_proc_layoutreturn
>>
>> nfs4_pnfs_getdeviceinfo =3D> nfs4_proc_getdeviceinfo
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
