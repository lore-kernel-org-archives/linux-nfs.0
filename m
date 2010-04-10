From: Thomas Wunder <thomas.wunder@swt-bamberg.de>
Subject: Re: NFS-Mount with MIT-Kerberos5 doesn't use user tickets...
Date: Sat, 10 Apr 2010 18:13:10 +0200
Message-ID: <201004101813.10319.thomas.wunder@swt-bamberg.de>
References: <loom.20100407T160936-119@post.gmane.org> <y2o4d569c331004090750zeb56bf58udb7bbfb3277832c@mail.gmail.com> <4BBF57D4.80301@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Cc: Kevin Coffman <kwc@citi.umich.edu>, linux-nfs@vger.kernel.org,
	"William A. \(Andy\) Adamson" <androsadamson@gmail.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ldap.uni-bamberg.de ([141.13.240.32]:3396 "EHLO
	urz32.UNI-BAMBERG.DE" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428Ab0DJQNP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 10 Apr 2010 12:13:15 -0400
In-Reply-To: <4BBF57D4.80301@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> I don't know anything about these upcalls, sorry.
But maybe you know which piece of code puts the uid into
/var/lib/nfs/rpc_pipefs/clntXX/krb5

It's hard for me to find an entry point to dig into the nfs kernel code on my 
own as i haven't got any experience with linux "filesystem drivers" yet...

We just need to find out why it always puts "0" there instead of the real uid 
of the user which invoked the mound command...

