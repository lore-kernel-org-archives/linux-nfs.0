From: "Chen, Helen Y" <hycsw@sandia.gov>
Subject: RE: Fwd: Re: [pnfs] problem building pnfs-nfs-utils under
 Fedora 13
Date: Tue, 20 Jul 2010 16:51:40 -0600
Message-ID: <F9F38212E2D77948B1CD89D239A7C07B138EFFAC41@ES01SNLNT.srn.sandia.gov>
References: <4BFD1595.1070502@panasas.com> <4BFD65CA.7080509@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Cc: "'NFS list'" <linux-nfs@vger.kernel.org>
To: "'Steve Dickson'" <SteveD@redhat.com>,
	"'Benny Halevy'" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sentry-three.sandia.gov ([132.175.109.17]:52678 "EHLO
	sentry-three.sandia.gov" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932987Ab0GTWvw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 18:51:52 -0400
In-Reply-To: <4BFD65CA.7080509-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Benny,

I installed Steve's fedora 13 pnfs kernel and your pnfs utils from the git tree on my 3 node testbed, a client, a MDS and a DS.  I have successfully configured and mounted pNFS from the client, but can only create empty files in the directory.  All attempts to write resulted in remote I/O errors.  I discovered later that spnfsd is not running on the MDS.  It dies silently every time I tried to start it. Running spnfsd with gdb indicated that it is reading /etc/spnfsd.conf correctly but crashed while writing to /proc/fs/spnfs/config.  Your help will be appreciated?

Thanks in advance,
Helen


-----Original Message-----
From: Steve Dickson [mailto:SteveD@redhat.com] 
Sent: Wednesday, May 26, 2010 11:18 AM
To: Benny Halevy
Cc: NFS list; Chen, Helen Y
Subject: Re: Fwd: Re: [pnfs] problem building pnfs-nfs-utils under Fedora 13



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
> 'configure' when I ran autogen.sh:
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


