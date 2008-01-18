From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: RE: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching negative dentries
Date: Fri, 18 Jan 2008 12:00:38 -0800
Message-ID: <01AE8AF878612047A442668306EAEB0501817BA4@SACEXMV01.hq.netapp.com>
References: <20080115163013.GC18911@newbie.thebellsplace.net> <1200415972.7702.7.camel@heimdal.trondhjem.org> <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com> <20080116012209.GB26010@newbie.thebellsplace.net> <1200451350.28088.43.camel@heimdal.trondhjem.org> <478DFD5A.1040501@RedHat.com> <01AE8AF878612047A442668306EAEB05018178E7@SACEXMV01.hq.netapp.com> <1200516219.6932.22.camel@heimdal.trondhjem.org> <C8097339-F9C5-4350-823E-A99945F4600E@oracle.com> <20080118152902.GF7128@newbie.thebellsplace.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Steve Dickson" <SteveD@redhat.com>,
	"NFS list" <linux-nfs@vger.kernel.org>
To: "Bob Bell" <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>,
	"Chuck Lever" <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22598 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764843AbYARUBR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2008 15:01:17 -0500
In-reply-to: <20080118152902.GF7128-y89O8yXFYpDSsb2jM9SCN5/hYUUxywnI@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

How about "all" instead of "full" ("all" being the opposite of "none")?
A cache being "full", although not making sense in this context, does
have another meaning. 

-----Original Message-----
From: Bob Bell [mailto:b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org] 
Sent: Friday, January 18, 2008 7:29 AM
To: Chuck Lever
Cc: Trond Myklebust; Muntz, Daniel; Steve Dickson; NFS list
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid
caching negative dentries

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
