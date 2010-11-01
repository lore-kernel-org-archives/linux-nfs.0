Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from tokyo.v-ss.at ([83.169.21.118]:54090 "EHLO tokyo.v-ss.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757113Ab0KAPRq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Nov 2010 11:17:46 -0400
Received: from [192.168.0.102] (unknown [91.129.45.182])
	(Authenticated sender: michael@mseiwald.at)
	by tokyo.v-ss.at (Postfix) with ESMTP id 7736B4690376
	for <linux-nfs@vger.kernel.org>; Mon,  1 Nov 2010 14:59:36 +0000 (UTC)
Message-ID: <4CCED5D7.6060703@mseiwald.at>
Date: Mon, 01 Nov 2010 15:59:35 +0100
From: Michael Seiwald <michael@mseiwald.at>
To: linux-nfs@vger.kernel.org
Subject: nfs4-acl-editor does not compile
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello everybody,

when trying to compile the GUI ACL editor [1] I got the following 
compile error:

nfs4acleditor.cpp: In member function ‘void 
NFS4_ACL_Editor::syncWho(nfs4_ace*, const char*)’:
nfs4acleditor.cpp:572:48: error: ‘strlcpy’ was not declared in this scope

I just replaced strlcpy with strncpy and now it compiles and runs fine. 
But I wonder what's the matter with this 'strlcpy' function and if my 
fix doesn't have any bad side effects.

Thanks in advance

Michael

[1] 
http://www.citi.umich.edu/projects/nfsv4/linux/nfs4-acl-tools/nfs4-acl-tools-0.3.3.tar.gz
