Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764AbbAWODx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jan 2015 09:03:53 -0500
Message-ID: <54C254C7.8090507@RedHat.com>
Date: Fri, 23 Jan 2015 09:03:51 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: =?UTF-8?B?SG9sZ2VyIEhvZmZzdMOkdHRl?=
	<holger.hoffstaette@googlemail.com>,
        linux-nfs@vger.kernel.org
Subject: Re: nfs-utils/idmapd: use of private define breaks with libevent-2.1.x
References: <pan.2015.01.17.18.25.17@googlemail.com>
In-Reply-To: <pan.2015.01.17.18.25.17@googlemail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/17/2015 01:25 PM, Holger Hoffstätte wrote:
> 
> Hello,
> 
> The Gentoo community has found a problem with the current release of
> nfs-utils, where idmapd uses a not strictly private, yet strongly
> discouraged #define.
> 
> Bug description with proposed patch:
> https://bugs.gentoo.org/show_bug.cgi?id=446374
Committed... 

steved.

> 
> The code in question:
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=blob;f=utils/idmapd/idmapd.c;hb=HEAD#l719 
> 
> According to:
> https://github.com/libevent/libevent/blob/master/include/event2/event_struct.h
> 
> which says:
> "No field declared in this file should be used directly in user code."
> 
> using EVLIST_INIT directly is bound to break. This seems to be a leftover
> from legacy code.
> 
> A simple fix is attached to the bugzilla above and just calls the
> proper public API, which is functionally equivalent to the bit check.
> 
> Would be nice to see this in 1.3.2. :)
> 
> Thanks!
> 
> Holger
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
