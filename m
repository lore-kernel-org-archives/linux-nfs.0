Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21218 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751622Ab2K0OYA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 09:24:00 -0500
Message-ID: <50B4CCFD.6010900@RedHat.com>
Date: Tue, 27 Nov 2012 09:23:57 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Revert "mountd: handle allocation failures in auth_unix_ip
 upcall"
References: <20121126220343.GA18140@fieldses.org> <73EFE585-98D4-40BE-9EDF-15CC6B14BDB2@oracle.com> <20121126221535.GB18186@fieldses.org> <A954A569-E030-4119-A349-6CB888979738@oracle.com> <20121126225116.GE18186@fieldses.org>
In-Reply-To: <20121126225116.GE18186@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

On 26/11/12 17:51, J. Bruce Fields wrote:
>> What exactly is the problem with the current code?
>> > 
>> > client_resolve() can return a NULL in some cases.  Why is it OK to
>> > pass a NULL "ai" to client_compose() ?  Looks like that can result in
>> > a mountd segfault.
> Bah, I thought I'd checked this and found it was prepared to handle
> that, but no:
> 
> 	client_check->check_wildcard()
> 
> looks like it can oops.
Yeah... added client_check->check_netgroup() to this list...

> 
> OK, I'll take another look.
A simply check that ai is not null when calling client_compose() should work..

> 
>> > The kernel won't get any downcall reply in that
>> > case!  Is that what you are trying to fix?
>> > 
>> > WRT my original objection: In general I don't see how to make it
>> > impossible for mountd to fail.
> Sure, but mountd is required for the server to function, so it's just a
> question of how we fail.
> 
>> > Thus the kernel needs to be better about recovering when mountd
>> > suddenly disappears.
> Currently it drops and lets the client retry.  I suspect that's the
> correct thing to do, but alternatives are welcomed.
This one things I didn't see happen... the client retrying... expected it would...

steved.
