From: "Alexander Borghgraef" <alexander.borghgraef.rma@gmail.com>
Subject: Re: Nfs filesystem corruption(?) after kmail crash
Date: Tue, 27 May 2008 14:15:41 +0200
Message-ID: <9e8c52a20805270515o14a7ded6ne1737a827c91d2a7@mail.gmail.com>
References: <9e8c52a20805140532w2bcfeff3n896fa5a9b0e82b5@mail.gmail.com>
	 <20080519144806.GB7622@fieldses.org>
	 <9e8c52a20805230744m2f7488e5q2867674f2987444@mail.gmail.com>
	 <RTPCLUEXC1-PRDRXf2L00000168@RTPMVEXC1-PRD.hq.netapp.com>
	 <9e8c52a20805260144u34f81996oa27475cc4c2e72d2@mail.gmail.com>
	 <20080526074054.141945a7@tleilax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	linux-nfs@vger.kernel.org
To: "Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:64431 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756338AbYE0MPp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 May 2008 08:15:45 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1134648nfc.21
        for <linux-nfs@vger.kernel.org>; Tue, 27 May 2008 05:15:41 -0700 (PDT)
In-Reply-To: <20080526074054.141945a7-RtJpwOs3+0O+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 26, 2008 at 1:40 PM, Jeff Layton <jlayton@redhat.com> wrote:
>
> The ???? fields usually pop up when stat() calls fail. The odd thing in
> this case though is that stat() seemed to figure out that this was a
> directory and not a plain file, but missed out on everything else.
>
> Is this problem persistent?

It varies. I've had occurrences where it lasted for 15mins, but recent
ones have been too short to register. I've had cases where an ls or cd
into the affected directory showed nothing out of the ordinary, which
leads me to believe that the error was just there long enough to cause
the kmail crash, and then disappeared.

> If so, it might be interesting to run:
>
>    strace stat cur
>
> ...and see what error it's returning.

Ok, I'll do that when I get an error which lasts long enough.

> Even better would be to get a
> capture on the wire at the same time and see if the server is returning
> an error of some sort.

I have absolutely no idea how to do that :-)

-- 
Alex Borghgraef
