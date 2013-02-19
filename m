Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:33321 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933885Ab3BSTQ3 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2013 14:16:29 -0500
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH [rpcbind]] fix building one systems w/out nss.h
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <201302191414.51958.vapier@gentoo.org>
Date: Tue, 19 Feb 2013 14:16:18 -0500
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Message-Id: <88E7D0D7-8F5A-42D2-B535-DB19A004945E@oracle.com>
References: <1361299690-19402-1-git-send-email-vapier@gentoo.org> <D1025EAD-8EEB-40A4-8EA4-0D21ECC16B66@oracle.com> <201302191414.51958.vapier@gentoo.org>
To: Mike Frysinger <vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 19, 2013, at 2:14 PM, Mike Frysinger <vapier@gentoo.org> wrote:

> On Tuesday 19 February 2013 13:54:19 Chuck Lever wrote:
>> On Feb 19, 2013, at 1:48 PM, Mike Frysinger <vapier@gentoo.org> wrote:
>>> The nss.h header is glibc-specific, so use the existing HAVE_NSS_H define
>>> to avoid including/using it when it is not available.
>>> --- a/src/rpcbind.c
>>> +++ b/src/rpcbind.c
>>> @@ -67,7 +67,11 @@
>>> #include <pwd.h>
>>> #include <string.h>
>>> #include <errno.h>
>>> +#ifdef HAVE_NSS_H
>>> #include <nss.h>
>>> +#else
>>> +static inline void __nss_configure_lookup(const char *db, const char *s)
>>> {} +#endif
>> 
>> Where is rpcbind getting the __nss_configure_lookup() function in this
>> case?  I don't see that the call sites are ifdef-d out if HAVE_NSS_H is
>> not defined.
> 
> i'm not sure what you mean.
> 
> if nss.h exists, then HAVE_NSS_H is defined, and the nss.h header provides the 
> __nss_configure_lookup prototype (and presumably, the C library provides that 
> func).
> 
> if nss.h doesn't exist, then HAVE_NSS_H is not defined, so we have to stub out 
> the __nss_configure_lookup func.  i could have put "#ifdef HAVE_NSS_H" around 
> all the call sites, but i think this version is cleaner and less error prone.

OK, clear.  Sorry to be dense.

> 
> also, i typoed the subject name ("one" vs "on").
> -mike

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




