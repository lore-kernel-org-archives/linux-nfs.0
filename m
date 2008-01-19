From: Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 2/3] NFS: Add NFS_MOUNT_NONEGDE flag to avoid caching negative dentries
Date: Fri, 18 Jan 2008 20:28:01 -0500
Message-ID: <20080119012758.GA19933@newbie.thebellsplace.net>
References: <1200415972.7702.7.camel@heimdal.trondhjem.org> <CB3B3B75-ECE5-4A46-BEA5-7DEDA8DB7DCA@oracle.com> <20080116012209.GB26010@newbie.thebellsplace.net> <1200451350.28088.43.camel@heimdal.trondhjem.org> <478DFD5A.1040501@RedHat.com> <01AE8AF878612047A442668306EAEB05018178E7@SACEXMV01.hq.netapp.com> <1200516219.6932.22.camel@heimdal.trondhjem.org> <C8097339-F9C5-4350-823E-A99945F4600E@oracle.com> <20080118152902.GF7128@newbie.thebellsplace.net> <01AE8AF878612047A442668306EAEB0501817BA4@SACEXMV01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Steve Dickson <SteveD@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv03.macroped.com ([74.52.9.226]:53628 "EHLO
	srv03.macroped.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756454AbYASB3D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2008 20:29:03 -0500
In-Reply-To: <01AE8AF878612047A442668306EAEB0501817BA4-Ye0EzW0T4yEQ4vjYWPuN5KYtpRd4g51m@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 18, 2008 at 12:00:38PM -0800, Muntz, Daniel wrote:
> How about "all" instead of "full" ("all" being the opposite of "none")?
> A cache being "full", although not making sense in this context, does
> have another meaning. 

That makes sense to me.

-- 
Bob Bell
