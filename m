Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:36134 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753355Ab0CHKmR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Mar 2010 05:42:17 -0500
Date: Mon, 8 Mar 2010 21:42:06 +1100 (EST)
From: James Morris <jmorris@namei.org>
To: linux-nfs@vger.kernel.org
cc: linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH 0/6][v4][RFC] NFSv3: implement extended attribute protocol
 (XATTR)
In-Reply-To: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>
Message-ID: <alpine.LRH.2.00.1003082122340.6314@tundra.namei.org>
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This is version 4 of the NFSv3 XATTR protocol extension patches, which 
I've previously posted:
 
v1: http://thread.gmane.org/gmane.linux.file-systems/35475
v2: http://thread.gmane.org/gmane.linux.nfs/30539
v3: http://thread.gmane.org/gmane.linux.nfs/30971

Since the last version, I've incorporated feedback to add a new top-level 
xattr namespace "nfsd", for storing client-origin xattrs on the server.  
Support for the new namespace has been implemented on ext3 for testing 
purposes.

Access to this namespace locally requires CAP_SYS_ADMIN, and it is not 
accessible over the wire.  Note that there is still potential for 
confusion between local and remote users, e.g.

$ setfattr -n user.foo -v bar file.txt

on an NFS mounted fs will create an xattr on the server called 
nfsd.user.foo, and then if the user logs in locally, they will not see the 
xattr at all.  Similarly, if they create xattrs locally, they will not be 
exported via XATTR.

Comments welcome.


- James
-- 
James Morris
<jmorris@namei.org>
