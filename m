From: Chuck Lever <chuck.lever@oracle.com>
Subject: whither bindresvport6() ?
Date: Thu, 17 Jan 2008 15:02:08 -0500
Message-ID: <8E814A5D-6806-49CB-9C56-CC398847F5E1@oracle.com>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
To: NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:32417 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbYAQUCb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jan 2008 15:02:31 -0500
Received: from rgmgw2.us.oracle.com (rgmgw2.us.oracle.com [138.1.186.111])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m0HK2PJd009237
	for <linux-nfs@vger.kernel.org>; Thu, 17 Jan 2008 14:02:26 -0600
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by rgmgw2.us.oracle.com (Switch-3.2.4/Switch-3.2.4) with ESMTP id m0HK2ONC029415
	for <linux-nfs@vger.kernel.org>; Thu, 17 Jan 2008 13:02:24 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm filling in the IPv6 blanks in the mount command, and have run  
into a little problem.  netinet/in.h suggests I need to use  
bindresvport6() for IPv6 addresses, but it doesn't appear in the  
standard libraries on Fedora 7.

Anyone happen to know where this function resides in a late model glibc?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



