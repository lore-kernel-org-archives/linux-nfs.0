From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: NFS write errors
Date: Wed, 13 Oct 2004 12:33:08 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <EXCHG2003AOPpBpcXCX00006570@EXCHG2003.microtech-ks.com>
References: <1097686177.8133.2915.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CHn06-0006Gx-Om
	for nfs@lists.sourceforge.net; Wed, 13 Oct 2004 10:33:22 -0700
Received: from host27-44.discord.birch.net ([65.16.27.44] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CHn03-0006QU-TC
	for nfs@lists.sourceforge.net; Wed, 13 Oct 2004 10:33:22 -0700
To: "'Dan Stromberg'" <strombrg@dcs.nac.uci.edu>,
	<nfs@lists.sourceforge.net>
In-Reply-To: <1097686177.8133.2915.camel@tesuji.nac.uci.edu>
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


I have seen a fair amount of issues with RH3.0 update 2, either
on the client or server side.

On the client side, Opterun's will crash the client on a core dump
across NFS, on IA64's we get a variety of odd errors including using
vi on an existing file and the file going away on the :wq exit, and
no longer being there at all.   If you are using update 2, I would
strongly suggest getting update 3.

I don't know if there were issues before update 2, I did do some testing
on update 1 and we did not see anything bad, but we updated to update 2 
before the serious production work started, and it was bad.

                       Roger

-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Dan Stromberg
Sent: Wednesday, October 13, 2004 11:50 AM
To: nfs@lists.sourceforge.net
Cc: Dan Stromberg
Subject: [NFS] NFS write errors


We are occasionally getting NFS write errors when writing terrabytes of data
from an AIX 5.1 system to an RHEL 3 system, using the version of in-kernel
NFS that comes with RHEL 3.  We're using 8k rsize, 8k wsize, nfs v3, and tcp
presently, but this isn't written in stone.

Has anyone else seen this?

Has anyone found a workaround?

Does anyone have any suggestions, speculative or otherwise?

Thanks!

--
Dan Stromberg DCS/NACS/UCI <strombrg@dcs.nac.uci.edu>




-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
