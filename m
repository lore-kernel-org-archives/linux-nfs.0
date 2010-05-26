Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21987 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751749Ab0EZSRw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 May 2010 14:17:52 -0400
Message-ID: <4BFD65CA.7080509@RedHat.com>
Date: Wed, 26 May 2010 14:17:46 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Benny Halevy <bhalevy@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>, "Chen, Helen Y" <hycsw@sandia.gov>
Subject: Re: Fwd: Re: [pnfs] problem building pnfs-nfs-utils under Fedora
 13
References: <4BFD1595.1070502@panasas.com>
In-Reply-To: <4BFD1595.1070502@panasas.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 05/26/2010 08:35 AM, Benny Halevy wrote:
> Has anyone successfully build pnfs enabled nfs utils under Fedora 13? 
Yes... I run both the kernel and nfs-utils on a number of my test machines
to ensure they stability.

> I am running the kernel from:
> http://steved.fedorapeople.org/repos/pnfs/13/x86_64/
You might want to think about installing the yum repo at
   http://steved.fedorapeople.org/pnfs.repo
so you can automatically get updates

>  
> I am having trouble building these utils. I failed to generate
> ‘configure’ when I ran autogen.sh:
Here is the list of packages that need to be installed to 
build the Fedora nfs-utils:

libgssglue-devel

libevent-devel

libcap-devel

nfs-utils-lib-devel

libtirpc-devel

libblkid-devel

openldap-devel

krb5-devel

tcp_wrappers-devel


To install these all at once, cat them into a file and then:

yum install `cat /tmp/list` 

Next run the following commands:

   ./autogen.sh && ./configure && make 

> I am new at this and would appreciate any help you can provide.
Well welcome... and please let know if there any more problems...

steved.
