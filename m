From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: exportfs nohide option for nfsv4
Date: Thu, 10 Mar 2005 10:26:50 -0500
Message-ID: <20050310152650.GA12460@fieldses.org>
References: <20050310151451.84319.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D9PYR-0000F3-No
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 07:26:27 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D9PYP-0006Ar-6B
	for nfs@lists.sourceforge.net; Thu, 10 Mar 2005 07:26:27 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-Reply-To: <20050310151451.84319.qmail@web51603.mail.yahoo.com>
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

On Thu, Mar 10, 2005 at 07:14:50AM -0800, mehta kiran wrote:
> what i feel is that when i have explicitly exported 
> exported /export/exp1 and /export i should not require
> to specify no hide option(I have explicitly exported
> /export/exp1 and so why should i ask nfs to
> unhide it)

In v4, the client expects *all* of the exports to be stitched together
into a single namespace.

In v3, mounting is done with a separate protocol.  So, for example, it's
possible that you can get a different file by mounting "/a" and then
looking up "b" than you would get if you mounted "/a/b".

To v3 clients, exporting /export/exp1 makes it possible for clients to
mount /export/exp1, without allowing them to mount /export and then
traverse to /export/exp1.

>From the point of view of someone that only uses v4, yes, the "nohide"
looks redundant since the only way to get to that export is by
traversing from the parent.  But for v3 it isn't redundant, so this
requirement is not likely to go away.

(I suppose as a special case we could treat "fsid=0" as implying the
crossmnt option for v4 clients.  I don't know whether that's a good
idea.)

>    I am referring to  man page of exports.

Which part of "man exports" are you referring to?  Could you quote the
relevant passage?  I don't see anything that says "nohide" is
unnecessary in this case.

--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
