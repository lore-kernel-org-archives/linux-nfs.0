From: Brian De Wolf <bldewolf@csupomona.edu>
Subject: nfs4_getfacl "Failed getxattr operation" when too many ACL entries
 exist
Date: Thu, 10 Apr 2008 14:53:44 -0700
Message-ID: <47FE8C68.50502@csupomona.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tweak.unx.csupomona.edu ([134.71.247.20]:38010 "EHLO
	tweak.unx.csupomona.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756802AbYDJWCB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2008 18:02:01 -0400
Received: from localhost (localhost [127.0.0.1])
	by tweak.unx.csupomona.edu (Postfix) with ESMTP id A00B21345E0
	for <linux-nfs@vger.kernel.org>; Thu, 10 Apr 2008 14:53:45 -0700 (PDT)
Received: from tweak.unx.csupomona.edu ([127.0.0.1])
	by localhost (tweak.unx.csupomona.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id s7znvIfrPiuC for <linux-nfs@vger.kernel.org>;
	Thu, 10 Apr 2008 14:53:45 -0700 (PDT)
Received: from [134.71.248.29] (woof.iitsystems.csupomona.edu [134.71.248.29])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: bldewolf)
	by tweak.unx.csupomona.edu (Postfix) with ESMTP id 7E95D1345DD
	for <linux-nfs@vger.kernel.org>; Thu, 10 Apr 2008 14:53:45 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently we've been prototyping serving Solaris ZFS exports via NFSv4 to some 
Linux hosts.  These will some day be exposed to general users, so I've been 
testing things to see if I can break them.  Anyway, it seems that nfs4_getfacl 
is only able to read ACLs with up to 208 entries.  nfs4_setfacl is able to 
insert a 209th entry, but any attempts to view or edit the ACLs after that fail 
with:

Failed getxattr operation
: Input/output error

There are two ways to make the ACLs readable again:
1) Have someone log in to the Solaris box and remove some of the entries
2) Reset the ACLs using nfs4_setfacl -s `some spec`

Has anyone run into this issue before?  Is it fixable?  I didn't reach the same 
problem locally on the Solaris box, nor on another Solaris box with the same NFS 
mount, so it looks like it's a problem specific to Linux.  Here's the versions 
of relevant packages on the test box running Gentoo (did I miss any?):
Kernel: 2.6.23-gentoo-r8
nfs-utils-1.1.0-r1
attr-2.4.39
nfs4-acl-tools-0.3.2
