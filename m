From: Jeff Garzik <jeff@garzik.org>
Subject: Re: A new NFSv4 server...
Date: Fri, 04 Jan 2008 00:32:49 -0500
Message-ID: <477DC501.3060104@garzik.org>
References: <477CD231.30603@garzik.org> <20080103163200.GB30029@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfsv4@linux-nfs.org, NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46642 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751755AbYADFcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Jan 2008 00:32:53 -0500
In-Reply-To: <20080103163200.GB30029@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Thu, Jan 03, 2008 at 07:16:49AM -0500, Jeff Garzik wrote:
>> At this point, I'm quite interested to hear feedback on how the server 
>> works with other NFSv4 clients.
> 
> Any possibility of making Connectathon in May?:
> 
> 	http://www.connectathon.org/
> 
> The major NFSv4 implementors normally have their clients there, so it's
> usually the quickest way to find and solve any interoperability
> problems.  Almost all the work will probably be on sessions and pNFS,
> but people should be willing to do basic 4.0 testing too.

As this isn't an official RH project, I would probably have to pay my 
own way, which makes it doubtful :)

Plus, surely in this day and age, we can figure out something better 
than waiting for face-to-face events to test something.  Maybe somebody 
could arrange a donation of some slice of a grid (Amazon EC2?), make 
various OS images available, and give engineers some way to request a 
selection of tests, with a selection of OS images?


> Glad to hear you're still working on this--it sounds interesting.

Certainly pNFS parallels some of the work I want to do...  NFSv4.1 is so 
darned complex though.  I am torn as to whether or not I want to take my 
server down that path.

I really wish the entire wire protocol were scrapped and replaced with 
something more sane, and easier to parse.  The variable-length 
structures passed to PCI hardware these days [as seen in the kernel 
drivers I hack on, IOW] are just as compact, if not more so, but are 
designed to be parsed quickly in large chunks, rather than the "next XDR 
may be your last!" approach :)

Sessions are IMO a tad overdone, too...  largely due to necessities 
forced upon NFSv4.1 by the legacy RPC protocol assumptions.  If you 
simply /assume/ basic properties of TCP or SCTP, it's a lot easier to do 
multi-channel or multi-homed messaging.  Multi-channel _isn't_ really 
that hard, and we've been doing it since the earliest days of NNTP and 
the Usenet Top 1000 pissing contest, if not longer.

It's tempting to see what would arise from a clean-slate wire protocol 
effort, something that is otherwise compatible with NFS 4.x operations, 
objects, and data model.

	Jeff



