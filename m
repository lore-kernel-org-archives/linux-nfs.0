From: Chuck Lever <chuck.lever@oracle.com>
Subject: "sync" mount option semantics
Date: Tue, 4 Mar 2008 18:15:25 -0500
Message-ID: <9DC7FC7A-41B0-43C6-9759-8DF253C47EEE@oracle.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:19969 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934431AbYCDXPu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2008 18:15:50 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

I have kind of an academic question.

When an NFS file system is mounted with the "sync" option, only  
writes via sys_write appear to be affected.  Writes via mmap or pages  
dirtied via a loopback device are not affected at all.

Similarly, O_SYNC only appears to affect sys_write and not mmap or  
loopback.

Is this the desired behavior?  If so, why not include cached writes?   
Should we document this in nfs(5)?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
