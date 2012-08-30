Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34618 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071Ab2H3S7k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Aug 2012 14:59:40 -0400
Date: Thu, 30 Aug 2012 14:59:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Cc: Carlos =?utf-8?Q?Jim=C3=A9nez?= <cjimenez@eneotecnologia.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Stale NFS file handle - persistent error
Message-ID: <20120830185937.GA23140@fieldses.org>
References: <503E131F.2040904@eneotecnologia.com>
 <503E13BF.6010304@eneotecnologia.com>
 <20120829171122.GA9983@fieldses.org>
 <503F0BEF.4020104@eneotecnologia.com>
 <503F8E7C.1030102@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <503F8E7C.1030102@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 30, 2012 at 12:02:04PM -0400, Bryan Schumaker wrote:
> On 08/30/2012 02:45 AM, Carlos Jiménez wrote:
> > Hi,
> > 
> > Thank you for your reply.
> >> Could you be more specific?  What kernel version exactly, and what
> >> filesystem are you exporting, and what are the export options?
> > Kernel version: 2.4.27-3-386
> 
> 2.4.27 is incredibly old, do you have access to the server and can you try a more recent kernel?

Yes, we can't make much use of 2.4 bug reports at this point; you should
probably report this to your distro, or try a more recent kernel.

--b.

> 
> - Bryan
> 
> > Filesystem exported: ext3
> > Export options: rw,no_root_squash,sync
> > 
> > I've shared/exported to the full network 192.168.180.0/24.
> > The exported directory is /opt/virtual/one and in /opt/virtual it is mounted /dev/cciss/c0d0p4 (with default options), which is a 256GB (8GB used) partition over a 3 disks RAID5.
> > 
> >>
> >> What version of NFS are you using?
> >>
> > Vers 3
> > 
> >> I assume you're not doing anything else with either file or directory at
> >> the same time?  (E.g., not deleting or renaming the file while it's
> >> being copied?)
> >>
> >>
> > I'm not doing anything else with either file or directory at the same time.
> > 
> > -- 
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
