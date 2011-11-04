Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:48157 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285Ab1KDOn3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Nov 2011 10:43:29 -0400
Date: Fri, 4 Nov 2011 10:43:26 -0400
From: Jim Rees <rees@umich.edu>
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH (resend) Version 2 3/3] NFSv4.1: fix backchennel bug
Message-ID: <20111104144326.GA911@umich.edu>
References: <1318919979-14606-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1318919979-14606-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

You misspelled "backchannel" in the description.  Also could be a bit more
descriptive:

NFSv4.1: fix backchannel slotid off-by-one bug
