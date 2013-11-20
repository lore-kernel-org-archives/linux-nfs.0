Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755205Ab3KTUtu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 15:49:50 -0500
Subject: Re: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to
 sync Kerberos credentials and kernel gss_contexts.
From: Simo Sorce <simo@redhat.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: "<steved@redhat.com>" <steved@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
In-Reply-To: <096F13FC-A99E-4C19-ACCA-01C244D7420F@netapp.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
	 <1382454148.9794.72.camel@willson.li.ssimo.org>
	 <A8A66580-CD6F-4141-AE93-B1DD025BFD7A@netapp.com>
	 <1382458162.9794.85.camel@willson.li.ssimo.org>
	 <9C15298B-8915-46E2-85E1-5098F1A12832@netapp.com>
	 <1382462720.9794.131.camel@willson.li.ssimo.org>
	 <096F13FC-A99E-4C19-ACCA-01C244D7420F@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Nov 2013 15:49:47 -0500
Message-ID: <1384980587.17044.49.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-11-20 at 20:35 +0000, Adamson, Andy wrote:
> Hi
> 
> As suggested, I approached the Kerberos@mit.edu about the possibility
> of a plugin architecture for libkrb5 credential cache manipulation
> functions so that we could trigger the kernel GSS_context management
> functions.

[..]
> 
> It appears that Solution 4: [plugin architecture to libkrb for
> callouts on functions that manipulate kerberos credentials.] is a
> no-go. 
> 
> I agree that Solution 1: [inotify on FILE credentials] is clunky and
> won't work well.
> 
> Solution 2: [integrate with KEYRING credentials] could work if we
> insist that all NFS Kerberos credentials use the KEYRING: - e.g. the
> proposed new 'big-key' type. Note there is no backporting of this
> solution.

Note that solution 2 is semantically identical to solution 4, you are
going to try to guess what user space is doing, based on how it
manipulates caches, and would have the same side effects.

> I think Solution 3: [nfslog/nfslogout interfaces invoked from PAM or
> other login system facility] is a good way to go.  Note that a PAM
> based solution where in the PAM would get us most of the way towards
> providing users with a way to login and logout of NFS kerberized
> shares.
> 
> Comments on an NFS PAM that will destroy GSS context for a UID upon
> logout?

I prefer 3 too, let it to the login system (whether PAM based or other)
to determine when it is time to destroy credentials, that's the only
component that have a chance of guessing right.
Of course you could also provide a user utility to force a purge.

> Simo - I answered your latest comments below in-line.

[..]

> I think a PAM based solution will get us most of the way there.

Agree.


> > So the way I see it you probably want to keep the tracking in
> > whatever tool you want to use to experiment (say gsskeyd) and only
> > provide a downcall to the kernel that will tell it: destroy any
> > cache for 'uid number (optionally pass in a session id too ?)'.
> 
> This is what the gss-ctx keyring destroy method is - a downcall to the
> kernel telling it to destroy all GSS_contexts for a UID.

Why do you need to abuse the keyring interface to implement a syscall ?
Or did I misunderstand what you mean by "telling the kernel to do X" ?

> > This way you can replace the logic of how to keep track of what is
> > going on completely in user space, where it can easily be adjusted
> > and adapted  as experience is gained.
> > 
> > IE: track it completely in userspace for now and only provide a
> > syscall to kill creds per UID, no tracking on the kernel side.
> 
> Yes - I believe that is what the gss-ctx keyring code I wrote does.

A keyring is not a syscall.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

