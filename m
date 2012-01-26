Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:54294 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750809Ab2AZFYp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jan 2012 00:24:45 -0500
Received: from sc9-mailhost2.vmware.com (sc9-mailhost2.vmware.com [10.113.161.72])
	by smtp-outbound-2.vmware.com (Postfix) with ESMTP id 657FB2839B
	for <linux-nfs@vger.kernel.org>; Wed, 25 Jan 2012 21:16:48 -0800 (PST)
Received: from zimbra-prod-mta-1.vmware.com (zimbra-prod-mta-1.vmware.com [10.113.160.173])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id 61EC1B0359
	for <linux-nfs@vger.kernel.org>; Wed, 25 Jan 2012 21:16:48 -0800 (PST)
Received: from localhost (localhost.localdomain [127.0.0.1])
	by zimbra-prod-mta-1.vmware.com (Postfix) with ESMTP id 5D6F0A478A
	for <linux-nfs@vger.kernel.org>; Wed, 25 Jan 2012 21:16:48 -0800 (PST)
Received: from zimbra-prod-mta-1.vmware.com ([127.0.0.1])
	by localhost (zimbra-prod-mta-1.vmware.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FMekDjZowuhW for <linux-nfs@vger.kernel.org>;
	Wed, 25 Jan 2012 21:16:48 -0800 (PST)
Received: from zimbra-prod-mbox-2.vmware.com (zimbra-prod-mbox-2.vmware.com [10.113.160.202])
	by zimbra-prod-mta-1.vmware.com (Postfix) with ESMTP id 48BCAA4677
	for <linux-nfs@vger.kernel.org>; Wed, 25 Jan 2012 21:16:48 -0800 (PST)
Date: Wed, 25 Jan 2012 21:16:48 -0800 (PST)
From: Andrei Warkentin <awarkentin@vmware.com>
To: linux-nfs@vger.kernel.org
Message-ID: <420810398.113477.1327555008193.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
In-Reply-To: <946833378.113316.1327554221600.JavaMail.root@zimbra-prod-mbox-2.vmware.com>
Subject: NFSv3 mounts issue (get stale errors).
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I genuinly tried to look for anything on this issue, so I apologize in advance if it was covered before.
Anyway, I've seen something like this while trying to mount a share (which is authorized to a set of specific IP):
1) One mount from one host succeeds.
2) Other mounts fail with stale fh error.

Kernel is 3.2.

Log contains something like:
Jan 25 18:03:44 localhost rpc.mountd[6844]: nfsd_fh: inbuf '10.150.27.241 6 \x150ad1f8b9824ea5a1bfafa56e92fa0b'
Jan 25 18:03:44 localhost rpc.mountd[6844]: /exports and /exports/abracadabra have same filehandle for 10.150.27.241, using first
Jan 25 18:03:44 localhost rpc.mountd[6844]: qword_eol: fflush failed: errno 22 (Invalid argument)
Jan 25 18:03:44 localhost rpc.mountd[6844]: Cannot export /exports, possibly unsupported filesystem or fsid= required

...where /exports/abracadabra is the actual export, and /exports is this pseudoexport for NFSv4.

Granted, my nfs-utils is old (1.2.3). I've looked at the latest tarball, 1.2.5, yet I don't think
this would still help me out very much, as subexport checks for NFSEXP_CROSSMOUNT, which is not set.
(/exports/abracadabra   10.150.27.220(rw,no_root_squash,sync,no_wdelay,no_subtree_check,uuid=b5ffa269:e068456b:9d95fb6a:f2a8f431)

cache.c: static void nfsd_fh(FILE *f) {
...
                    if (!found || subexport(&exp->m_export, found)) {
                                found = &exp->m_export;
                                free(found_path);
                                found_path = strdup(path);
                                if (found_path == NULL)
                                        goto out;
                        } else if (strcmp(found->e_path, exp->m_export.e_path)
                                   && !subexport(found, &exp->m_export))
                                xlog(L_WARNING, "%s and %s have same filehandle for %s using fi\
rst",
                                     found_path, path, dom);
                        }
...
}

Is my thinking wrong? Wouldn't it still pick up (in error) /exports? Does this mean that mountd needs to know if the nfsd.fh request
was for a NFSv3 or NFSv4 mount?

A
