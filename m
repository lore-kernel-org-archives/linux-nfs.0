From: seth vidal <skvidal@phy.duke.edu>
Subject: Re: NFS server not responding
Date: 04 Dec 2003 15:55:24 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1070571324.8472.2.camel@opus>
References: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>
	 <shsptfch1om.fsf@charged.uio.no> <3FCF70D9.1010808@RedHat.com>
	 <shsr7zk5sw4.fsf@guts.uio.no>  <3FCF86E9.2030300@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AS0VU-0003uj-B2
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 12:55:28 -0800
Received: from mail.phy.duke.edu ([152.3.182.2] ident=[tFGUq6AOBZY7lcvYTEbzTl9a3SYF+ckt])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AS0VT-0002pD-TU
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 12:55:28 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3FCF86E9.2030300@RedHat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> Well... it was in increase at the time I posted the patch.
> If remember correctly... there was actually some discussion
> that 1/30th of a second was a bit too long...
> 
> >You are setting the minimum timeout value at 1/30th of a second
> >instead of 1/10th of a second.
> >  
> >
> Right... I did miss this "minor" detail when I did the port....
> 
> >This might indeed explain why people are seeing an increase in resends
> >and 'server not responding' messages.
> >  
> >
> Most definitely... Here is the patch that should take care of the problem...
> 

Steve,
 Do you know if this change was in place when the 7.X kernels went from
2.4.18 to 2.4.20?

We started noticing a lot of nfs pain on udp connections when we went
from 2.4.18 to 2.4.20 from rh's kernels.
(in addition to the kscand nightmare)

-sv




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
