From: "Laurenz, Dirk" <Dirk.Laurenz-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org>
Subject: AW: Sm-notify
Date: Sat, 28 Jun 2008 13:25:19 +0200
Message-ID: <FC3FA7C4E1CA2348B5579A68B24556E9DA4AED046F@ABGEX72E.FSC.NET>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: "Oeltze, Benjamin" <Benjamin.Oeltze-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dgate10.fujitsu-siemens.com ([80.70.172.49]:41997 "EHLO
	dgate10.fujitsu-siemens.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755317AbYF1LZV convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Jun 2008 07:25:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

No, the client hungs for 15mins and then resumes it workshop

----- Urspr=FCngliche Nachricht -----
Von: Neil Brown <neilb@suse.de>
Gesendet: Samstag, 28. Juni 2008 12:33
An: Laurenz, Dirk <Dirk.Laurenz-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org>
Cc: Oeltze, Benjamin <Benjamin.Oeltze-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org>; linux-nfs@v=
ger.kernel.org <linux-nfs@vger.kernel.org>
Betreff: RE: Sm-notify


On Saturday June 28, Dirk.Laurenz-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org wrote:
> i, the time out is from node a to b seconds, but from node b to a 15 =
minutes.
> what I saw was, that the handle changed in /var/lib/nfs/rmtab from 0x=
000002 to 0x000003 although
> the fsid is the same on both nodes.
> how can the 15minute timeout occur?

The number is rmtab (e.g. 0x000002) is like a reference count.  The
fact that you sometimes see '2' and sometimes '3' is of no real
interest.

I am correct in interpreting what you say as:

  When you fail over from 'a' to 'b', it does so quite quickly, but
  when you then fail back from 'b' to 'a', you get a 15 minute
  timeout?

If not, please explain in more detail.
If so:
  Why exactly are you doing this.  It doesn't seem to make sense.
  Did 'b' get rebooted in the interim?
  It could be that you are hitting the same issue discussed here:

    http://linux-nfs.org/pipermail/nfsv4/2008-June/008673.html

  and in the surrounding thread.

However this has nothing to do with sm-notify.

NeilBrown
