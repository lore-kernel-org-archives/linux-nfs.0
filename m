From: Peter Staubach <staubach@redhat.com>
Subject: Re: [NFS] re-exporting NFS-mounted dir over NFS
Date: Wed, 04 Jun 2008 10:46:11 -0400
Message-ID: <4846AAB3.9070005@redhat.com>
References: <4846A272.8040206@infineon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "Martin Schuster (IFKL IT OS DSM CD)" <Martin.Schuster1-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37560 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753435AbYFDOqP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2008 10:46:15 -0400
In-Reply-To: <4846A272.8040206-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Martin Schuster (IFKL IT OS DSM CD) wrote:
> I am in the process of setting up an "NFS-proxy", a machine which
> mounts directories from an NetApp-filer using NFS3, and should re-export
> them using NFS4 (with Kerberos).
>
> But apparently nfsd doesn't support re-exporting NFS-mounted dirs:
> # mount | grep home
> netapp.example.com:/vol/home/schumar on /srv/nfs4/home/schumar type nfs
> # cat /etc/exports
> /srv/nfs4/home/schumar  gss/krb5(rw,sync,fsid=0,secure,no_subtree_check)
> # exportfs -r
> exportfs: Warning: /srv/nfs4/home/schumar does not support NFS export.
>
> I traced this back to linux-2.6.25.1/fs/nfsd/export.c, where it says, starting
> in line 386:
>         if (!inode->i_sb->s_export_op ||
>             !inode->i_sb->s_export_op->fh_to_dentry) {
>                 dprintk("exp_export: export of invalid fs type.\n");
>                 return -EINVAL;
>         }
>
> (and a quick look in fs/nfs/super.c confirmed that the nfs-client never
> sets an export_op)
>
> Is there a technical reason for this (i.e. is it simply theoretically
> impossible to re-export an NFS-mount), or is my use-case so strange that
> nobody has ever needed this until now, and thus it just wasn't coded?
> Or am I just stupid/blind? (wouldn't be the first time :)
>
> Thanks in advance,
>   
Is the real goal to be able to export the files using krb5
authentication or the use of NFSv4?

If the former, then why not just export the files from the
NetApp using Kerberos?

If the latter, then I suspect that it won't provide much, if
any, benefit.  It would still be limited to the NFSv3 semantics
of the file system.

    Thanx...

       ps
