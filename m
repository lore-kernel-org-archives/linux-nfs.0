Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31457 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755543Ab2CHOEV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Mar 2012 09:04:21 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: dan.carpenter@oracle.com, linux-nfs@vger.kernel.org
Subject: [PATCH V2] NFSv4.1 handle DS stateid errors 
Date: Wed,  7 Mar 2012 18:44:32 -0500
Message-Id: <1331163873-2306-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Thanks for the review Dan. The DS COMMIT can be called with a NULL state.
Fix the "variable dereferenced before check" reported by Smatch.

-->Andy
