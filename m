From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Fri, 31 Oct 2008 13:52:22 -0400
Message-ID: <490B45D6.1060905@RedHat.com>
References: <20081029171841.GC31936@fieldses.org> <1225301403729@dmwebmail.dmwebmail.chezphil.org> <20081029173750.GD31936@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44722 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751150AbYJaRyM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Oct 2008 13:54:12 -0400
In-Reply-To: <20081029173750.GD31936@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



J. Bruce Fields wrote:
> On Wed, Oct 29, 2008 at 05:30:03PM +0000, Phil Endecott wrote:
>> J. Bruce Fields wrote:
>>> On Wed, Oct 29, 2008 at 12:13:20AM +0000, Phil Endecott wrote:
>>>> Dear Experts,
>>>>
>>>> sm-notify was taking a long time while my laptop booted.  This was 
>>>> odd because I use NFS only rarely - via autofs - on that machine, and 
>>>> sm-notify actually has no-one to notify most of the time.  So I have 
>>>> patched it as follows.  Is this a legitimate thing to do?
>>> It looks like your patch was committed to nfs-utils a couple weeks ago:
>>> see c8d18e26d2a53d9036a32c2dafebccaf4ce1634d from
>>>
>>> 	git://linux-nfs.org/nfs-utils
>>>
>>> --b.
>> How curious.  I guess someone saw my Debian bug report.  No mention of  
>> it on this list as far as I can see though.
>>
>> I presume from this that it is considered a safe thing to do.
> 
> It looks right to me.  Hopefully somebody actually has tested this on a
> client that holds locks when it reboots?
I did... things worked as expected....

steved.
