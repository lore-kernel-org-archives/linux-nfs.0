From: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching negative dentries
Date: Fri, 18 Jan 2008 10:29:03 -0500
Message-ID: <20080118152902.GF7128@newbie.thebellsplace.net>
References: <20080115163013.GC18911@newbie.thebellsplace.net> <1200415972.7702.7.camel@heimdal.trondhjem.org> <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com> <20080116012209.GB26010@newbie.thebellsplace.net> <1200451350.28088.43.camel@heimdal.trondhjem.org> <478DFD5A.1040501@RedHat.com> <01AE8AF878612047A442668306EAEB05018178E7@SACEXMV01.hq.netapp.com> <1200516219.6932.22.camel@heimdal.trondhjem.org> <C8097339-F9C5-4350-823E-A99945F4600E@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	"Muntz, Daniel" <Dan.Muntz@netapp.com>,
	Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv03.macroped.com ([74.52.9.226]:53346 "EHLO
	srv03.macroped.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754812AbYARPaP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2008 10:30:15 -0500
In-Reply-To: <C8097339-F9C5-4350-823E-A99945F4600E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 16, 2008 at 03:49:20PM -0500, Chuck Lever wrote:
>On Jan 16, 2008, at 3:43 PM, Trond Myklebust wrote:
>>How about
>>         -odircache=aggr[essive]	/* Full caching */
>>         -odircache=noneg[ative]	/* Positive lookups only */
>>         -odircache=off		/* strict lookup revalidation */
>
>  "-olookupcache=" would be even more specific, if not more verbose.   
>dircache=off implies that not even readdir results are cached.
>
>	-olookupcache=full
>	-olookupcache=pos[itive]
>	-olookupcache=strict

I think that "lookupcache" is a little more accurate, and perhaps worth 
the verbosity.  "dircache" could be misinterpreted to imply that 
directory listings are being cached -- which, incidentally, I'm start to 
receive complaints is a problem for us, too...

Converstation on this seems to have died down, and I'm ready to revisit 
the patch.  I'm inclined to go with:
    -o lookupcache=full
    -o lookupcache=pos[itive]
    -o lookupcache=none

If you have a strong (enough) opinion otherwise, please speak up now and 
save me the trouble of an extra pass at the patch...

-- 
Bob Bell
