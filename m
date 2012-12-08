Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:61769 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757465Ab2LHBYd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Dec 2012 20:24:33 -0500
Date: Fri, 7 Dec 2012 20:24:27 -0500
From: Jim Rees <rees@umich.edu>
To: Marc Eshel <eshel@us.ibm.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: notify_deviceid_type4
Message-ID: <20121208012427.GA11565@umich.edu>
References: <OFF752FE87.86716271-ON88257AC7.002025E3-88257AC7.00206C04@LocalDomain>
 <OF13B342CA.3B3F39AC-ON88257ACD.0080BC4F-88257ACD.00815B0B@us.ibm.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA90B33D909@SACEXCMBX04-PRD.hq.netapp.com>
 <OF0F29D082.A262ED54-ON88257ACE.0000B379-88257ACE.0000F121@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF0F29D082.A262ED54-ON88257ACE.0000B379-88257ACE.0000F121@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Marc Eshel wrote:

  commit 1013e2ea88384da2e7326f40047bbc92deb9e516
  Author: Marc Eshel <eshel@almaden.ibm.com>
  Date:   Fri Dec 7 15:58:07 2012 -0800
  
  Change definition of notify_deviceid_type4 to correspond to the NFSv4.1 
  spec.

Doesn't apply for me:

% git am ~/Mail/tmp/89
Applying: RE: notify_deviceid_type4
fatal: corrupt patch at line 9
Patch failed at 0001 RE: notify_deviceid_type4
When you have resolved this problem run "git am --resolved".
If you would prefer to skip this patch, instead run "git am --skip".
To restore the original branch and stop patching run "git am --abort".
