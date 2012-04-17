Return-Path: linux-nfs-owner@vger.kernel.org
Received: from minas.ics.muni.cz ([147.251.4.40]:54847 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752931Ab2DQOfG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 10:35:06 -0400
Date: Tue, 17 Apr 2012 16:34:48 +0200
From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, jiri.horky@cesnet.cz
Subject: Re: NFSv4 high availability setups
Message-ID: <20120417143448.GU32132@ics.muni.cz>
References: <20120405103124.GV4752@ics.muni.cz>
 <20120405073901.63d1c749@tlielax.poochiereds.net>
 <20120410125552.GC5074@ics.muni.cz>
 <20120410091321.1be1a87e@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <20120410091321.1be1a87e@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Tue, Apr 10, 2012 at 09:13:21AM -0400, Jeff Layton wrote:
> Nope. It'll all work just great...until it doesn't. I don't have any
> specific failure scenarios, but most of the problems will be issues
> with state recovery when a server node is restarted.
> 
> That may manifest in different ways -- problems reclaiming locks for
> instance, or even silent data corruption depending on the application.

would it work if I relax active-active scenario to just active-passive in the
following way:

Server A actively exports  /export/A
Server B actively exports  /export/B

Server B is passive backup for Server A
Server A is passive backup for Server B

would it work to migrate the failed Server B to Server A so that Server A will
server both /export/A and /export/B?

There will be a problem with v4recovery dir. Would it be possible just to
merge v4recovery from Server B to Server A (nfs export would be stopped while
merging v4recovery).

It seems that cp -r B/v4recovery/* A/v4recovery/ would do all the things. Am
I right?

Do I need to copy recovery state if I delay migration of the failed Server B to
Server A for 91 secs? I.e., longer than lease expiry time.. Or do I still need
a record for the client in v4recovery dir in such a case?

-- 
Luká¹ Hejtmánek
