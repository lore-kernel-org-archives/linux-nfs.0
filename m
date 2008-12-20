From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] nfs-utils: Enabling TCP wrappers
Date: Sat, 20 Dec 2008 07:35:13 -0500
Message-ID: <494CE681.7020001@RedHat.com>
References: <49468BC7.2000907@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33948 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217AbYLTMh0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Dec 2008 07:37:26 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mBKCbPtE002441
	for <linux-nfs@vger.kernel.org>; Sat, 20 Dec 2008 07:37:25 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mBKCbO6l002065
	for <linux-nfs@vger.kernel.org>; Sat, 20 Dec 2008 07:37:25 -0500
Received: from [10.16.10.12] (vpn-10-12.bos.redhat.com [10.16.10.12])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id mBKCbOdK015430
	for <linux-nfs@vger.kernel.org>; Sat, 20 Dec 2008 07:37:24 -0500
In-Reply-To: <49468BC7.2000907-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Steve Dickson wrote:
> Recently I was asked to re-enable the TCP wrapper calls, that check the
> validity of client that communicate with mountd and statd.
> 
> It became very apparent this code had not been used in a while
> and was as a bit broken. So this patch set fixes the logic and 
> tries to make the code scale better. 
> 
> The commit blobs in the set are relative to the 'tcpwrap'
> branch in the git://linux-nfs.org/~steved/nfs-utils-exp.git
> git tree.
> 
The three patches have been tested and committed.

Note, it was decided the IPv6 patch (the 4th patch)
was not needed. 

steved.
 
