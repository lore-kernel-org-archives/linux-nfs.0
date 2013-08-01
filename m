Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43728 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754897Ab3HATKZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 Aug 2013 15:10:25 -0400
Subject: Re: [PATCH 2/2] KEYS: Add per-user_namespace registers for
 persistent per-UID kerberos caches
From: Simo Sorce <simo@redhat.com>
To: Daniel Kahn Gillmor <dkg@fifthhorseman.net>
Cc: David Howells <dhowells@redhat.com>, keyrings@linux-nfs.org,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, linux-nfs@vger.kernel.org,
        krbdev@mit.edu, linux-kernel@vger.kernel.org
In-Reply-To: <51FAAF3D.3010806@fifthhorseman.net>
References: <20130801173846.28023.19009.stgit@warthog.procyon.org.uk>
	 <20130801173902.28023.68819.stgit@warthog.procyon.org.uk>
	 <51FAA0CC.7010106@fifthhorseman.net>
	 <1375381798.15733.207.camel@willson.li.ssimo.org>
	 <51FAAF3D.3010806@fifthhorseman.net>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 01 Aug 2013 15:10:16 -0400
Message-ID: <1375384216.15733.210.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2013-08-01 at 14:55 -0400, Daniel Kahn Gillmor wrote:
> On 08/01/2013 02:29 PM, Simo Sorce wrote:
> 
> > It's called 'abstraction' :-)
> 
> Good, I like abstraction :)
> 
> >> It seems like a non-privileged user could use this to store arbitrary
> >> data in this keyring as a way of hiding what would otherwise be
> >> filesystem activity or using it for some sort of odd/sneaky IPC
> >> mechanism.  Is this an intentional side effect?
> > 
> > Just as a user can add data into a shm segment ?
> > Is there any difference ?
> 
> I guess this raises the question from a different perspective: if the
> kernel already supports arbitrary shm segments, filesystem locations,
> etc, which can be used for storing/passing opaque bytestrings between
> different parts of userspace, what advantages do we gain from having
> this new specific mechanism in the kernel?  Why couldn't those parts of
> userspace just rely on already-existing mechanisms instead of
> introducing this new interface?
> 
> Again, i'm not trying to say it's a bad idea; there's probably a
> big-picture piece of the puzzle that i don't see that makes this all
> obvious.  i just want to understand what it is.  Thanks for your
> explanations!

A few things deal with creation of the keyring and access control,
automatic garbage collection and in future the fact this data will not
leak in an intelligible form to disc (once we add the encryption bit to
the big_key type). Avoidance of naming collision and so on.
There is probably something else I am forgetting now.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

