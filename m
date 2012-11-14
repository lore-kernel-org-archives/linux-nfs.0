Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:24863 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216Ab2KNXDp convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Nov 2012 18:03:45 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] nfs(5): Document the minorversion= mount option
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092E0DB4@SACEXCMBX04-PRD.hq.netapp.com>
Date: Wed, 14 Nov 2012 18:03:40 -0500
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <A7E004BD-A5DA-4258-978A-80E46DBE3D32@oracle.com>
References: <20121114223600.48062.5680.stgit@seurat.1015granger.net> <4FA345DA4F4AE44899BD2B03EEEC2FA9092E0DB4@SACEXCMBX04-PRD.hq.netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 14, 2012, at 6:01 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

>> -----Original Message-----
>> From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
>> owner@vger.kernel.org] On Behalf Of Chuck Lever
>> Sent: Wednesday, November 14, 2012 5:39 PM
>> To: linux-nfs@vger.kernel.org
>> Subject: [PATCH] nfs(5): Document the minorversion= mount option
>> 
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> 
>> Our pals on the Solaris team recently noticed that the minorversion= option
>> is not documented in nfs(5).  This is a first take, just to start the conversation.
>> I'm pretty sure I got the kernel version information wrong, for instance.
>> 
>> Any other comments?
> 
> You might want to note that it is deprecated in favour of the "vers=4.1" notation, and for that reason we might want to forgo documenting it altogether.

OK.  minorversion= is the only way to get NFSv4.1 on EL6-based distributions, isn't it?

By "deprecated" do you mean that you intend to remove it?

> 
>> utils/mount/nfs.man |   17 +++++++++++++++++
>> 1 files changed, 17 insertions(+), 0 deletions(-)
>> 
>> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man index
>> c15de98..66198cc 100644
>> --- a/utils/mount/nfs.man
>> +++ b/utils/mount/nfs.man
>> @@ -777,6 +777,23 @@ so if this mount option is not specified, the NFS
>> version 4 client  uses the TCP protocol.
>> Refer to the TRANSPORT METHODS section for more details.
>> .TP 1.5i
>> +.BI minorversion= n
>> +Specifies the protocol minor version number.
>> +NFSv4 introduces "minor versioning," where NFS protocol enhancements
>> +can be introduced without bumping the NFS protocol version number.
>> +Before kernel 2.6.38, the minor version is always zero, and this option
>> +is not recognized.
>> +After this kernel, specifying "minorversion=1" enables a number of
>> +advanced features, such as NFSv4 sessions.
>> +.IP
>> +Recent kernels allow the minor version to be specified using the .B
>> +vers= option.
>> +For example, specifying
>> +.B vers=4.1
>> +is the same as specifying
>> +.BR vers=4,minorversion=1 .
>> +.TP 1.5i
>> .BI port= n
>> The numeric value of the server's NFS service port.
>> If the server's NFS service is not available on the specified port,
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the
>> body of a message to majordomo@vger.kernel.org More majordomo info at
>> http://vger.kernel.org/majordomo-info.html--
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




