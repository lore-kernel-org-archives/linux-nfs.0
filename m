Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:42475 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760586Ab2CNXZp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Mar 2012 19:25:45 -0400
Received: by lahj13 with SMTP id j13so1924530lah.19
        for <linux-nfs@vger.kernel.org>; Wed, 14 Mar 2012 16:25:43 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 14 Mar 2012 19:25:43 -0400
Message-ID: <CAP=VYLoNpAU7YAvy+3KrqpBErbJtE9i4_3uCyv-QaMgHiD6evw@mail.gmail.com>
Subject: NFS related randconfig failure on powerpc ('nfs_debug' undeclared)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
To: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Just a heads up that linux-next builds found this;

fs/nfs/nfs4xdr.c:3443:27: error: 'nfs_debug' undeclared (first use in
this function)
make[3]: *** [fs/nfs/nfs4xdr.o] Error 1
make[2]: *** [fs/nfs] Error 2
make[1]: *** [fs] Error 2
make: *** [sub-make] Error 2

Full build log at:

http://kisskb.ellerman.id.au/kisskb/buildresult/5871973/

Paul.
