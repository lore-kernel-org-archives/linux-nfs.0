Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:8278 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751925Ab2AZSc3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 13:32:29 -0500
From: Weston Andros Adamson <dros@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: 
Date: Thu, 26 Jan 2012 13:32:21 -0500
Message-Id: <1327602743-1152-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


End users probably find it confusing to see messages from the nfs subsystem
that aren't labeled as such.  These patches modify all printks (not d*printks)
to start with "NFS:"

I separated this in to two patches:

  - printks that obvisouly need this as they have no context to inform a user 
    that the message is related to NFS

  - printks that do have some context (such as printing __func__), but are 
    changed to start with "NFS:" for consistency
