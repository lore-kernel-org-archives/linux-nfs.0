Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:58854 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757354Ab1ANQFZ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Jan 2011 11:05:25 -0500
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: mac error
Date: Fri, 14 Jan 2011 10:55:00 -0500
Message-ID: <BF3BB6D12298F54B89C8DCC1E4073D8002CC1D8F@CORPUSMX50A.corp.emc.com>
In-Reply-To: <BB05F812-F3D3-4742-BD54-794FD4BCC0C0@oracle.com>
References: <AANLkTin04TeswNAM89ij84YzfeTAR7rsppGyZFfq01qM@mail.gmail.com> <4D2FB6F4.6070304@cn.fujitsu.com> <AANLkTin8PEyLqpdaTorSrS3Zi5sF7VeJRcrCVK9fEyc7@mail.gmail.com> <BB05F812-F3D3-4742-BD54-794FD4BCC0C0@oracle.com>
From: <peter.staubach@emc.com>
To: <chuck.lever@oracle.com>, <webmail.hce@gmail.com>
Cc: <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi.

Actually, that command should work.  The server should respond with an
RPC error indicating which
versions of the nlockmgr protocol are supported and then rpcinfo will
ping each of them.

		ps

-----Original Message-----
From: linux-nfs-owner@vger.kernel.org
[mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Chuck Lever
Sent: Friday, January 14, 2011 10:18 AM
To: hce
Cc: Linux NFS Mailing List
Subject: Re: mac error


On Jan 13, 2011, at 11:01 PM, hce wrote:

> Thanks for your response. I've just found that nlockmgr did not
> respond when I run following command on the server. Is it a problem or
> it is normal? Anyway, the NFS is still working fine.

nlockmgr and NFS are two separate RPC services.  So, NFS can work while
there might be a problem with nlockmgr.  IMO, nlockmgr should respond in
this case.

> $ rpcinfo -t linux_server nlockmgr
> rpcinfo: RPC: Timed out
> program 100021 version 0 is not available
> 
> $ rpcinfo -u linux_server nlockmgr
> rpcinfo: RPC: Timed out
> program 100021 version 0 is not available

This is attempting to contact nlockmgr's "version 0" which is not
registered (see below).  Versions 1, 3, and 4 are registered.

Try "rpcinfo -u linux_server nlockmgr 3".

> $ rpcinfo -p
>   program vers proto   port
>    100000    2   tcp    111  portmapper
>    100000    2   udp    111  portmapper
>    100024    1   udp    895  status
>    100024    1   tcp    898  status
>    100011    1   udp    806  rquotad
>    100011    2   udp    806  rquotad
>    100011    1   tcp    809  rquotad
>    100011    2   tcp    809  rquotad
>    100003    2   udp   2049  nfs
>    100003    3   udp   2049  nfs
>    100003    4   udp   2049  nfs
>    100021    1   udp  32794  nlockmgr
>    100021    3   udp  32794  nlockmgr
>    100021    4   udp  32794  nlockmgr
>    100003    2   tcp   2049  nfs
>    100003    3   tcp   2049  nfs
>    100003    4   tcp   2049  nfs
>    100021    1   tcp  57164  nlockmgr
>    100021    3   tcp  57164  nlockmgr
>    100021    4   tcp  57164  nlockmgr
>    100005    1   udp    828  mountd
>    100005    1   tcp    831  mountd
>    100005    2   udp    828  mountd
>    100005    2   tcp    831  mountd
>    100005    3   udp    828  mountd
>    100005    3   tcp    831  mountd

nlockmgr is registered, so it must have been started at some point.
It's a kernel service, so there's no daemon to die.  Do you have some
kind of firewall in place that would prevent contacting the NLM service?
Does "linux_server" resolve to the IP address you expect it to?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

