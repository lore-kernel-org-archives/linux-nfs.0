Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy01.merit.edu ([207.75.116.193]:51438 "EHLO
	merit-proxy01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754155Ab1IQOwT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 17 Sep 2011 10:52:19 -0400
Date: Sat, 17 Sep 2011 10:52:17 -0400
From: Jim Rees <rees@umich.edu>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
Subject: Re: [PATCH] nfs-utils/blkmapd: Add complex block layout discovery
 and mapping daemon
Message-ID: <20110917145217.GA15540@merit.edu>
References: <1313086848-7435-1-git-send-email-rees@umich.edu>
 <4E749FBC.5090609@RedHat.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E749FBC.5090609@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Steve Dickson wrote:

  So I will make the enable_nfsv41 ==> enable_nfsdv41 change in 
  the next rc release, alone with some other outstanding changes.
  After that rc release, I'll commit this code and then make a minor 
  release, 1.2.5, that will have this code on by default.
  
  Sound reasonable?

Sounds good to me.  About when could I expect to see 1.2.5 with blkmapd?
