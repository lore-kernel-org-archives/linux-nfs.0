From: "John Lumby" <johnlumby@hotmail.com>
Subject: multi-hopping NFS - aka re-exporting mounted filesystems
Date: Tue, 21 Dec 2004 11:58:33 -0500
Message-ID: <BAY22-F53EF5EFCFF6A662D31E4CA3A30@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CgnMW-0005tr-Tk
	for nfs@lists.sourceforge.net; Tue, 21 Dec 2004 08:59:52 -0800
Received: from bay22-f5.bay22.hotmail.com ([64.4.16.55] helo=hotmail.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CgnMW-0000ep-IU
	for nfs@lists.sourceforge.net; Tue, 21 Dec 2004 08:59:52 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

I would like to be able to export an NFS-mounted filesystem for multi-hop 
mounting.    I.e.:

machine DIRHOST exports fs /dir for mount by machine CANMOUNTIT
machine CANMOUNTIT mount -t nfs .... mounthost=DIRHOST DIRHOST:/dir /candir

Now I want CANMOUNTIT to re-export /candir for machine WOULDLIKETOMOUNTIT

This doesn't work in the NFS I am using - nfs-utils 1.0.5 and linux kernel 
2.6.7.  On WOUDLIKETOMOUNTIT I get :
mount: Stale NFS file handle

I gather this is something that has come up from time to time and is not 
supported in the nfs-utils.. However I found a reference in the archives 
from someone claiming to have got it working
http://marc.theaimsgroup.com/?l=linux-nfs&m=98762491202667&w=2
some package called nfs-server-2.2beta provided a --re-export option on 
rpc.mountd and rpc.nfsd.   I tried the homepage for it and the download 
appears to have vanished and is ancient anyway.

My own particular need is for strictly read-only and I don't need it to be 
supported, just to work for simple use.    The reason I can't just export 
/dir firectly from DIRHOST to WOULDLIKETOMOUNTIT
is because the owner of DIRHOST (who is not me) does not like to export to 
machines outside a close physical distance (same building) owing to finding 
occasionally that a runaway client will flood the local network.  I own 
CANMOUNTIT  (in same building) and WOULDLIKETOMOUNTIT
is my laptop which could be anywhere.

Does anyone have any suggestions for how to get this working, or can anyone 
point me to where I could lay my hands on this --re-export source code?

John




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
