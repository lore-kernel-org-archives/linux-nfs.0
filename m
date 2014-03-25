Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp2.uvm.edu ([132.198.101.169]:43895 "EHLO smtp2.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752070AbaCYM4N convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Mar 2014 08:56:13 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: [PATCH] nfsidmap: use multiple child keyrings
From: Benjamin Coddington <bcodding@uvm.edu>
In-Reply-To: <21532.1395740051@warthog.procyon.org.uk>
Date: Tue, 25 Mar 2014 08:56:07 -0400
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <8D885171-9D19-4E78-BC2F-D5AC906D7A3B@uvm.edu>
References: <53308CD4.9020307@RedHat.com> <201403241150.s2OBonLC010685@hobo-dev.uvm.edu> <533064A1.2080502@RedHat.com> <189016FB-E865-42B7-BF5A-D1D12F45B81E@uvm.edu> <21532.1395740051@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar 25, 2014, at 5:34 AM, David Howells <dhowells@redhat.com> wrote:
> Steve Dickson <SteveD@redhat.com> wrote:
> 
>>>>> The kernel keyring has a max of ~508 entries on 64-bit systems.
>>>>> For installations with more distict users than this limit, create
>>>>> a specified number of child keyrings and fill them evenly.
> 
> This got fixed recently.
> 
> 	Commit b2a4df200d570b2c33a57e1ebfa5896e4bc81b69
> 	Author: David Howells <dhowells@redhat.com>  2013-09-24 10:35:18
> 	Subject: KEYS: Expand the capacity of a keyring
> 
> With that, the capacity is more or less infinite.

Yep, I'm aware of that - but unless RH backports this fix (which I was told is not going to happen) or uses this multiple keyring nfsidmap approach, things are going to stay broken in RHEL6.

Ben