From: Jeff Layton <jlayton@redhat.com>
Subject: Re: Nfs filesystem corruption(?) after kmail crash
Date: Mon, 26 May 2008 07:40:54 -0400
Message-ID: <20080526074054.141945a7@tleilax.poochiereds.net>
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5@mail.gmail.com>
	<20080519144806.GB7622@fieldses.org>
	<9e8c52a20805230744m2f7488e5q2867674f2987444@mail.gmail.com>
	<RTPCLUEXC1-PRDRXf2L00000168@RTPMVEXC1-PRD.hq.netapp.com>
	<9e8c52a20805260144u34f81996oa27475cc4c2e72d2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org
To: "Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39048 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754213AbYEZLlP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 May 2008 07:41:15 -0400
In-Reply-To: <9e8c52a20805260144u34f81996oa27475cc4c2e72d2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 26 May 2008 10:44:07 +0200
"Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com> wrote:

> On Fri, May 23, 2008 at 9:08 PM, Talpey, Thomas
> <Thomas.Talpey@netapp.com> wrote:
> >> The main thing here is that I'd like to understand why this is
> >>happening? What does it mean when ls returns something like:
> >>
> >>d????????? ? ?        ?          ?                ? cur
> >
> > This is something very different. (I'm assuming this "ls" was done on the
> > NFS mount and not the server itself.)
> 
> Yes, ls on the NFS mount on the client.
> 

> > Usually, this happens because there
> > are no attributes available locally - ls seems to know only the filetype
> > (directory) and filename (cur). What client kernel version are you running?
> 
> Client kernel: 2.6.24.4-64.fc8
> Server kernel: 2.6.9-1.667
> 

The ???? fields usually pop up when stat() calls fail. The odd thing in
this case though is that stat() seemed to figure out that this was a
directory and not a plain file, but missed out on everything else.

Is this problem persistent? If so, it might be interesting to run:

    strace stat cur

...and see what error it's returning. Even better would be to get a
capture on the wire at the same time and see if the server is returning
an error of some sort.

-- 
Jeff Layton <jlayton@redhat.com>
