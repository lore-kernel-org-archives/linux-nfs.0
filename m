From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: Revisting mmap() and truncate() related corruption
Date: Fri, 6 Feb 2004 09:43:10 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040206144310.GB23283@ti19.telemetry-investments.com>
References: <1076032596.30653.24.camel@s4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ap7Cd-0003tS-KG
	for nfs@lists.sourceforge.net; Fri, 06 Feb 2004 06:43:31 -0800
Received: from 209-166-240-202.cust.walrus.com ([209.166.240.202] helo=ti3.telemetry-investments.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Ap7CZ-0004fj-6d
	for nfs@lists.sourceforge.net; Fri, 06 Feb 2004 06:43:27 -0800
To: Chris Newbold <cnewbold@laurelnetworks.com>
In-Reply-To: <1076032596.30653.24.camel@s4>
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

On Thu, Feb 05, 2004 at 08:56:36PM -0500, Chris Newbold wrote:
> So, I'd like to find out what ever happened with this issue and if there
> ever were, or will be, any official fixes against the 2.4.x line...

FWIW, the Fedora Core 1 kernels contain this patch.
[But the FC1 kernels have other problems, namely hanging in umount. :-/]

Regards,

	Bill Rugolsky


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
