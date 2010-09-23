Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41694 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752485Ab0IWVGM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 23 Sep 2010 17:06:12 -0400
Date: Thu, 23 Sep 2010 17:04:40 -0400
To: Olga Kornievskaia <aglo@citi.umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: question about nfs41 features
Message-ID: <20100923210440.GC14610@fieldses.org>
References: <AANLkTinvrHsQmcLCpt99dE1nU0md8zfwsh4vP8JRBJT6@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTinvrHsQmcLCpt99dE1nU0md8zfwsh4vP8JRBJT6@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 23, 2010 at 02:30:49PM -0400, Olga Kornievskaia wrote:
> I would greatly appreciate it I can get a reply from NFS41 server
> implementers out there on the subject of whether or not the following
> feature are (a) currently implemented by your server, (b) will be
> implemented soon (1year), (c) having interest in being implemented
> within the next few years and (d) are so low in priority that could be
> said: will never be implemented.

This could change depending on interest, of course, but:

> volatile handles
> named attributes

Probably both (d).

> directory delegations
> SSV

I'm guessing (c) or (d).  (I'd be happier if SSV were a higher priority,
but oh well.)

> trunking (session or clientid)

(b)

> segmented file layouts
> 
> recall of file layouts
> cb_notify_deviceid

Not sure.

> cb_getattr

(c)

> cb_recall_slot
> cb_notify_lock

Probably both (c).

This list doesn't necessarily get you anyone other than linux
implementors, so you may want to ask on nfsv4@ietf.org or ask people at
the bakeathon.

--b.
