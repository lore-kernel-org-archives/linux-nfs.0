From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] re-exporting NFS-mounted dir over NFS
Date: Thu, 5 Jun 2008 14:30:08 -0400
Message-ID: <20080605183008.GA4969@fieldses.org>
References: <4846A272.8040206@infineon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Martin Schuster (IFKL IT OS DSM CD)" <Martin.Schuster1-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45210 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751995AbYFESaJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Jun 2008 14:30:09 -0400
In-Reply-To: <4846A272.8040206-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 04, 2008 at 04:10:58PM +0200, Martin Schuster (IFKL IT OS DSM CD) wrote:
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

It's certainly not trivial to implement re-export.  It's probably also
possible, at least in theory, but would be difficult (and probably
wouldn't work terribly well).  So, like Peter Staubach says, I'd try to
talk the server administrator into turning on krb5 on the filer.

--b.

> Or am I just stupid/blind? (wouldn't be the first time :)
> 
> Thanks in advance,
> -- 
> Infineon Technologies IT-Services GmbH   Martin.Schuster1-d0qZbvYSIPpWk0Htik3J/w@public.gmane.org
> Lakeside B05, 9020 Klagenfurt, Austria   Martin Schuster
>          FB: LG Klagenfurt, FN 246787y   +43 5 1777 3517
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
