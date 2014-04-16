Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:29067 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbaDPAWr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Apr 2014 20:22:47 -0400
Message-ID: <534DCD52.5080202@RedHat.com>
Date: Tue, 15 Apr 2014 20:22:42 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Ben Greear <greearb@candelatech.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>
Subject: Re: Question on nfs-utils patch for 'keyctl_invalidate'.
References: <534C7B70.9000500@candelatech.com>
In-Reply-To: <534C7B70.9000500@candelatech.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/14/2014 08:21 PM, Ben Greear wrote:
> It seems that key_invalidate is only available in quite recent
> keyutils packages.
> 
> Anyone know if there is a relatively simple way to implement
> the same behaviour using older keyutils packages?
CC-ing the keyutils maintainer... David, when did that kernel 
change go in that cause keyctl_revoke() to no longer work?

The nfs-utils commit is:

commit 2ae0763a618d30037ebb2520f6292f80d838a440
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Mar 25 10:56:58 2014 -0400

    nfsidmap: Keys need to be invalidated instead of revoked

It sound like we need to do some type of #ifdef kernel version.... 

steved.

> 
> The reason I ask is that I recently updated to latest nfs-utils
> package and how build fails on many of my older systems...
> 
> Thanks,
> Ben
> 
