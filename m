From: Neil Brown <neilb@suse.de>
Subject: RE: Sm-notify
Date: Sat, 28 Jun 2008 09:44:21 +1000
Message-ID: <18533.31573.855657.391140@notabene.brown>
References: <485A6033.3090301@citi.umich.edu>
	<20080625193757.GF12629@fieldses.org>
	<FC3FA7C4E1CA2348B5579A68B24556E9DA4AF2946C@ABGEX72E.FSC.NET>
	<46260.192.168.1.70.1214533375.squirrel@neil.brown.name>
	<FC3FA7C4E1CA2348B5579A68B24556E9DA4AD413AB@ABGEX72E.FSC.NET>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Laurenz, Dirk" <Dirk.Laurenz-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: "Oeltze, Benjamin" <Benjamin.Oeltze-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:43539 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757441AbYF0Xo3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Jun 2008 19:44:29 -0400
In-Reply-To: message from Oeltze, Benjamin on Friday June 27
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Friday June 27, Benjamin.Oeltze-/ixSogHR0HOS/tZ4Wjpou0EOCMrvLtNR@public.gmane.org wrote:
> Hi,
> maybe I can specify Dirks question.

Thanks.

> 
> We are trying to set up a NFS Cluster and want to use sm-notify to inform the Clients if the Server has failed over.
> We have found a Howto that says: sm-notify uses files under /var/lib/nfs/sm to determine the Clients it has to inform.
> Our Problem is, that ther are no files in this place even if we connet with a client. Is there anything we have forgotten?

Files do not get created in /var/lib/nfs/sm until the client tried to
get a lock on some file (or part of a file).  Then the file is
created.
Some minutes after the last lock is dropped, the file should be
removed (though I recall there were some issues related to that, it
might depend on exactly which kernel you are running).

If no file locking is involved, there is no need to inform the client
of failover.  They will transparently start accessing the new server
through the old IP address, possible after a short timeout.

NeilBrown

