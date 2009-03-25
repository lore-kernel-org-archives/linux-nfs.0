Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37364 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863AbZCYSzz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Mar 2009 14:55:55 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n2PItrgN032121
	for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2009 14:55:53 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n2PItlMx028553
	for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2009 14:55:47 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-42.bos.redhat.com [10.16.10.42])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n2PItq2Z016492
	for <linux-nfs@vger.kernel.org>; Wed, 25 Mar 2009 14:55:53 -0400
Message-ID: <49CA7D93.9050608@RedHat.com>
Date: Wed, 25 Mar 2009 14:53:07 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Making crossmnt a default export option
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

What would be the ramifications of turning on the crossmnt
option on by default? Currently the the default is nocrossmnt.

In my recent work with pseudo exports, it has become very apparent
that having the crossmnt always set, especially with multi file
system exports, allows mount to "just work"!

So historically what is the reason for not allowing the clients
to always cross file systems? Is it a security issue? 
And again, what would be the ramifications always allowing, by
default, clients to cross file systems?

steved.
     
