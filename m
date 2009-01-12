From: Harry P <reader-kFrNdAxtuftBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [basic] nfsd failing to start
Date: Mon, 12 Jan 2009 15:09:19 -0600
Message-ID: <87vdskxmdc.fsf@newsguy.com>
References: <87zlhxy102.fsf@newsguy.com> <20090112172418.GC24322@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:52761 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658AbZALVJb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2009 16:09:31 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1LMU2L-00023x-Ik
	for linux-nfs@vger.kernel.org; Mon, 12 Jan 2009 21:09:30 +0000
Received: from c-98-215-178-6.hsd1.in.comcast.net ([98.215.178.6])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jan 2009 21:09:29 +0000
Received: from reader by c-98-215-178-6.hsd1.in.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jan 2009 21:09:29 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org>
writes:

>>   CONFIG_NFS_FS=m
>>   CONFIG_NFS_V3=y
>>   CONFIG_NFS_V3_ACL=y
>>   CONFIG_NFS_V4=y
>>   CONFIG_NFSD=m
>>   CONFIG_NFSD_V2_ACL=y
>>   CONFIG_NFSD_V3=y
>>   CONFIG_NFSD_V3_ACL=y
>>   CONFIG_NFSD_V4=y
>>   CONFIG_NFS_ACL_SUPPORT=m
>>   CONFIG_NFS_COMMON=y
>>   CONFIG_SUNRPC=m
>>   CONFIG_SUNRPC_GSS=m
>>   CONFIG_SUNRPC_REGISTER_V4=y
>
> From the config help test: "If you enable this option, you must run a
> portmapper daemon that supports rpcbind protocol version 4."

Thanks, with your clue I commented all nfs and SunRPC 4 related lines
recompiled and rebooted... started up with no problems.

