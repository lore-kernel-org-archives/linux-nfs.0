Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:58406 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809Ab2K3HTw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2012 02:19:52 -0500
MIME-Version: 1.0
In-Reply-To: <CANXojcwRy5cBz=E1S567J-1BFC4AiamLr=35bKrX0Zq-Me2b3w@mail.gmail.com>
References: <CANXojcy9thLBwrENTkOTSSE17L3N17A8XsTmyNqq3oNdhW_Q_w@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90B329CFD@SACEXCMBX04-PRD.hq.netapp.com>
	<CANXojcxR9673fRObMLPSScogAN05RSVhPFoni=ENc6YDWq9T7w@mail.gmail.com>
	<1354202525.4064.1.camel@pico.ipa.ssimo.org>
	<4FA345DA4F4AE44899BD2B03EEEC2FA90B32AEB7@SACEXCMBX04-PRD.hq.netapp.com>
	<CANXojcys4wR8N-R3oSjWRWJLsObn0Qf+i41vBUaNnJctdcrKVw@mail.gmail.com>
	<20121129202037.GQ4939@ZenIV.linux.org.uk>
	<CANXojcw15RdJdRoZxB3Z59YbOda7vG7RDRegfpoCjG4Bv4AvsQ@mail.gmail.com>
	<20121129211624.GS4939@ZenIV.linux.org.uk>
	<CANXojcxfrO+Ar4JSd0NiDJh7+_gg6s6cq5=UA7Pu1h4DRZ8Vkg@mail.gmail.com>
	<CAH2r5muw1U2XNMZsCq0gApuTMyj+6SN6S9KsUq52YM8CyZEG4A@mail.gmail.com>
	<CANXojcwRy5cBz=E1S567J-1BFC4AiamLr=35bKrX0Zq-Me2b3w@mail.gmail.com>
Date: Fri, 30 Nov 2012 08:19:52 +0100
Message-ID: <CANXojcxa98W7buVOgmsjMgrOukiiyVuafHS-NFz_yaSC2OFE1w@mail.gmail.com>
Subject: Re: Possible to make nfs aware of a inotify watch has been set.
From: Stef Bon <stefbon@gmail.com>
To: Steve French <smfrench@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

2012/11/30 Stef Bon <stefbon@gmail.com>:
> 2012/11/30 Steve French <smfrench@gmail.com>:

>> match closely to the existing Linux API.
>
> Hi,
>
> I start working on the seperate notifyfs servers.
> The whole advantage of that approach is that you can design the api
> from scratch. Notifyfs is not bound to the api of inotify. There
> remains the problem of mapping it to the fs event api on the host,
> which will be inotify probably on linux.
>
> At this moment the different events look like:
>


Maybe I will add locking information as well. I see that the
/proc/locks file can be monitored as well.

To me, information is very valuable.  It would be very nice (yes my
opinion) to have information about a file on a nfs (or cifs) share
about it lockstatus, and by who, and get notified when it's unlocked.

And no nobody asked me to do so.

Stef
