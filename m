Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51938 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752982Ab2H2RLY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Aug 2012 13:11:24 -0400
Date: Wed, 29 Aug 2012 13:11:23 -0400
To: Carlos =?utf-8?Q?Jim=C3=A9nez?= <cjimenez@eneotecnologia.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Stale NFS file handle - persistent error
Message-ID: <20120829171122.GA9983@fieldses.org>
References: <503E131F.2040904@eneotecnologia.com>
 <503E13BF.6010304@eneotecnologia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <503E13BF.6010304@eneotecnologia.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 29, 2012 at 03:06:07PM +0200, Carlos Jiménez wrote:
> I have a computer acting as an NFS Server running a Debian based
> distro

Could you be more specific?  What kernel version exactly, and what
filesystem are you exporting, and what are the export options?

What version of NFS are you using?

> and several hosts running CentOS 6.2 acting as NFS clients
> (for a virtualization environment). Every time more often "Stale NFS
> file handle" errors appear when trying to copy a file from one
> directory to another (both in the nfs shared directory).

I assume you're not doing anything else with either file or directory at
the same time?  (E.g., not deleting or renaming the file while it's
being copied?)

--b.

> In the server side there are no related information in the logs, but
> this is the output of one of the nfs clients:
> 
> Wed Aug 29 11:52:57 2012 [TM][E]: clone: Command "cd
> /var/lib/one/datastores/0/32; cp -r
> ../../1/5c0455eb494fd43b5c7c576e0c642fbe
> /var/lib/one/datastores/0/32/disk.0" failed: cp: reading
> `../../1/5c0455eb494fd43b5c7c576e0c642fbe': Stale NFS file handle
> 
> I've checked that path and filenames are correct. The file itself is
> a 300MG sized and the error appears aprox. 30 minutes after the
> start of the copy, so I guess that it doesn't finish the file copy.
> I usually tried unmounting and remounting the shared directory. In
> fact, initially it was enough and it was possible to fully copy the
> file (after aprox. 30 minutes), moreover because the error took
> place from time to time. But now, the problem persists after doing
> it (even after rebooting the clients).
> Additionally, I've tried doing the same operation (to copy the same
> file from a directory to another) locally in the NFS Server and it
> takes just a minute (aprox.).
> 
> Could you give me advice on troubleshooting it?
> 
> 
> Thanks in advance.
> 
> Carlos.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
