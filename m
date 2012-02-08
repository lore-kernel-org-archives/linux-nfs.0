Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:59687 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755399Ab2BHRtH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Feb 2012 12:49:07 -0500
Date: Wed, 8 Feb 2012 12:49:01 -0500
From: Jim Rees <rees@umich.edu>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [RFC PATCH 1/2] NFSv4.1: Convert slotid from u8 to u32
Message-ID: <20120208174901.GA28564@umich.edu>
References: <1328576237-7362-1-git-send-email-Trond.Myklebust@netapp.com>
 <20120208162322.GA13315@fieldses.org>
 <1328722042.3234.13.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1328722042.3234.13.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond wrote:

  10GigE + high latencies is exactly where we're seeing the value. Andy
  has been working with the high energy physics community doing NFS
  traffic between the US and CERN...

CITI to CERN is just over 120ms.  I don't know what it would be from Andy's
house.  Does he have 10G at home yet?
