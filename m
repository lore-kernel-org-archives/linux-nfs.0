Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17746 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755118Ab2JPSj6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Oct 2012 14:39:58 -0400
Date: Tue, 16 Oct 2012 13:39:56 -0500
From: "Haynes, Tom" <thomas@netapp.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Testing XDR code for nits
Message-ID: <20121016183956.GA19073@netapp.com>
References: <20121015173035.GA1777@netapp.com>
 <507C7129.7090609@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <507C7129.7090609@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 15, 2012 at 04:25:13PM -0400, Steve Dickson wrote:
> 
> Here is the list of build decencies to build a Fedora nfs-utils rpm.
> 
> libgssglue-devel libevent-devel libcap-devel
> libnfsidmap-devel libtirpc-devel libblkid-devel
> krb5-libs >= 1.4 autoconf >= 2.57 openldap-devel >= 2.2
> automake, libtool, glibc-headers, device-mapper-devel
> krb5-devel, tcp_wrappers-devel, libmount-devel
> fedfs-utils-devel >= 0.8.0-7
> 
> I hope this helps...
> 
> steved.

The difference I finally can see is FC13:


[thomas@ietf include]$ ls -la /usr/include/rpcsecgss
total 20
drwxr-xr-x    3 root root  4096 Oct 16 11:49 .
drwxr-xr-x. 134 root root 12288 Oct 16 11:49 ..
drwxr-xr-x    2 root root  4096 Oct 16 11:49 rpc
[thomas@ietf include]$ yum provides /usr/include/rpcsecgss/rpc/rpcsecgss_rename.h
Loaded plugins: presto, refresh-packagekit
nfs-utils-lib-devel-1.1.5-1.fc13.i686 : Development files for the nfs-utils-lib library
Repo        : fedora
Matched from:
Filename    : /usr/include/rpcsecgss/rpc/rpcsecgss_rename.h



nfs-utils-lib-devel-1.1.5-1.fc13.i686 : Development files for the nfs-utils-lib library
Repo        : installed
Matched from:
Other       : Provides-match: /usr/include/rpcsecgss/rpc/rpcsecgss_rename.h

And FC17:

[thomas@psyklo include]$ ls -la /usr/include/rpcsecgss
ls: cannot access /usr/include/rpcsecgss: No such file or directory
[thomas@psyklo include]$ yum provides /usr/include/rpcsecgss/rpc/rpcsecgss_rename.h
Loaded plugins: langpacks, presto, refresh-packagekit
nfs-utils-lib-devel-1.1.5-6.fc17.i686 : Development files for the nfs-utils-lib library
Repo        : fedora
Matched from:
Filename    : /usr/include/rpcsecgss/rpc/rpcsecgss_rename.h



nfs-utils-lib-devel-1.1.5-6.fc17.x86_64 : Development files for the nfs-utils-lib library
Repo        : fedora
Matched from:
Filename    : /usr/include/rpcsecgss/rpc/rpcsecgss_rename.h


mas@psyklo include]$ sudo yum -y install nfs-utils-lib-devel
Loaded plugins: langpacks, presto, refresh-packagekit
Resolving Dependencies
--> Running transaction check
---> Package nfs-utils-lib-devel.x86_64 0:1.1.5-6.fc17 will be installed
--> Processing Dependency: librpcsecgss.so.3()(64bit) for package: nfs-utils-lib-devel-1.1.5-6.fc17.x86_64
Package nfs-utils-lib-1.1.5-6.fc17.x86_64 is obsoleted by libnfsidmap-0.25-3.fc17.x86_64 which is already installed
--> Finished Dependency Resolution
Error: Package: nfs-utils-lib-devel-1.1.5-6.fc17.x86_64 (fedora)
           Requires: librpcsecgss.so.3()(64bit)
           Available: nfs-utils-lib-1.1.5-6.fc17.x86_64 (fedora)
               librpcsecgss.so.3()(64bit)
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
[thomas@psyklo include]$ sudo yum -y --skip-broken install nfs-utils-lib-devel
Loaded plugins: langpacks, presto, refresh-packagekit
Resolving Dependencies
--> Running transaction check
---> Package nfs-utils-lib-devel.x86_64 0:1.1.5-6.fc17 will be installed
--> Processing Dependency: librpcsecgss.so.3()(64bit) for package: nfs-utils-lib-devel-1.1.5-6.fc17.x86_64
Package nfs-utils-lib-1.1.5-6.fc17.x86_64 is obsoleted by libnfsidmap-0.25-3.fc17.x86_64 which is already installed

Packages skipped because of dependency problems:
    nfs-utils-lib-devel-1.1.5-6.fc17.x86_64 from fedora

So it looks like this functionality is no longer provided.

What is supposed to replace it?


-- 
Tom Haynes - ex-cfb
