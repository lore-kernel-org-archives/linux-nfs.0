From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 00/12] pnfs: LAYOUTGET/DEVINFO submission v5
Date: Thu, 21 Oct 2010 17:12:08 -0400
Message-ID: <1287695528.16982.4.camel@heimdal.trondhjem.org>
References: <1287548284-28374-1-git-send-email-iisaman@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Fred Isaman <iisaman@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:32751 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818Ab0JUVMZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Oct 2010 17:12:25 -0400
Received: from sacrsexc2-prd.hq.netapp.com (sacrsexc2-prd.hq.netapp.com [10.99.115.28])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o9LLC9Fl007812
	for <linux-nfs@vger.kernel.org>; Thu, 21 Oct 2010 14:12:10 -0700 (PDT)
In-Reply-To: <1287548284-28374-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-10-20 at 00:17 -0400, Fred Isaman wrote:
> This is try 5 of the first wave of the linux pnfs client submission.
> The only change (besides rebase on top of Trond's most recent
> nfs-for-2.6.37 branch) between this series and the previous is that
> owner/sign-off issues have been addressed, which allows us to
> remove the RFC label of the previous series.
> 
> For those interested, the patches themselves can also be found at
> git://linux-nfs.org/~iisaman/linux-pnfs.git,
> branch devinfo-submit-rc7-trond
> 
> 
> This is the start of code implementing pnfs, based on RFC 5661.  Since
> sending the whole thing at once would be overwhelming, we are trying
> to break it into bite sized waves.  This first wave implements the
> mount/umount infrastructure, as well as sending the LAYOUTGET and
> GETDEVTICEINFO calls on io (but not actually using the information for
> io).  Note that two major simplifications to the protocol will be made 
> throughout the initial submission process:  only the file layout
> driver is considered, and only whole file layouts are requested.
> 
> 
> These patches apply against Trond's nfs-for-2.6.37 branch.
> 
> patches 01-08 implement the mount/umount hooks
> patches 09-12 implement LAYOUTGET and GETDEVICEINFO

OK. I merged these patches for testing in linux-next last night. If all
goes well, I'll send them to Linus in this merge window.

Trond
