Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.mail.umich.edu ([141.211.14.82]:54729 "EHLO
	hellskitchen.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756826Ab1JDMUZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 08:20:25 -0400
Date: Tue, 4 Oct 2011 08:20:19 -0400
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>, Brent Welch <welch@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: Re: [PATCH 16/19] pnfs-obj: Rename objlayout_io_state =>
 objlayout_io_res
Message-ID: <20111004122019.GA2946@umich.edu>
References: <4E8ADEDA.4050709@panasas.com>
 <1317724560-27795-1-git-send-email-bharrosh@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1317724560-27795-1-git-send-email-bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Boaz Harrosh wrote:

  * All instances of objlayout_io_state => objlayout_io_res
  * All instances of state => oir;
  * All instances of ol_state => oir;
  
  Big but nothing to it
  
  Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>

You have trailing whitespace here:

  + * objlayout_{read,write}_done 
