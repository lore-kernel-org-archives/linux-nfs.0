From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: ANNOUNCE: nfs-utils 1.0.7-pre1
Date: Thu, 9 Dec 2004 12:31:01 -0500
Message-ID: <20041209173101.GD20877@fieldses.org>
References: <16815.63554.437489.308079@cse.unsw.edu.au> <20041209165622.GY20794@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CcS7y-0006yx-FW
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 09:30:54 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CcS7x-00067R-Ic
	for nfs@lists.sourceforge.net; Thu, 09 Dec 2004 09:30:54 -0800
To: Robert Schwebel <robert@schwebel.de>
In-Reply-To: <20041209165622.GY20794@pengutronix.de>
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

On Thu, Dec 09, 2004 at 05:56:22PM +0100, Robert Schwebel wrote:
> On Fri, Dec 03, 2004 at 04:23:14PM +1100, Neil Brown wrote:
> > I have made available a pre-release of nfs-utils 1.0.7.
> 
> Here is an update of our "fix autotools to make nfs-utils crosscompile"
> patch: 
> 
> 	http://www.pengutronix.de/software/nfs-utils/nfs-utils-1.0.7-pre1-ptx1.patch.gz
> We could not test the NFSv4 stuff, kerberos and gss, but the other
> things seem to work. The patch was cleaned up and doesn't touch the
> distribution code any more. 

It does seem to add back the etc/nodist files.  I assume that was just
an accident?

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
