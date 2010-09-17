Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:21625 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754439Ab0IQSkK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Sep 2010 14:40:10 -0400
Subject: Re: nfsv3 gssapi client?
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20100917174328.GC25515@fieldses.org>
Date: Fri, 17 Sep 2010 14:39:32 -0400
Cc: George Mamalakis <mamalos@eng.auth.gr>, linux-nfs@vger.kernel.org
Message-Id: <6140A069-3C67-4E5A-84E5-124BCD1EAF50@oracle.com>
References: <4C938F3B.4030604@eng.auth.gr> <20100917174328.GC25515@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 17, 2010, at 1:43 PM, J. Bruce Fields wrote:

> On Fri, Sep 17, 2010 at 06:54:35PM +0300, George Mamalakis wrote:
>>  Hi all,
>> 
>> I have a FreeBSD nfsv3 server that exports a filesystem with
>> sec=krb5. Mounting the share with sec=krb5 under a fbsd client works
>> fine. I now try to mount it under linux (archlinux, upgraded today)
>> using nfs-utils. Heimdal is configured on the linux-box, kinit -k
>> linuxclient works fine. I am also able to kinit to my user
>> principals from it. When I try to mount the nvsv3 sec=krb5 share, I
>> get the following error:
>> 
>> # mount -t nfs -o sec=krb5 fbsdserver:/exports /mnt
>> 
> 
> Was there supposed to be some error output there?  Or did the mount just
> hang?
> 
>> # tail /var/log/messages
>> Sep 17 16:05:31 linuxclient rpc.statd[27683]: Version 1.2.2 starting
>> Sep 17 16:05:31 linuxclient sm-notify[27684]: Version 1.2.2 starting
>> Sep 17 16:05:31 linuxclient sm-notify[27684]: Already notifying
>> clients; Exiting!
>> Sep 17 16:05:31 linuxclient rpc.statd[27683]: Running as root.
>> chown /var/lib/nfs to choose different user
>> Sep 17 16:05:31 linuxclient sm-notify[27687]: Version 1.2.2 starting
>> Sep 17 16:05:31 linuxclient sm-notify[27687]: Already notifying
>> clients; Exiting!
>> Sep 17 16:05:53 linuxclient kernel: svc: failed to register lockdv1
>> RPC service (errno 111).
>> Sep 17 16:05:53 linuxclient kernel: lockd_up: makesock failed, error=-111
>> Sep 17 16:05:54 linuxclient kernel: svc: failed to register lockdv1
>> RPC service (errno 111).
>> Sep 17 16:05:57 linuxclient kernel: svc: failed to register lockdv1
>> RPC service (errno 111).
>> Sep 17 16:06:01 linuxclient kernel: svc: failed to register lockdv1
>> RPC service (errno 111).
> 
> 111 is ECONNREFUSED.  I'm not sure why that's failing.  (Should failure
> to register lockd fail the whole mount?

I could be wrong, but I believe that yes, it should fail the mount operation in this case, unless you specified "nolock".

> I thought it would at worst
> result in ENOLCK on lock requests?) Do you get better results if you
> mount with nolock?

-- 
chuck[dot]lever[at]oracle[dot]com




