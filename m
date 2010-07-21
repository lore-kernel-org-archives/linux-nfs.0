From: "Chen, Helen Y" <hycsw@sandia.gov>
Subject: RE: Fwd: Re: [pnfs] typo in the pnfs setup wiki?
Date: Wed, 21 Jul 2010 13:06:57 -0600
Message-ID: <F9F38212E2D77948B1CD89D239A7C07B138EFFAD86@ES01SNLNT.srn.sandia.gov>
References: <4BFD1595.1070502@panasas.com> <4BFD65CA.7080509@RedHat.com>
 <F9F38212E2D77948B1CD89D239A7C07B138EFFAC41@ES01SNLNT.srn.sandia.gov>
 <7A6A58246D5F0B4EA127BEA555B3A9AD06111FB6@RTPMVEXC1-PRD.hq.netapp.com>
 <4C46F6A7.3090800@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Cc: "'Benny Halevy'" <bhalevy@panasas.com>,
	"'NFS list'" <linux-nfs@vger.kernel.org>
To: "'Steve Dickson'" <SteveD@redhat.com>,
	"'Sager, Mike'" <Mike.Sager@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sentry-three.sandia.gov ([132.175.109.17]:59724 "EHLO
	sentry-three.sandia.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932191Ab0GUTHM convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jul 2010 15:07:12 -0400
In-Reply-To: <4C46F6A7.3090800-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Mike,

I got spnfsd to run successfully after I corrected a typo in the DataServers section of my spnfsd.conf.  I didn't step far enough in gdb to realize that I actually had a typo there.  Sorry if I have wasted your time!

I was still struggling with the remote I/O error even after spnfsd had been started successfully.  I had to remove the pnfs option in /etc/exportfs on the DS server to get rid of the remote I/O error.  Is there a mistake in the wiki instruction?

Thank you very much for your help,
Helen


-----Original Message-----
From: Steve Dickson [mailto:SteveD@redhat.com] 
Sent: Wednesday, July 21, 2010 6:31 AM
To: Sager, Mike
Cc: Chen, Helen Y; Benny Halevy; NFS list
Subject: Re: Fwd: Re: [pnfs] problem building pnfs-nfs-utils under Fedora 13



On 07/20/2010 10:50 PM, Sager, Mike wrote:
> Does the kernel have spnfs configured in (i.e., CONFIG_SPNFS)?  Upon
> start up, spnfsd expects to find certain files under /proc/fs/spnfs.  If
> spnfs isn't configured, those files won't exist.
Yes... I have the following set,
CONFIG_SPNFS=y
CONFIG_SPNFS_LAYOUTSEGMENTS=y
CONFIG_SPNFS_BLOCK=y

steved.


