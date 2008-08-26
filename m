From: Chuck Lever <chuck.lever@oracle.com>
Subject: RESTRICTED_STATD
Date: Tue, 26 Aug 2008 16:41:21 -0400
Message-ID: <6972A199-D332-4E74-9D47-70EC2CA381FE@oracle.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>, Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:54702 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbYHZUmn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Aug 2008 16:42:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi guys-

I was wondering if anyone ever builds nfs-utils with RESTRICTED_STATD  
undefined these days.  It seems totally insecure to do.  Is it still  
necessary to keep this?

It would be easier to understand, update, and test the logic in utils/ 
statd/monitor.c (IPv6-wise) if we could remove the unused parts of  
this code.

I propose removing RESTRICTED_STATD, leaving in the secure version of  
the code permanently and removing the insecure parts that are left out  
when RESTRICTED_STATD is undefined.

Thoughts?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
