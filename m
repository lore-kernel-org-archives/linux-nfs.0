From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] nfs-utils: Enabling TCP wrappers
Date: Mon, 15 Dec 2008 12:56:38 -0500
Message-ID: <49469A56.1070704@RedHat.com>
References: <49468BC7.2000907@RedHat.com> <1819C671-5353-45B4-A814-98B1B2A4BEB1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55977 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750967AbYLOR6y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Dec 2008 12:58:54 -0500
In-Reply-To: <1819C671-5353-45B4-A814-98B1B2A4BEB1@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> On Dec 15, 2008, at 11:54 AM, Steve Dickson wrote:
>> Recently I was asked to re-enable the TCP wrapper calls, that check the
>> validity of client that communicate with mountd and statd.
>>
>> It became very apparent this code had not been used in a while
>> and was as a bit broken. So this patch set fixes the logic and
>> tries to make the code scale better.
>>
>> The commit blobs in the set are relative to the 'tcpwrap'
>> branch in the git://linux-nfs.org/~steved/nfs-utils-exp.git
>> git tree.
>>
>> Comments?
> 
> A general comment:  This code will need support for IPv6 addresses.
> 
> Until it has it, perhaps we should add some logic to configure.ac that
> prevents the use of tcpwrappers when --enable-ipv6 is in effect.
Good point...

steved.

