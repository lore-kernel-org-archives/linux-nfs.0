From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv4 needs restart (permission denied)
Date: Mon, 6 Dec 2004 10:18:36 -0500
Message-ID: <20041206151836.GD20864@fieldses.org>
References: <41B0A7C0.1020209@drzeus.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CbKdC-0006hw-Fz
	for nfs@lists.sourceforge.net; Mon, 06 Dec 2004 07:18:30 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CbKd9-0008FE-Hn
	for nfs@lists.sourceforge.net; Mon, 06 Dec 2004 07:18:30 -0800
To: Pierre Ossman <drzeus-list@drzeus.cx>
In-Reply-To: <41B0A7C0.1020209@drzeus.cx>
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

On Fri, Dec 03, 2004 at 06:52:00PM +0100, Pierre Ossman wrote:
> Whenever I reboot my file server one of my clients has trouble accessing
> the exports. I just get permission denied. However, when I restart nfsd
> it works fine. The other clients have no problems mounting.

NFSv4's server reboot recovery isn't really working yet--a Linux client
should be able to survive a non-Linux server reboot, but if a Linux
server reboots the clients its client will probably be lost.  The
missing piece is some code to store state about connected clients in
stable storage, which we're working on right now.

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
