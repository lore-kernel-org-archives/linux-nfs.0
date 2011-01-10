Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42833 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463Ab1AJUy1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jan 2011 15:54:27 -0500
Received: by bwz15 with SMTP id 15so19514543bwz.19
        for <linux-nfs@vger.kernel.org>; Mon, 10 Jan 2011 12:54:26 -0800 (PST)
In-Reply-To: <201101101545.21890.shtylman@athenacr.com>
References: <201101101455.30608.shtylman@athenacr.com>
	<20110110153504.0379874a@tlielax.poochiereds.net>
	<201101101545.21890.shtylman@athenacr.com>
Date: Mon, 10 Jan 2011 15:54:26 -0500
Message-ID: <AANLkTikCthWySbmUeFCohpzZZpcPVVGxbHnQ-HL7Yfpm@mail.gmail.com>
Subject: Re: question about nfs4 with krb5 behavior
From: Kevin Coffman <kwc@citi.umich.edu>
To: Roman Shtylman <shtylman@athenacr.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jan 10, 2011 at 3:45 PM, Roman Shtylman <shtylman@athenacr.com> wrote:
>
> On Monday, January 10, 2011 03:35:04 pm Jeff Layton wrote:
>> On Mon, 10 Jan 2011 14:55:30 -0500
>>
>> Roman Shtylman <shtylman@athenacr.com> wrote:
>> > I have setup nfs4 with krb5 server and successfully mounted a client. Two
>> > people can log into the client box and both access their respective
>> > shares and not each other's. However, when one user (who lets say has
>> > root privs) uses root to become the second user (using su) then that
>> > user can now access the info of the user he became.
>> >
>> > I was under the impression that this should not be possible as the
>> > tickets for access should still be tied to the first user they logged in
>> > as. Is this true? Or do I have an error in my setup?
>> >
>> > Process:
>> > Login as user A
>> > (User B logs into the machine from another terminal)
>> > sudo su B (to become user B on the machine)
>> > <can now edit files which belong to B>
>>
>> That's correct, or is at least in accordance with the design. The
>> credcache is (usually) a file in /tmp. The kernel has to upcall to
>> userspace for that information. To do that, it passes along the uid of
>> the owner of the credcache. I think this is governed by the fsuid.
>>
>> When you "su" to another user, all of the uid's associated with the
>> process are changed (real, effective, fs and saved). So, the uid passed to
>> the upcall in this case is B's and not A's.
>>
>> This could potentially be "fixable" by moving the krb5 credcache into
>> the per-session keyring and then teach nfs to do keys API upcalls to get
>> the right blob. Not a trivial project, but it's doable. This is
>> something that would be nice for CIFS and maybe AFS too.
>
> AFS does not have this behavior.
>
> What is a best practice for handling this situation? Prevent "untrusted"
> machines from connecting to the nfs server? Basically any machine where a
> normal user can become root would be a potential problem?
>
> Thanks for the quick response.
>
> cheers,
> ~Roman

AFS uses a Process Authentication Group (PAG) to segregate use of
credentials in the kernel.  As far as I know, this doesn't prevent a
user with root access on the "untrusted" machine from impersonating
another user on the machine.  (They can simply copy any existing
kerberos credentials for use in their PAG.)  I think it does prevent
"accidental" use of the other user's credentials in this kind of
situation.
