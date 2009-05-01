From: andros@netapp.com
Subject: [PATCH 0/1] NFSD Fix for 2.6.30
Date: Fri,  1 May 2009 11:33:52 -0400
Message-ID: <1241192033-4493-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:50366 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755513AbZEAPdz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 1 May 2009 11:33:55 -0400
In-Reply-To: <>
References: <>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce

Please add this patch to the 2.6.30 rc fixes. It prevents an oops on nfsd shutdown.

0001-nfsd41-slots-are-freed-with-session.patch

Thanks

-->Andy

