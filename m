Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:33800 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753584Ab2BPRaZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2012 12:30:25 -0500
Date: Thu, 16 Feb 2012 12:30:22 -0500
From: Jim Rees <rees@umich.edu>
To: Weston Andros Adamson <dros@netapp.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFSv4: Send implementation id with exchange_id
Message-ID: <20120216173022.GA29158@umich.edu>
References: <1329409026-20466-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1329409026-20466-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Weston Andros Adamson wrote:

  Send the nfs implementation id in EXCHANGE_ID requests unless the module
  parameter nfs.send_implementation_id is 0.
  
  This adds a CONFIG variable for the nii_domain that defaults to "kernel.org".
  
  Signed-off-by: Weston Andros Adamson <dros@netapp.com>

  @@ -271,7 +273,12 @@ static int nfs4_stat_to_errno(int);
   				1 /* flags */ + \
   				1 /* spa_how */ + \
   				0 /* SP4_NONE (for now) */ + \
  -				1 /* zero implemetation id array */)
  +				1 /* implemetation id array of size 1 */ + \

implemetation -> implementation
Might as well fix this typo while you're at it.

General comment... If this is going to be configurable, I'd rather make it a
sysctl, and be able to set the id to whatever I want at run time.  But
that's because I like to be able to break things.  I suspect Trond will
disagree.
