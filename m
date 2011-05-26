Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4887 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757800Ab1EZPET convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 May 2011 11:04:19 -0400
Subject: Re: [RFC] pnfs: Send layoutreturn, if Return-On-Close is set
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Benny Halevy <bhalevy@panasas.com>, Fred Isaman <iisaman@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Date: Thu, 26 May 2011 11:04:17 -0400
In-Reply-To: <4DDE6783.5@panasas.com>
References: <4DDE536E.8020805@panasas.com>
	 <1306419397.2984.14.camel@lade.trondhjem.org> <4DDE6783.5@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1306422257.2984.21.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2011-05-26 at 17:45 +0300, Boaz Harrosh wrote: 
> On 05/26/2011 05:16 PM, Trond Myklebust wrote:
> > On Thu, 2011-05-26 at 16:19 +0300, Boaz Harrosh wrote: 
> >> Every thing was ready, in pnfs_roc(). The segments released
> >> and the LO state blocked til after the close is done. All that
> >> is needed is to send the actual layoutreturn synchronously.
> > 
> > Why would we want to do this?
> > 
> > Return-on-close was initially considered useful only for debugging.
> > 
> What ??
> 
> > At the interim IETF meeting in Sunnyvale, we also discussed the case
> > where the forgetful client has forgotten the layout: in this case the
> > server may decide to forget the layout too. There is no controversy in
> > doing this, since both the client and the server know that any
> > outstanding layout is supposed to be returned (and if there is a
> > problem, then the server always has the option of sending a
> > CB_LAYOUTRECALL).
> > 
> 
> OK I didn't know that. So what you are saying is that if the server see
> a final close he can go and provocative free all segments marked with ROC?
> 
> If so then someone should fix the Linux server. Because currently it never
> frees them. On a modest machine like the UML I use. Few 10s of "git checkout linux"
> crash the machine with oom. Today they are only freed on client umount.

That would be a bug. The server must either free or recall in this
situation.

> > Adding a synchronous call to close is in any case a bug since close can
> > on occasion be sent in situations where we don't allow sleeping.
> > 
> 
> This is done only on the final close. Isn't the very final call sync?
> 
> Ok re-inspecting the code I can see that nfs4_do_close also takes a wait flag.
> I thought that the last close should always be waiting for all operations
> to end before proceeding with the close. That's how it is at the VFS level
> but I guess life is hard. So the only possible solution is within the same
> compound as the close. (not that we need it as you say)

The problem is that LAYOUTRETURN may have to be sent with a _different_
credential than the CLOSE itself.

See the description of the EXCHGID4_FLAG_BIND_PRINC_STATEID exchangeid
flag. Although we don't set that flag in our exchangeid requests, the
_server_ may still set it in its reply, in which case we are supposed to
obey it.
This is also a reason why sending OPEN and LAYOUTGET in the same
compound can be problematic.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

