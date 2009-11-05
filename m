From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: IPv6 support
Date: Thu, 05 Nov 2009 17:19:51 +0530
Message-ID: <4AF2BBDF.9060505@suse.de>
References: <4AEE9645.6010503@suse.de> <B3F6BEAE-A564-475F-93D5-7D6E0FC79147@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Chris Mason <chris.mason@oracle.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:56360 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754565AbZKELtv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Nov 2009 06:49:51 -0500
In-Reply-To: <B3F6BEAE-A564-475F-93D5-7D6E0FC79147@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

Thanks much for the detailed update.

On 11/02/2009 10:10 PM, Chuck Lever wrote:
> On Nov 2, 2009, at 3:20 AM, Suresh Jayaraman wrote:
>> Hi Chuck et al,
>>
>> Thanks for all the excellent work on IPv6 support. There have been
>> considerable amount of development that has been happening recently.
>> However, it's not very clear what are the missing pieces or open
>> problems (if any).
> 
> There's a working document on the linux-nfs.org wiki that has a full
> list, but I can't seem to get to linux-nfs.org right now.

Is this what you mentioned?

http://wiki.linux-nfs.org/wiki/index.php/Server_IPv6_support
http://wiki.linux-nfs.org/wiki/index.php/NFSv4_Introduction#IPv6_support_for_the_client

> 
> The long answer depends on your definition of "full".  :-)
> 
> Does that include complete support for link-local IPv6 addresses?  Does
> that include full support for netids in the kernel?  Does that include
> complete multi-homed host support in lockd and statd?  Does that include
> full support for internationalized domain names?  Does that include IPv6
> netgroup support?  Does it include IPv6 support in TCP wrappers?  Does
> it include support for systems that have no IPv4 addresses (not even
> loopback)?
> 
> There are a bunch of details that still need to be worked through.  I've
> only been able to guess at what features are required, and which can be
> implemented at a later time.  What I would dearly love to have is a list
> of specific features that folks feel is a baseline (based on actual
> data, of course).  

I'd try and see if I could get the list of specific features.

> 
> Plus, most distributions don't have fluent user space infrastructure for
> IPv6 yet.  NetworkManager is one area that may need work.  The Network
> Administration tool in Fedora is still IPv4-centric, iirc.  We don't
> have firewall admin tools that handle IPv6 rules.  Unlike IPv4, admins
> can (and often do) use IPv6-aware kernels without ipv6.ko, so all of our
> tools and support have to be careful about using IPv6 when the O/S may
> not support it.  This is different than IPv4, which is nearly always
> available.
> 

Thanks,

-- 
Suresh Jayaraman
