From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] nfs-utils: Enabling TCP wrappers
Date: Thu, 18 Dec 2008 16:21:58 -0500
Message-ID: <494ABEF6.7070700@RedHat.com>
References: <49468BC7.2000907@RedHat.com> <1819C671-5353-45B4-A814-98B1B2A4BEB1@oracle.com> <494AABA1.4070006@RedHat.com> <04AA0955-045D-432B-B96D-4A21F4889F6D@oracle.com> <494AB74E.3040403@RedHat.com> <CB549023-9164-4258-91EC-D9E3F2EF74E5@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Olaf Kirch <okir@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36264 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047AbYLRVYO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2008 16:24:14 -0500
In-Reply-To: <CB549023-9164-4258-91EC-D9E3F2EF74E5@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Hi Steve-
> 
> On Dec 18, 2008, at Dec 18, 2008, 3:49 PM, Steve Dickson wrote:
>> Chuck Lever wrote:
>>>> @@ -72,12 +74,29 @@ mount_dispatch(struct svc_req *rqstp, SVCXPRT
>>>> *transp)
>>>>    union mountd_results    result;
>>>>
>>>> #ifdef HAVE_TCP_WRAPPER
>>>> +#ifdef IPV6_SUPPORTED
>>>> +    static int once = 0;
>>>> +
>>>> +    if (svc_getcaller(transp)->sin_family != AF_INET) {
>>>
>>> It's not clear to me that svc_getcaller() will ever return a non-AF_INET
>>> address.
>>>
>>> Should we use svc_getcaller_netbuf() here instead?
>> I would if I could but there is no svc_getcaller_netbuf() in the
>> glibc version of RPC...
> 
> If IPV6_SUPPORTED is set than libtirpc is required to be available. 
> nfs-utils won't build with --enable-ipv6 if there's no libtirpc.
Ah... good point! So something like this should work:

    sa = (struct sockaddr *)svc_getcaller_netbuf(transp)->buf;

    if (sa->sa_family != AF_INET) {

        if (!once) {

            syslog(LOG_WARNING,

                "No IPv6 support in Access Control Library (TCP
Wrappers)");

            once++;

        }

        goto skipcheck;

    }


steved.

