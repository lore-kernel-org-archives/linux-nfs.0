Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45263 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754678Ab1AJUsa convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Jan 2011 15:48:30 -0500
Received: by bwz15 with SMTP id 15so19509050bwz.19
        for <linux-nfs@vger.kernel.org>; Mon, 10 Jan 2011 12:48:29 -0800 (PST)
In-Reply-To: <201101101455.30608.shtylman@athenacr.com>
References: <201101101455.30608.shtylman@athenacr.com>
Date: Mon, 10 Jan 2011 15:48:29 -0500
Message-ID: <AANLkTi=aNht6s4qzkhBbOzPJUywmToeWNJDhsdyRXBzE@mail.gmail.com>
Subject: Re: question about nfs4 with krb5 behavior
From: Kevin Coffman <kwc@citi.umich.edu>
To: Roman Shtylman <shtylman@athenacr.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jan 10, 2011 at 2:55 PM, Roman Shtylman <shtylman@athenacr.com> wrote:
> I have setup nfs4 with krb5 server and successfully mounted a client. Two
> people can log into the client box and both access their respective shares and
> not each other's. However, when one user (who lets say has root privs) uses
> root to become the second user (using su) then that user can now access the
> info of the user he became.
>
> I was under the impression that this should not be possible as the tickets for
> access should still be tied to the first user they logged in as. Is this true?
> Or do I have an error in my setup?
>
> Process:
> Login as user A
> (User B logs into the machine from another terminal)
> sudo su B (to become user B on the machine)
> <can now edit files which belong to B>

User A is now "user B" and has access to the Kerberos credentials
created by user B when they logged in.  Even if user B logged out and
deleted their kerberos credentials before user A did the "sudo su B",
if user B had already accessed NFS, a kernel gss context with the
server would have been created.  That will still be available and
usable when user A becomes user B, until it expires.

> If User B does not login before user A becomes user B, user A is not able to
> edit user B's files even after he becomes user B.

In this case, user B had not previously created Kerberos credentials.

> Kernel version: 2.6.32-24
>
> any clarification on behavior would be appreciated.
>
> cheers,
> ~Roman
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
