Return-Path: linux-nfs-owner@vger.kernel.org
Received: from elasmtp-junco.atl.sa.earthlink.net ([209.86.89.63]:44928 "EHLO
	elasmtp-junco.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754188AbaIZQ1z convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2014 12:27:55 -0400
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Stefan Bauer'" <sb@plzk.de>, <linux-nfs@vger.kernel.org>
References: <zarafa.5425815f.6e31.1b72722237f64a60@srv1.localhost>
In-Reply-To: <zarafa.5425815f.6e31.1b72722237f64a60@srv1.localhost>
Subject: RE: posix acl to nfs4 acl mapping - status?
Date: Fri, 26 Sep 2014 09:11:39 -0700
Message-ID: <01cb01cfd9a4$8e802360$ab806a20$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I'm just a regular sysadmin and want to use NFS4 shares for backup purpose
> and keep existing posix acls from local filesystems during transfer.
> 
> It seems to not be supported:
> 
> root@s1:/# mount.nfs4 -o acl 192.168.0.254:/ /bla root@s1:/# cp -Rvp omg
> /bla/ ‘omg’ -> ‘/bla/omg’
> cp: preserving permissions for ‘/bla/omg’: Operation not supported

cp will not attempt to copy the NFS v4 ACL.

> What is the status on that? I'm aware of nfs4_getfacl but dont want to adjust
> permissions manually.
> 
> I also found https://tools.ietf.org/html/draft-ietf-nfsv4-acl-mapping-05
> which describes a working algorithm for posix->nfs4 mapping but no
> evidence whether this is implemented and if so - how.

I believe the implementation follows this document. I do know that several years ago, we had some significant ACL testing using AIX clients that exposed many issues in the translation.

Unfortunately, the translation is always doomed to be imperfect, and is probably not suitable for backup-purposes. Any POSIX ACL that includes a mask will certainly be changed to lose that mask (with the CURRENT effect of the mask being applied permanently).

> I'm using Debian testing with kernel 3.14.3.4 #5 SMP Thu May 8 16:31:22 CEST
> 2014 x86_64 GNU/Linux.
> mount.nfs4: (linux nfs-utils 1.2.8)

Frank


