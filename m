From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 6/7] nfs41: implement cb_recall_slot
Date: Wed, 20 Jan 2010 16:27:29 -0500
Message-ID: <1264022849.7799.4.camel@localhost>
References: <1264021587-27697-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com, "Sager, Mike" <Mike.Sager@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:20684 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753384Ab0ATV2F convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jan 2010 16:28:05 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0KLRZt1000822
	for <linux-nfs@vger.kernel.org>; Wed, 20 Jan 2010 13:27:50 -0800 (PST)
In-Reply-To: <1264021587-27697-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-01-20 at 16:06 -0500, andros@netapp.com wrote: 
> Resend with fix to compile without CONFIG_NFS_V4_1.
> 
> Sorry 'bout that Trond.
> 
> -->Andy

No problem. However I did hit a conflict between your patchset and one
of Mike's. The conflicting patches were

commit 8f4a598ccfa936dc850323859af8f52bb1ef15c1 nfs41: back channel drc
minimal implementation

and

commit f93f599e8f6f8c26a99beb8324b15bc8c5f3663a nfs41: Process
callback's referring call list


Could you please both check that I fixed it up correctly in the
nfsv41-for-next branch?

Cheers
  Trond
