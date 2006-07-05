From: Neil Brown <neilb@suse.de>
Subject: Re: nfs-utils 1.0.9-rc1 - hopefully -final in a week
Date: Wed, 5 Jul 2006 17:06:51 +1000
Message-ID: <17579.25867.214365.475122@cse.unsw.edu.au>
References: <17576.25386.427824.894874@cse.unsw.edu.au>
	<44AACDA6.AD69.00CC.0@novell.com>
	<17579.22038.267510.116270@cse.unsw.edu.au>
	<44ABA72E.AD69.00CC.0@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, J.BruceFields@sc8-sf-spam2.sourceforge.net,
	nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fy1Tj-0001xG-Dz
	for nfs@lists.sourceforge.net; Wed, 05 Jul 2006 00:07:19 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fy1Ti-0006fH-6T
	for nfs@lists.sourceforge.net; Wed, 05 Jul 2006 00:07:19 -0700
To: "Shankar Anand" <shanand@novell.com>
In-Reply-To: message from Shankar Anand on Wednesday July 5
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wednesday July 5, shanand@novell.com wrote:
> 
> Anyway the server is going to have either nfs4 or nfs4.1 running at
> one point in time. So it should be fine.
> 

I don't think that is true.
A server needs to support multiple versions - at least as an option,
just as we now support v2, v3, and v4.

But I suspect it is a question that can be safely left until it is a
real issue.

Thanks,
NeilBrown

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
