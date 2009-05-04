From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Do not display the setting of the "intr" mount option
Date: Mon, 4 May 2009 10:27:46 -0400
Message-ID: <382F5CF6-4D1A-4B1E-8E17-B6426CFC3A03@oracle.com>
References: <20090501163402.25637.67939.stgit@ingres.1015granger.net> <alpine.LFD.2.00.0905021010320.19638@maggie.lkpg.cendio.se>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed	delsp=yes
Cc: linux-nfs@vger.kernel.org
To: =?ISO-8859-1?Q?Peter_=C5strand?= <astrand-+4tYiAq3b6azQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:42687 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754679AbZEDO1w convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2009 10:27:52 -0400
In-Reply-To: <alpine.LFD.2.00.0905021010320.19638-K9BqGu7AvB3wj5YHdwD3Ga2PxDmRETKR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On May 2, 2009, at 4:12 AM, Peter =C5strand wrote:
> On Fri, 1 May 2009, Chuck Lever wrote:
>
>> The "intr" mount option has been deprecated for a while, but
>> /proc/mounts continues to display "nointr" whether "intr" or "nointr=
"
>> has been specified for a mount point.
>>
>> Since these options do not have any effect, simply do not display
>> them.
>
> Does this mean that "intr" is default now? Will the "intr" mount =20
> option
> still be accepted/ignored in the future?

Since 2.6.25, the behavior of the NFS client has been a mix of the =20
two.  I believe the current behavior is that SIGKILL can terminate an =20
NFS operation, but all other signals are deferred until pending NFS =20
operations complete.

The mount command continues to accept both options, but neither have =20
any effect on the client's behavior (both options are no-ops).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com