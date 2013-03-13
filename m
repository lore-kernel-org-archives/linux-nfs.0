Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ares07.inai.de ([5.9.24.206]:33055 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751901Ab3CMOrF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Mar 2013 10:47:05 -0400
Date: Wed, 13 Mar 2013 15:47:02 +0100 (CET)
From: Jan Engelhardt <jengelh@inai.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
cc: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistent error codes between NFSv4 and v3 on network
 issues
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9286AF064@sacexcmbx05-prd.hq.netapp.com>
Message-ID: <alpine.LNX.2.01.1303131546290.4909@nerf07.vanv.qr>
References: <alpine.LNX.2.01.1303011240350.11154@nerf07.vanv.qr>  <6AADB1AD-6FB9-42AD-8BF2-6B0B706927E5@oracle.com>  <alpine.LNX.2.01.1303041957050.18372@nerf07.vanv.qr>  <4FA345DA4F4AE44899BD2B03EEEC2FA9286ADBED@sacexcmbx05-prd.hq.netapp.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AF064@sacexcmbx05-prd.hq.netapp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Monday 2013-03-04 23:37, Myklebust, Trond wrote:

>On Mon, 2013-03-04 at 20:43 +0000, Myklebust, Trond wrote:
>> On Mon, 2013-03-04 at 20:10 +0100, Jan Engelhardt wrote:
>> > Just nuke your default route, and it should be easily reproducible.
>> > 
>> 
>> The problem is that call_connect_status() is converting that ENETUNREACH
>> into a EIO. We shouldn't be doing that, but should leave it up to the
>> caller (i.e. the NFS layer) to perform that kind of mapping.
>
>Could you please check if the attached patch helps.

With the patch, I still get EIO from the mount syscall.
