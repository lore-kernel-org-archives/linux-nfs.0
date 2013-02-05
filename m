Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:25097 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754036Ab3BEAEK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2013 19:04:10 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: Probable rpc.mountd regression in nfs-utils-1.2.6
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1360021461/oystr@maui.cs.washington.edu>
Date: Mon, 4 Feb 2013 19:04:05 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <63123289-EEE8-4A48-B88C-36A1A062ACFE@oracle.com>
References: <1360021461/oystr@maui.cs.washington.edu>
To: Jan Sanislo <oystr@cs.washington.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 4, 2013, at 6:44 PM, Jan Sanislo <oystr@cs.washington.edu> wrote:

> Attempting to NFSv4 mount a file system from an NFS server running the
> rpc.mountd from nfs-utils-1.2.6 will hang indefinitely if the file
> system in question is not exported to the client machine.  Attempting
> to mount the same, non-exported file system using NFSv3 will produce
> the expected error message: "mount.nfs: access denied by server while
> mounting ....".
> 
> This problem seems to stem from a change in the 1.2.6 version of
> the nfs-utils mountd program: utils/mountd/cache.c[auth_unix_ip()].
> 
> In the 1.2.5 version of auth_unix_ip the code is:
> 
>        /* addr is a valid, interesting address, find the domain name... */
>        if (!use_ipaddr) {
>                ai = client_resolve(tmp->ai_addr);
>                client = client_compose(ai);
>                freeaddrinfo(ai);
>        }
>        freeaddrinfo(tmp);
> 
>        qword_print(f, "nfsd");
> 	qword_print(f, ipaddr);
> 	....
> 
> I.e., mountd *always* wrote at least the ip address down the
> /proc/net/rpc/auth.unix.ip/channel pipe in response to kernel upcall.
> 
> In the 1.2.6 version of auth_unix_ip the code is:
> 
>        /* addr is a valid, interesting address, find the domain name... */
>        if (!use_ipaddr) {
>                struct addrinfo *ai = NULL;
> 
>                ai = client_resolve(tmp->ai_addr);
>                if (ai == NULL)
>                        goto out;
>                client = client_compose(ai);
>                freeaddrinfo(ai);
>                if (!client)
>                        goto out;
>        }
>        qword_print(f, "nfsd");
>        qword_print(f, ipaddr);
> 	...
>  out:
> 
> In this latter case, the kernel upcall is responded to only if the
> requesting IP address is associated with an exported file system.
> Without the response the kernel waits about 5 seconds and then
> drops the NFS request (PUTROOTFH,GETATTR,...) and leaves the client
> hanging.

Probably fixed by commit cb3b81d6, in nfs-utils 1.2.8-rc1.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




