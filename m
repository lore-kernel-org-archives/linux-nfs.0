Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:55325 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090Ab1LYP6M (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 25 Dec 2011 10:58:12 -0500
Date: Sun, 25 Dec 2011 10:57:55 -0500
From: Jim Rees <rees@umich.edu>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@tonian.com>,
        fanchaoting <fanchaoting@cn.fujitsu.com>,
        Benny Halevy <benny@tonian.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fix do_xor_speed 64-bit devision issue on 32-bits arch
Message-ID: <20111225155755.GB19792@umich.edu>
References: <1323266927-3686-1-git-send-email-bhalevy@tonian.com>
 <4EF422A8.5070907@cn.fujitsu.com>
 <20111223132546.GA10015@umich.edu>
 <4EF6B516.5070609@tonian.com>
 <4EF74056.2040306@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4EF74056.2040306@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:

  Please trash this patch for now. I will carry it out of tree for my use.
  (Looks I'm the only one who's using UML and the XOR engine)

UML would explain it.  Regular kernels should be ok.
