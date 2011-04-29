Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51057 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838Ab1D2PHz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Apr 2011 11:07:55 -0400
Received: by wya21 with SMTP id 21so2911042wya.19
        for <linux-nfs@vger.kernel.org>; Fri, 29 Apr 2011 08:07:54 -0700 (PDT)
Message-Id: <D158BE8E-BEDC-43EF-9C6C-48668AA6F5DF@gmail.com>
From: David McGiven <davidmcgivenn@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Linux to Netapp -> Is UDP over WAN safe as long as I use "sync, hard and intr" ?
Date: Fri, 29 Apr 2011 17:07:44 +0200
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Dear All,

I'm having problems with Linux NFS clients accessing a NetApp NFS  
server. The problems are mostly because it's a WAN connection (with 3  
hops in between). There's a mixture of poor WAN performance and Ubuntu  
kernel bugs regarding NFS locks. I've been struggling with this for  
too long. I then tried UDP instead of TCP and all the problem seem to  
have vanished :

I get better performance.
I don't get lock errors and stalled connections in the kernel.
I don't get nfs server xxx.xxx.xx not responding any more.

So I guess I will use UDP, no matter if TCP is recommended in terms of  
performance. Also, I can't control the WAN routers and switches so I'm  
tied up to that.

My concerns are, is it OK to use UDP over WAN regarding data  
corruption ? I've read that UDP over WAN can cause it, and I'm a  
little bit afraid, although I don't know why would it corrupt data if  
it's "sync,hard,intr" as the mount options.

What do you think ?

Thanks in advance.

--
David McGiven
Associate Researcher
Universitat Autonoma de Barcelona
davidmcgivenn@gmail.com



