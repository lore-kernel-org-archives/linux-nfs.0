Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp1.uvm.edu ([132.198.101.168]:55285 "EHLO smtp1.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752499AbaCYMt0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Mar 2014 08:49:26 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] nfsidmap: use multiple child keyrings
From: Benjamin Coddington <bcodding@uvm.edu>
In-Reply-To: <21552.1395740102@warthog.procyon.org.uk>
Date: Tue, 25 Mar 2014 08:49:19 -0400
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <D3F70C86-3EE3-4024-831F-400141B0DB4A@uvm.edu>
References: <ECEE9807-64C6-4B8A-92C5-9F2031800992@uvm.edu> <201403241150.s2OBonLC010685@hobo-dev.uvm.edu> <533064A1.2080502@RedHat.com> <189016FB-E865-42B7-BF5A-D1D12F45B81E@uvm.edu> <53308CD4.9020307@RedHat.com> <5330C65B.6010904@RedHat.com> <21552.1395740102@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm dealing with a bunch of RHEL6 boxes - so the RHEL kernel versions: 2.6.32-431..  I can't just update all these machines to later kernels, unfortunately.  This nfsidmap fix is just a stop-gap, since it seemed easier to get Steve D to update nfs-utils than to backport the keyring stuff, and when I suggested this method in the BZ I was instructed to bring it to the list.

I regret all this RHEL-specific noise on this list; apologies.

Ben

On Mar 25, 2014, at 5:35 AM, David Howells <dhowells@redhat.com> wrote:

> 
> What kernel are you dealing with?
> 
> David
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

