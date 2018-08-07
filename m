Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45232 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726428AbeHGWu3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Aug 2018 18:50:29 -0400
Date: Tue, 7 Aug 2018 16:34:19 -0400
To: Cedric Blancher <cedric.blancher@gmail.com>
Cc: Peter Scott <pjscott@jpl.nasa.gov>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: NFSv4 file lock reporting interface request
Message-ID: <20180807203419.GB18415@fieldses.org>
References: <8dd8a352-aaca-71af-aca7-9be6c7039ff4@jpl.nasa.gov>
 <CALXu0UdHWGOnMYk-xGG6_GWGfdpXffc0U-+Ark0joEYvhPSh_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CALXu0UdHWGOnMYk-xGG6_GWGfdpXffc0U-+Ark0joEYvhPSh_g@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 02, 2018 at 08:50:20PM +0200, Cedric Blancher wrote:
> Solaris and FreeBSD dtrace facility supports this functionality.
> Unfortunately, Linux rejected dtrace for license issues, and instead
> did... nothing.

I didn't think was this sort of question tracing was designed to
answer--it's a question about the system state at a given time (who
holds what locks), rather than a list of events.  But I know nothing
about dtrace.

--b.

> 
> Ced
> 
> On 10 July 2018 at 04:28, Peter Scott <pjscott@jpl.nasa.gov> wrote:
> > Hello.  I am with the institutional hosting service at NASA's Jet Propulsion
> > Laboratory and we have been trying to find the answer to an apparently
> > simple question.
> >
> > We are running an NFSv4 server on Centos 7 and we need to get the server to
> > tell us which files it thinks are locked by which clients.  This is because
> > we have observed failure modes where something apparently has a lock
> > (because attempting to lock the file again blocks) but we can't find a
> > client that has the lock. Finding out what the server believes would be
> > critical to troubleshooting this.
> >
> > We tracked down Trond Myklebust and Neil Brown and conversation suggests
> > that this is a function that is (a) not currently available and (b)
> > reasonable to ask for.  So this is me suggesting that an interface be
> > provided to have knfsd output its list of locked files and clients.
> >
> > Regards,
> > Peter Scott
> > Office of the CIO
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
> 
> -- 
> Cedric Blancher <cedric.blancher@gmail.com>
> [https://plus.google.com/u/0/+CedricBlancher/]
> Institute Pasteur
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
