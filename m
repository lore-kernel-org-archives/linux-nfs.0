Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f46.google.com ([74.125.82.46]:64624 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546Ab3EMMWX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 May 2013 08:22:23 -0400
Received: by mail-wg0-f46.google.com with SMTP id n12so6071864wgh.1
        for <linux-nfs@vger.kernel.org>; Mon, 13 May 2013 05:22:22 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 13 May 2013 13:22:22 +0100
Message-ID: <CAEBR3EH71A3jbxhEBcBX7_QFzVw6C9SQuer2zwZ+DDYzqOOWBg@mail.gmail.com>
Subject: recursive ACL inherit
From: Oliver Lee <oliver.lee2007@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

When using the nfs4_setfacl tool I've found that recursive operations
fail when using the d or f inheritance flags because nfs4_setfacl
tries to apply them to files as well as directories, which obviously
doesn't make sense.

so

nfs4_setfacl -R -s A:df:OWNER@:RWX,A:dfg:GROUP@:RWX,A:df:EVERYONE@:RX /directory

You would expect to allow:
owner read,write and execute
group read,write and execute
others read and execute
applied to all directories and files under (and including) /directory,
so that newly created files and directories also have the same
permissions

This fails with:
Failed setxattr operation: Input/output error
An error occurred during recursive file tree walk.

When nfs4_setfacl encounters the first file. All directories before
the first file are changed correctly

Am I doing something wrong or is this a bug/missing feature?

Also, the man page for nfs4_acl references nfs4_setacl in its SEE ALSO
section, presumably this should be nfs4_setfacl?
Finally, the man page references nfsv4@linux-nfs.org in its CONTACT section

NFS Server is Debian 7, kernel 3.2.0-4-686-pae
Clients are Debian 7 and openSUSE 12.3

Thanks for your time
