From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] nfs-utils: Enabling TCP wrappers
Date: Thu, 18 Dec 2008 15:56:35 -0500
Message-ID: <CB549023-9164-4258-91EC-D9E3F2EF74E5@oracle.com>
References: <49468BC7.2000907@RedHat.com> <1819C671-5353-45B4-A814-98B1B2A4BEB1@oracle.com> <494AABA1.4070006@RedHat.com> <04AA0955-045D-432B-B96D-4A21F4889F6D@oracle.com> <494AB74E.3040403@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Olaf Kirch <okir@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:35760 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949AbYLRU5d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Dec 2008 15:57:33 -0500
In-Reply-To: <494AB74E.3040403-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

On Dec 18, 2008, at Dec 18, 2008, 3:49 PM, Steve Dickson wrote:
> Chuck Lever wrote:
>>> @@ -72,12 +74,29 @@ mount_dispatch(struct svc_req *rqstp, SVCXPRT
>>> *transp)
>>>    union mountd_results    result;
>>>
>>> #ifdef HAVE_TCP_WRAPPER
>>> +#ifdef IPV6_SUPPORTED
>>> +    static int once = 0;
>>> +
>>> +    if (svc_getcaller(transp)->sin_family != AF_INET) {
>>
>> It's not clear to me that svc_getcaller() will ever return a non- 
>> AF_INET
>> address.
>>
>> Should we use svc_getcaller_netbuf() here instead?
> I would if I could but there is no svc_getcaller_netbuf() in the
> glibc version of RPC...

If IPV6_SUPPORTED is set than libtirpc is required to be available.   
nfs-utils won't build with --enable-ipv6 if there's no libtirpc.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
