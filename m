Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:53754 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759154Ab2HHTk3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Aug 2012 15:40:29 -0400
Date: Wed, 8 Aug 2012 15:40:21 -0400
From: Jim Rees <rees@umich.edu>
To: "bjschuma@gmail.com" <bjschuma@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] NFS: Fix a regression when loading the NFS v4 module
Message-ID: <20120808194021.GA24950@umich.edu>
References: <CAMFXNOztZkvP963ZWAa72aAj3ydJvhLgxU2m8_20bsZV3uqwLQ@mail.gmail.com>
 <CAMFXNOw0G4Yp0GZmetF6akD=YqKyXBL9aoFq=kF2wiEPwPhU0w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAMFXNOw0G4Yp0GZmetF6akD=YqKyXBL9aoFq=kF2wiEPwPhU0w@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

bjschuma@gmail.com wrote:

  I forgot to CC the mailing list... oops.
  
  
  ---------- Forwarded message ----------
  From: bjschuma@gmail.com <bjschuma@gmail.com>
  Date: Wed, Aug 8, 2012 at 1:57 PM
  Subject: [PATCH 1/2] NFS: Fix a regression when loading the NFS v4 module
  To: Trond Myklebust <Trond.Myklebust@netapp.com>
  Cc: "J. Bruce Fields" <bfields@fieldses.org>, jlayton@redhat.com
  
  
  Some systems have a modprobe.d/nfs.conf file that sets an nfs4 alias
  pointing to nfs.ko, rather than nfs4.ko.  This can prevent the v4 module
  from loading on mount, since the kernel sees that something named "nfs4"
  has already been loaded.  To work around this, I've renamed the modules
  to "nfsv2.ko" "nfsv3.ko" and "nfsv4.ko".

Is there no better way to do this?  We tried for years to standardize on
nfs4 rather than nfsv4.  In particular, this means the module name will no
longer be part of the names of the files used to build the module.
