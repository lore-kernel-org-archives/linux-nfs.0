Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41804 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750789AbdAMT7b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 13 Jan 2017 14:59:31 -0500
From: Steve Dickson <SteveD@redhat.com>
Subject: ANNOUNCE: nfs-utils-2.1.1 released.
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
Message-ID: <c009d974-6731-f186-53fd-11acc87b3cf7@RedHat.com>
Date: Fri, 13 Jan 2017 14:59:31 -0500
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

nfs-utils-2.1.1 has just been released. This is a 
major release because the configuration of the 
NFS server has fundamentally changed. 

All the daemon configurations now go through one 
file, /etc/nfs.conf. See nfs.conf(5). 

The command line interface in the systemd service 
files have been removed. This means the configuration 
file under /etc/sysconfig or /etc/defaults will 
no longer work. 

I'm leaving it up to the distros to figure out how
to deal with the backwards compatibility issue if/when 
they adopt this version.   

I believe this is right way to go. There are a number 
of external projects looking to configure the NFS server 
and having one file to deal with is a good thing... 

I want thank Neil Brown for all the work he did to 
make this happen.

The release also contains a number of bug fixes
and improvements. 


The tarballs can be found in
  https://www.kernel.org/pub/linux/utils/nfs-utils/2.1.1/
or
  http://sourceforge.net/projects/nfs/files/nfs-utils/2.1.1

The change log is in
   https://www.kernel.org/pub/linux/utils/nfs-utils/2.1.1/2.1.1-Changelog
or
   http://sourceforge.net/projects/nfs/files/nfs-utils/2.1.1/

The git tree is at:
   git://linux-nfs.org/~steved/nfs-utils

Please send comments/bugs to linux-nfs@vger.kernel.org

steved.
