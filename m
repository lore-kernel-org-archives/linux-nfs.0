From: seth vidal <skvidal@phy.duke.edu>
Subject: Re: nfs client monitoring?
Date: Thu, 29 Jul 2004 14:21:36 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1091125296.569.85.camel@grads-23.phy.duke.edu>
References: <41092832.3030400@psu.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BqFaB-0003NZ-Gq
	for nfs@lists.sourceforge.net; Thu, 29 Jul 2004 11:24:47 -0700
Received: from mail.phy.duke.edu ([152.3.182.2] ident=[8/r4jI17dGvFwHMBmTCar9EX+PtSC+lK])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BqFaB-0003HX-6y
	for nfs@lists.sourceforge.net; Thu, 29 Jul 2004 11:24:47 -0700
To: Jason Holmes <jholmes@psu.edu>
In-Reply-To: <41092832.3030400@psu.edu>
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

On Thu, 2004-07-29 at 12:39, Jason Holmes wrote:
> Hi,
> 
> Is there a command that can show the demands being placed on the nfs 
> server by each individual client?  I run into the situation from time to 
> time where a random user will do something that puts an extreme load on 
> the fileserver and having such a command would help greatly in trying to 
> figure out the source of the load.
> 

look back on this list, Iirc someone was writing a program to return a
list of which clients were accessing which files.

that's not _quite_ what you're looking for but it could be close.

-sv




-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
