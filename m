From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Fwd: Re: [pnfs] problem building pnfs-nfs-utils under Fedora
 13
Date: Wed, 21 Jul 2010 09:31:19 -0400
Message-ID: <4C46F6A7.3090800@RedHat.com>
References: <4BFD1595.1070502@panasas.com> <4BFD65CA.7080509@RedHat.com> <F9F38212E2D77948B1CD89D239A7C07B138EFFAC41@ES01SNLNT.srn.sandia.gov> <7A6A58246D5F0B4EA127BEA555B3A9AD06111FB6@RTPMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Chen, Helen Y" <hycsw@sandia.gov>,
	Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: "Sager, Mike" <Mike.Sager@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756970Ab0GUNbY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Jul 2010 09:31:24 -0400
In-Reply-To: <7A6A58246D5F0B4EA127BEA555B3A9AD06111FB6-rtwIt2gI0FxT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 07/20/2010 10:50 PM, Sager, Mike wrote:
> Does the kernel have spnfs configured in (i.e., CONFIG_SPNFS)?  Upon
> start up, spnfsd expects to find certain files under /proc/fs/spnfs.  If
> spnfs isn't configured, those files won't exist.
Yes... I have the following set,
CONFIG_SPNFS=y
CONFIG_SPNFS_LAYOUTSEGMENTS=y
CONFIG_SPNFS_BLOCK=y

steved.
