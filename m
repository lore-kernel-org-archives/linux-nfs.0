From: "Phil Endecott" <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Wed, 29 Oct 2008 17:30:03 +0000
Message-ID: <1225301403729@dmwebmail.dmwebmail.chezphil.org>
References: <20081029171841.GC31936@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; format="flowed"
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from japan.chezphil.org ([77.240.5.4]:3493 "EHLO japan.chezphil.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841AbYJ2RaH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Oct 2008 13:30:07 -0400
Received: from localhost ([127.0.0.1] helo=chezphil.org)
	by japan.chezphil.org with esmtp (Exim 4.69)
	(envelope-from <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>)
	id 1KvErt-0003qe-2p
	for linux-nfs@vger.kernel.org; Wed, 29 Oct 2008 17:30:05 +0000
In-Reply-To: <20081029171841.GC31936@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Wed, Oct 29, 2008 at 12:13:20AM +0000, Phil Endecott wrote:
>> Dear Experts,
>> 
>> sm-notify was taking a long time while my laptop booted.  This was odd because I 
>> use NFS only rarely - via autofs - on that machine, and sm-notify actually has 
>> no-one to notify most of the time.  So I have patched it as follows.  Is this a 
>> legitimate thing to do?
>
> It looks like your patch was committed to nfs-utils a couple weeks ago:
> see c8d18e26d2a53d9036a32c2dafebccaf4ce1634d from
>
> 	git://linux-nfs.org/nfs-utils
>
> --b.

How curious.  I guess someone saw my Debian bug report.  No mention of 
it on this list as far as I can see though.

I presume from this that it is considered a safe thing to do.


Phil.



