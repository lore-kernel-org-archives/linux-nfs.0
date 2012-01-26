Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33685 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752491Ab2AZUyG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 15:54:06 -0500
Date: Thu, 26 Jan 2012 15:54:05 -0500
To: Andrei Warkentin <awarkentin@vmware.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFSv3 mounts issue (get stale errors).
Message-ID: <20120126205405.GB700@fieldses.org>
References: <946833378.113316.1327554221600.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
 <420810398.113477.1327555008193.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <420810398.113477.1327555008193.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 25, 2012 at 09:16:48PM -0800, Andrei Warkentin wrote:
> Hi,
> 
> I genuinly tried to look for anything on this issue, so I apologize in advance if it was covered before.
> Anyway, I've seen something like this while trying to mount a share (which is authorized to a set of specific IP):
> 1) One mount from one host succeeds.
> 2) Other mounts fail with stale fh error.
> 
> Kernel is 3.2.
> 
> Log contains something like:
> Jan 25 18:03:44 localhost rpc.mountd[6844]: nfsd_fh: inbuf '10.150.27.241 6 \x150ad1f8b9824ea5a1bfafa56e92fa0b'
> Jan 25 18:03:44 localhost rpc.mountd[6844]: /exports and /exports/abracadabra have same filehandle for 10.150.27.241, using first

That sounds like a bug....

> Jan 25 18:03:44 localhost rpc.mountd[6844]: qword_eol: fflush failed: errno 22 (Invalid argument)
> Jan 25 18:03:44 localhost rpc.mountd[6844]: Cannot export /exports, possibly unsupported filesystem or fsid= required
> 
> ...where /exports/abracadabra is the actual export, and /exports is this pseudoexport for NFSv4.

Note we don't recommend that any more if you're using recent enough
kernel and nfs-utils.  If you leave out the fsid=0 export and export
normally, your export will be visible to v4 clients under its real path
(the same path v2/v3 clients would see.)

> Granted, my nfs-utils is old (1.2.3). I've looked at the latest tarball, 1.2.5, yet I don't think

There are a few fixes in that general area since 1.2.3.

--b.

> this would still help me out very much, as subexport checks for NFSEXP_CROSSMOUNT, which is not set.
> (/exports/abracadabra   10.150.27.220(rw,no_root_squash,sync,no_wdelay,no_subtree_check,uuid=b5ffa269:e068456b:9d95fb6a:f2a8f431)
> 
> cache.c: static void nfsd_fh(FILE *f) {
> ...
>                     if (!found || subexport(&exp->m_export, found)) {
>                                 found = &exp->m_export;
>                                 free(found_path);
>                                 found_path = strdup(path);
>                                 if (found_path == NULL)
>                                         goto out;
>                         } else if (strcmp(found->e_path, exp->m_export.e_path)
>                                    && !subexport(found, &exp->m_export))
>                                 xlog(L_WARNING, "%s and %s have same filehandle for %s using fi\
> rst",
>                                      found_path, path, dom);
>                         }
> ...
> }
> 
> Is my thinking wrong? Wouldn't it still pick up (in error) /exports? Does this mean that mountd needs to know if the nfsd.fh request
> was for a NFSv3 or NFSv4 mount?
