From: Neil Brown <neilb@suse.de>
Subject: RE: Sm-notify
Date: Sat, 28 Jun 2008 20:33:41 +1000
Message-ID: <18534.4997.157000.160865@notabene.brown>
References: <485A6033.3090301@citi.umich.edu>
	<20080625193757.GF12629@fieldses.org>
	<FC3FA7C4E1CA2348B5579A68B24556E9DA4AF2946C@ABGEX72E.FSC.NET>
	<46260.192.168.1.70.1214533375.squirrel@neil.brown.name>
	<FC3FA7C4E1CA2348B5579A68B24556E9DA4AD413AB@ABGEX72E.FSC.NET>
	<18533.31573.855657.391140@notabene.brown>
	<FC3FA7C4E1CA2348B5579A68B24556E9DA4AD419DD@ABGEX72E.FSC.NET>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Oeltze, Benjamin" <Benjamin.Oeltze-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Laurenz, Dirk" <Dirk.Laurenz-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns1.suse.de ([195.135.220.2]:52079 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754426AbYF1Kds (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Jun 2008 06:33:48 -0400
In-Reply-To: message from Laurenz, Dirk on Saturday June 28
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday June 28, Dirk.Laurenz-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org wrote:
> i, the time out is from node a to b seconds, but from node b to a 15 minutes.
> what I saw was, that the handle changed in /var/lib/nfs/rmtab from 0x000002 to 0x000003 although
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
