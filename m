From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] make capabilities support optional
Date: Mon, 26 Apr 2010 12:54:36 -0400
Message-ID: <4BD5C54C.60705@RedHat.com>
References: <1271753213-17374-1-git-send-email-vapier@gentoo.org> <4BD5B013.9060705@oracle.com> <4BD5BAD8.5040209@RedHat.com> <201004261251.12210.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43703 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543Ab0DZQym (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Apr 2010 12:54:42 -0400
In-Reply-To: <201004261251.12210.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/26/2010 12:51 PM, Mike Frysinger wrote:
> On Monday 26 April 2010 12:10:00 Steve Dickson wrote:
>> On 04/26/2010 11:24 AM, Chuck Lever wrote:
>>> At the very least, I think the man page should mention this bug somehow,
>>> and maybe a warning should be generated during the build.  Since this is
>>> mostly for embedded systems, according to Mike, I doubt an actual
>>> generated run-time warning would be visible to anyone.
>>
>> Mike would you be willing to test this out and document any
>> differences in statd behaviour with and without that config
>> flag set?
> 
> i think a BUGS section in statd is sufficient, but if you wanted to go 
> further, then a simple syslog() would be OK as well.  dumping warnings to 
> stderr/stdout is obnoxious and non-standard for daemons.  those really only 
> should be written when a daemon is quitting due to misconfiguration.
I agree... a blurb in the BUGS section is all that is needed..
> 
> i can send a patch for the man page, but i'd only copy and paste what Chuck 
> wrote (about statd remaining registered upon exit).
That would be good... thanks!

steved.
