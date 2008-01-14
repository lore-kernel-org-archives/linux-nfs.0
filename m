From: Benjamin Coddington <Benjamin.Coddington@uvm.edu>
Subject: Re: Strange lockup during unmount in 2.6.22 - maybe	rpciod	deadlock?
Date: Mon, 14 Jan 2008 15:28:55 -0500
Message-ID: <478BC607.8050008@uvm.edu>
References: <18310.37731.29874.582772@notabene.brown>	 <1200004896.13775.27.camel@heimdal.trondhjem.org>	 <478BB194.3090103@uvm.edu> <1200339108.7470.45.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pony.uvm.edu ([132.198.101.202]:36663 "EHLO pony.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750932AbYANU3D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 15:29:03 -0500
Received: from [132.198.107.214] ([132.198.107.214])
	(authenticated bits=0)
	by pony.uvm.edu (8.13.7/8.13.5) with ESMTP id m0EKSuRD020199
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 14 Jan 2008 15:28:57 -0500
In-Reply-To: <1200339108.7470.45.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> That shouldn't be the case in standard 2.6.22 unless you've also applied
> the NFS_ALL patches. In that case, there is a fix (which has also been
> applied to mainline) in
> 
>  http://client.linux-nfs.org/Linux-2.6.x/2.6.23-rc1/linux-2.6.23-001-fix_rpciod_down_race.dif

That fixed the problem -- still, do we care if we call async in 
gss_destroying_context?  On umount the server drops out from under the 
tasks..

Ben
