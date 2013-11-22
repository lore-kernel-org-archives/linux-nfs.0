Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aa.linuxbox.com ([69.128.83.226]:1689 "EHLO aa.linuxbox.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755635Ab3KVWOX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Nov 2013 17:14:23 -0500
Date: Fri, 22 Nov 2013 17:13:54 -0500
From: mdw@linuxbox.com
To: Tim Rafert <tim.rafert@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: ACL and NFSv4 expectations
Message-ID: <20131122221354.GA28920@soma.private.linuxbox.com>
References: <931f1e06-eca3-4f12-ad8a-99a93442409a@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <931f1e06-eca3-4f12-ad8a-99a93442409a@default>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I can't pretend to be familiar with solaris acls, but I have looked at
the linux client while implementing partial acl support in ganesha.
Following are my answers based on that:

> On Fri, Nov 22, 2013 at 11:34:04AM -0800, Tim Rafert wrote:
> > Looking for assistance if the following are REAL issues or expected behavior using NFSv4 ACL (on linux ol6 and interoperating with solaris).  Thanks in advance.
> > 
> > 1) Is there a max # of entries that can be stored in an ACL?  If so - what is it (or is dependent on the device)?

I don't see any mention of maximum in rfc5661.  I'm pretty sure this should
be "device dependent", with some vague notion of "slightly unreasonably large".

> > 
> > 2) Is it up to my own implementation instead of the "NFS Client" on the OS to try and keep the ACLs clean/organized/etc?  See my next question for further clarification

I belive it's mostly an application/user responsibility to keep the acl clean.
If the NFS acl is set indirectly, then whatever does that could change stuff.
There's some complicated wording about trying to preserve as much of what
the user sets as possible (such as permitting things to "BATCH@") while
not pretending to do anything one can't do.  Most of the excuses to do
something indirectly with the acl have to do with posix acls or unix mode bits.

> > 
> > 3) If a user adds the same ACE into an ACL multiple times - then it is actually added multiple times?  For example:

Should be.  Or at least I wouldn't think the server should be attempting
to do this gratuitously.  Certainly any change that changes the semantics of
the list is bad.  I believe if you have only 'allow' entries, you can in fact
reorder without changing the semantics, but as soon as there's any 'deny'
entries, it gets messy.

> > 
> > 4) ACL "caching" - it appears that if from one client-host - a user alters the ACL and then from another client-host - a user also alters the ACL - then one of the alterations can be lost (if they are within a minute or some cache timeframe).  For example:

I have seen weird stuff with caching and acls.  In my case I traced
most of it down to bad server logic, but I certainly believe the linux
client can report something different than what's actually on the server.
If the server is rewriting acls, that certainly sounds like it could
cause visible caching artifacts.  Another complication is that the linux
userland nfs4 tool sometimes hides bits, so what you set and what's stored and
returned, is not in fact what you see.

...

						-Marcus Watts
