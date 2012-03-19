Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:40316 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161687Ab2CSQ3m (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 12:29:42 -0400
Date: Mon, 19 Mar 2012 12:29:43 -0400
From: Jim Rees <rees@umich.edu>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: _nfs_display_fhandle_hash: undefined reference to `crc32_le'
Message-ID: <20120319162943.GA19160@umich.edu>
References: <20120318181304.GA2095@windriver.com>
 <194578ED-EA46-479D-A61A-08D1A92FF80C@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <194578ED-EA46-479D-A61A-08D1A92FF80C@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adamson, Dros wrote:

  Oops!  The fix is ok, in that it will work, but I'm not sure we want to
  pull in that type of dependency for a debug message.

crc32 isn't that much of a burden.  I'm surprised it's even optional.  Your
proposed fix gives a useless hash and will result in confusion.  I say pull
in crc32.
