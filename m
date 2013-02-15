Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:40237 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756229Ab3BOQeE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Feb 2013 11:34:04 -0500
Content-Type: text/plain; charset=iso-8859-1
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: Kernels 3.7 and newer break rpc.gssd -n
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <654867786.10283.1360929631448.JavaMail.root@opinsys.fi>
Date: Fri, 15 Feb 2013 11:33:58 -0500
Cc: Veli-Matti Lintu <veli-matti.lintu@opinsys.fi>, linux-nfs@vger.kernel.org
Message-Id: <74874B5C-CDDE-4F77-B69D-FC40FF5DD933@oracle.com>
References: <127351146.98508.1360769367943.JavaMail.root@opinsys.fi> <1117889154.119108.1360851840169.JavaMail.root@opinsys.fi> <CED6E6AF-B551-4099-89CE-861E5F46D31A@oracle.com> <654867786.10283.1360929631448.JavaMail.root@opinsys.fi>
To: =?iso-8859-1?Q?Tuomas_R=E4s=E4nen?= <tuomasjjrasanen@opinsys.fi>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 15, 2013, at 7:00 AM, Tuomas Räsänen <tuomasjjrasanen@opinsys.fi> wrote:

> ----- Original Message -----
>> From: "Chuck Lever" <chuck.lever@oracle.com>
>> 
>> Have you tried a kernel at commit 05f4c350 but with the compilation fix
>> applied, then one with 05f4c350 removed, to confirm that this indeed is the
>> commit that introduces the problem?
> 
> Yes. With commit 05f4c350 + the compilation fix, the problem occurs, but without
> 05f4c350, the parent (6f2ea7f) works as expected, requesting for service <null>.
> 
>> 
>> When the mount operation fails, is it the first time this client attempts to
>> mount a share on server.example.org, or does the client already have mounts
>> of server.example.org, possibly using other security flavors?
> 
> Yes, the problem occurs on the very first mount attempt.

Thanks for confirming.  Did you try updating nfs-utils on your NFS client to 1.2.8-rc1 or later (specifically to replace rpc.gssd)?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




