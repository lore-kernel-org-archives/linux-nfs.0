Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.195]:50777 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754857AbaCHBjS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Mar 2014 20:39:18 -0500
Date: Fri, 7 Mar 2014 20:38:32 -0500
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Brown Neil <neilb@suse.de>, Dickson Steve <steved@redhat.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] fix intr/nointr to match kernel behavior (ignored)
Message-ID: <20140308013832.GA10728@umich.edu>
References: <1394143352-26095-1-git-send-email-rees@umich.edu>
 <20140307185937.5852666b@notabene.brown>
 <D65A0AA5-ADF9-43AA-871F-69533C8F2DD7@primarydata.com>
 <20140308104228.4bfcd3d5@notabene.brown>
 <12C999A4-52B8-461F-BFB9-F67AB4F6EFCE@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <12C999A4-52B8-461F-BFB9-F67AB4F6EFCE@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:

  > I would certainly be good if we could delegation the documentation.  But I
  > couldn't find anything in signal(7) that seemed particularly relevant. Which
  > bit were you thinking of?
  > 
  
  The table which lists the posix signals, and which indicates whether they
  are fatal not (i.e. what ‘action’ they cause).  The same page also
  explains signal blocking and signal handling, which could also be
  helpful..

This seems the relevant part to me, assuming nfs system calls are considered
"slow":

           * read(2), readv(2), write(2),  writev(2),  and  ioctl(2)  calls  on
             "slow"  devices.   A  "slow"  device is one where the I/O call may
             block for an indefinite time, for example, a  terminal,  pipe,  or
             socket.   (A  disk  is not a slow device according to this defini‐
             tion.)  If an I/O call on a slow device  has  already  transferred
             some  data by the time it is interrupted by a signal handler, then
             the call will return a success status  (normally,  the  number  of
             bytes transferred).

Here's Neil's description:

>>> "A process that is waiting for a reply for an NFS server can be killed
>>> by any signal which would normally kill the process.  If a signal would not
>>> normally kill the process (i.e. it is caught or ignored) then that signal
>>> will not abort and NFS request".

So assuming nfs system calls honor the SA_RESTART flag, I think these
behaviors are the same?
