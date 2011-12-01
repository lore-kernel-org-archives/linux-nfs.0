Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:33729 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649Ab1LACne (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Nov 2011 21:43:34 -0500
Date: Wed, 30 Nov 2011 21:43:19 -0500
From: Jim Rees <rees@umich.edu>
To: Bruce Dubbs <bruce.dubbs@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: nfs server issues
Message-ID: <20111201024319.GA10246@umich.edu>
References: <4ED6BCEA.9050000@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4ED6BCEA.9050000@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce Dubbs wrote:

  I am trying to document the installation of nfs for Linux From
  Scratch.  The client works, but the server does not and I'm looking
  for some help.   If this is the wrong place to ask for help, please
  redirect me.
  
  For now, I am only trying to get nfs version 3 to work.
  
  # mount -t nfs -o nfsvers=3 lfs6:/home/bdubbs /mnt/test
     [ mounts OK ]
  # mount -t nfs -o nfsvers=3 localhost:/usr/src /mnt/tmp
  # mount.nfs: requested NFS version or transport protocol is not supported

It doesn't explain the error message you're getting, but your exports file
doesn't have an entry for localhost.  When I try this I get "mount.nfs:
access denied by server while mounting localhost:/usr/src".

  2. Build libtirpc
     Remove auth_des.c authdes_prot.c des_crypt.c from Makefile
     Comment out authdes_create() in rpc_soc.c
     ./configure --prefix=/usr --libdir=/lib

This shouldn't be necessary.  Instead of working around the problem, it
would be nice if you could figure out why you needed to do this, and if
there is a bug in the configure magic, let us know.
