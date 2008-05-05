From: "Janne Karhunen" <janne.karhunen@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Mon, 5 May 2008 12:42:49 -0400
Message-ID: <24c1515f0805050942h26a0aaefi471216482fbabef5@mail.gmail.com>
References: <24c1515f0805021413u450d8bbcr806a90c327b287a1@mail.gmail.com>
	 <24c1515f0805021724q7dfe5294r702a9c8ffde01129@mail.gmail.com>
	 <20080505144538.GB8259@fieldses.org> <481F20B6.8080603@gmail.com>
	 <24c1515f0805050801m66cce68k94073914ba26511e@mail.gmail.com>
	 <481F2600.20501@gmail.com>
	 <24c1515f0805050823s14f4caf7s3a4ff06a70c220be@mail.gmail.com>
	 <20080505152519.GE8259@fieldses.org>
	 <24c1515f0805050828o3aa5b33aod2a6e4e0b5b6c9dc@mail.gmail.com>
	 <20080505155858.GF8259@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Wendy Cheng" <s.wendy.cheng@gmail.com>,
	"Peter Staubach" <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:15885 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754915AbYEEQmu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 May 2008 12:42:50 -0400
Received: by wa-out-1112.google.com with SMTP id j37so789849waf.23
        for <linux-nfs@vger.kernel.org>; Mon, 05 May 2008 09:42:49 -0700 (PDT)
In-Reply-To: <20080505155858.GF8259@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 5, 2008 at 11:58 AM, J. Bruce Fields <bfields@fieldses.org> wrote:

>  > So the let the user worry approach. Statd does not
>  > notify anyone and user is supposed to do it with
>  > sm-notify manually.
>
>  We should modify distro startup scripts to run sm-notify and add -L to
>  statd, following the recommendations in nfs-utils/README.
>
>  That will leave the -v option to sm-notify, which will need to be added
>  somehow to handle the highly-available-nfs case.

Humm ... imho this does not add anything to current
1.1.* tree. Exactly same things happen when -n is
being used.


>  > This will work, but -n looks cleaner me..
>
>  I've lost the thread here a little.  Let me try to summarize, and tell
>  me what I've forgotten:
>
>  So we've got multiple nfs servers that may serve the same export.  Only
>  one serves a given export at a time.
>
>  To keep the clients from having to understand this, we tell them to
>  mount a single "floating" ip address, and when we want to use a
>  different server, we move that floating ip address, and the clients
>  automatically follow it.  The only problem is that the new server
>  doesn't know about locks held on the old server.  We solve that problem
>  by telling clients that the server has rebooted, and that they must
>  reclaim locks.
>
>  To make that work, we need to ensure that statd notifies the clients
>  that "floating-ip" has rebooted.  (They will get confused if they are
>  notified that "some-other-ip" has rebooted, where "some-other-ip" is
>  just some random ip that the new server happens to use on a different
>  interface.)

Exactly right.


>  The statd -n option has actually *never* worked, in any previous version
>  of nfs-utils--with it specified, statd can no longer communicate with
>  the nfs server on the same host.  That means the server won't find out
>  when a client reboots.  (But I guess even the broken -n may still have
>  been sufficient to allow clients to monitor the server and find out when
>  the server reboots.)

-n may work as is in 1.1.* tree:

a) It will bind to ANY, so kernel lockd will see packets coming
in from LO. 1.0.x bound the -n interface which will break.

b) sm-notify is run with -v and correct name (that will bind to
correct IP and use the right name)

So the only thing missing would be to limit the port visibility
of long-standing sockets; but this should probably be
discussed in another thread if you think it's worth it?


-- 
// Janne
