Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755581Ab2B2UnE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Feb 2012 15:43:04 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q1TKh3v9004259
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 29 Feb 2012 15:43:03 -0500
Message-ID: <4F4E8DD8.8050709@RedHat.com>
Date: Wed, 29 Feb 2012 15:43:04 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Harshula Jayasuriya <harshula@redhat.com>
CC: Bruce Fields <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs-utils: exports man page: no_acl is not supported
References: <1329490378.3976.31.camel@serendib>
In-Reply-To: <1329490378.3976.31.camel@serendib>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/17/2012 09:52 AM, Harshula Jayasuriya wrote:
> The inclusion of no_acl in the exports man page is confusing since it is
> not actually supported (v3.3-rc3):
> 
> 1090 static struct flags {
> 1091         int flag;
> 1092         char *name[2];
> 1093 } expflags[] = {
> 1094         { NFSEXP_READONLY, {"ro", "rw"}},
> 1095         { NFSEXP_INSECURE_PORT, {"insecure", ""}},
> 1096         { NFSEXP_ROOTSQUASH, {"root_squash", "no_root_squash"}},
> 1097         { NFSEXP_ALLSQUASH, {"all_squash", ""}},
> 1098         { NFSEXP_ASYNC, {"async", "sync"}},
> 1099         { NFSEXP_GATHERED_WRITES, {"wdelay", "no_wdelay"}},
> 1100         { NFSEXP_NOHIDE, {"nohide", ""}},
> 1101         { NFSEXP_CROSSMOUNT, {"crossmnt", ""}},
> 1102         { NFSEXP_NOSUBTREECHECK, {"no_subtree_check", ""}},
> 1103         { NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
> 1104         { NFSEXP_V4ROOT, {"v4root", ""}},
> 1105         { 0, {"", ""}}
> 1106 };
> 
> Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
> Acked-by: J. Bruce Fields <bfields@redhat.com>
Committed... sorry it too so long...

steved.

> ---
>  utils/exportfs/exports.man |   18 ------------------
>  1 files changed, 0 insertions(+), 18 deletions(-)
> 
> diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
> index 54adfeb..bc1de73 100644
> --- a/utils/exportfs/exports.man
> +++ b/utils/exportfs/exports.man
> @@ -293,24 +293,6 @@ be explicitly requested with either of the synonymous
>  .IR auth_nlm ,
>  or
>  .IR secure_locks .
> -.TP
> -.IR no_acl
> -On some specially patched kernels, and when exporting filesystems that
> -support ACLs, this option tells
> -.B nfsd
> -not to reveal ACLs to clients, so
> -they will see only a subset of actual permissions on the given file
> -system.  This option is safe for filesystems used by NFSv2 clients and
> -old NFSv3 clients that perform access decisions locally.  Current
> -NFSv3 clients use the ACCESS RPC to perform all access decisions on
> -the server.  Note that the
> -.I no_acl
> -option only has effect on kernels specially patched to support it, and
> -when exporting filesystems with ACL support.  The default is to export
> -with ACL support (i.e. by default,
> -.I no_acl
> -is off).
> -
>  .\".TP
>  .\".I noaccess
>  .\"This makes everything below the directory inaccessible for the named
> -- 1.7.7.6
> 
