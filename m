Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:51443 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753200Ab3JUOZF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Oct 2013 10:25:05 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id B4114280334
	for <linux-nfs@vger.kernel.org>; Mon, 21 Oct 2013 16:25:03 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id A6E7D1046
	for <linux-nfs@vger.kernel.org>; Mon, 21 Oct 2013 16:25:03 +0200 (MEST)
Date: Mon, 21 Oct 2013 16:25:02 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Weston Andros Adamson <dros@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Message-ID: <1726653680.198460.1382365502721.JavaMail.zimbra@desy.de>
In-Reply-To: <526537F3.2000303@RedHat.com>
References: <1382346241-20637-1-git-send-email-tigran.mkrtchyan@desy.de> <D009ABC0-C071-4597-8B67-11C7A0486383@netapp.com> <526537F3.2000303@RedHat.com>
Subject: Re: [PATCH] mountstats: enforce new python syntax
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "Steve Dickson" <SteveD@redhat.com>
> To: "Weston Andros Adamson" <dros@netapp.com>
> Cc: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>, "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
> Sent: Monday, October 21, 2013 4:19:31 PM
> Subject: Re: [PATCH] mountstats: enforce new python syntax
> 
> 
> 
> On 21/10/13 10:04, Weston Andros Adamson wrote:
> > I posted a similar patch last week.
> Which has been committed!

Ah, then sorry for the noise!

Tigran.
> 
> steved.
> > 
> > -dros
> > 
> > On Oct 21, 2013, at 5:04 AM, Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> > wrote:
> > 
> >> $ mountstats
> >>  File "/usr/sbin/mountstats", line 272
> >>    (count, ((count * 100) / sends)), end=' ')
> >>                                         ^
> >> SyntaxError: invalid syntax
> >>
> >> Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
> >> ---
> >> tools/mountstats/mountstats.py | 1 +
> >> 1 file changed, 1 insertion(+)
> >>
> >> diff --git a/tools/mountstats/mountstats.py
> >> b/tools/mountstats/mountstats.py
> >> index 3f5fea5..351145e 100644
> >> --- a/tools/mountstats/mountstats.py
> >> +++ b/tools/mountstats/mountstats.py
> >> @@ -1,5 +1,6 @@
> >> #!/usr/bin/env python
> >> # -*- python-mode -*-
> >> +from __future__ import print_function
> >> """Parse /proc/self/mountstats and display it in human readable form
> >> """
> >>
> >> --
> >> 1.8.3.1
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
