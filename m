Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:34148 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883Ab1LXQxG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Dec 2011 11:53:06 -0500
Date: Sat, 24 Dec 2011 11:53:01 -0500
From: Jim Rees <rees@umich.edu>
To: Jeff Layton <jlayton@redhat.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] autoconf: clean up linking in nfs-utils
Message-ID: <20111224165301.GA16658@umich.edu>
References: <1324669625-2948-1-git-send-email-jlayton@redhat.com>
 <20111224145456.GA13830@umich.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111224145456.GA13830@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jim Rees wrote:

  Jeff Layton wrote:
  
    This patchset is a cleanup of the linking in nfs-utils. This should
    reduce the number of unnecessary libraries that each of the binaries are
    linked against.
  
  This is probably unrelated to your patches, but here's what I get:
  
  ...
  /bin/bash ../../libtool --tag=CC   --mode=link gcc -Wall -Wextra -Wstrict-prototypes  -pipe -g -O2   -o nfsidmap nfsidmap.o -lnfsidmap -lkeyutils -lnfsidmap -ltirpc 
  libtool: link: gcc -Wall -Wextra -Wstrict-prototypes -pipe -g -O2 -o nfsidmap nfsidmap.o  -lkeyutils -lnfsidmap -ltirpc
  nfsidmap.o: In function `key_revoke':
  /home/rees/p/nfs-utils/utils/nfsidmap/nfsidmap.c:153: undefined reference to `xlog_syslog'
  ...

Never mind, cockpit error.  I ran autogen in the wrong directory.  Now I'm
getting this:

% configure --prefix=/usr --sysconfdir=/etc --enable-nfsv41 --enable-ipv6 \
?   --disable-gss --disable-uuid --enable-tirpc --without-tcp-wrappers \
?   --disable-libmount-mount
...
checking for bindresvport_sa... no
configure: error: Missing library functions needed for IPv6.
