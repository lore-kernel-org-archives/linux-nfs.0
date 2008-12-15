From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 0/3] nfs-utils: Enabling TCP wrappers
Date: Mon, 15 Dec 2008 11:54:31 -0500
Message-ID: <49468BC7.2000907@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38790 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754685AbYLOQ4n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Dec 2008 11:56:43 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mBFGuhPF005242
	for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2008 11:56:43 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mBFGugbd005871
	for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2008 11:56:42 -0500
Received: from [10.16.60.47] (xenhat.boston.devel.redhat.com [10.16.60.47])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id mBFGuffD022397
	for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2008 11:56:42 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently I was asked to re-enable the TCP wrapper calls, that check the
validity of client that communicate with mountd and statd.

It became very apparent this code had not been used in a while
and was as a bit broken. So this patch set fixes the logic and 
tries to make the code scale better. 

The commit blobs in the set are relative to the 'tcpwrap'
branch in the git://linux-nfs.org/~steved/nfs-utils-exp.git
git tree.

Comments?

steved.
