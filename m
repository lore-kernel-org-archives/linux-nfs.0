From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: Re: broken umount -f
Date: Wed, 15 Jan 2003 13:22:14 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030115132214.A13482@ti19>
References: <6440EA1A6AA1D5118C6900902745938E07D551FA@black.eng.netapp.com> <20030115130759.B11894@ti19>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
   "'Scott Mcdermott'" <smcdermott@questra.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 209-166-240-202.cust.walrus.com.240.166.209.in-addr.arpa ([209.166.240.202] helo=ti3.telemetry-investments.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YsBM-0002K0-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 10:22:32 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <20030115130759.B11894@ti19>; from brugolsky@ytelemetry-investments.com on Wed, Jan 15, 2003 at 01:07:59PM -0500
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

[Sorry, for the resend; I broke my return address on the first try.]

On Wed, Jan 15, 2003 at 09:04:58AM -0800, Lever, Charles wrote:
> do you know what the risk of data corruption is when using "intr"?
> seems pretty low to me.

Any reason why we can't add a mount option that makes cl_intr only
effective for SIGKILL in sunrpc/clnt.c?  (A general sigmask= option
doesn't seem immediately useful, unless there is some use for [T]STOP.)
  
Regards,
 
    Bill Rugolsky


-------------------------------------------------------
This SF.NET email is sponsored by: A Thawte Code Signing Certificate 
is essential in establishing user confidence by providing assurance of 
authenticity and code integrity. Download our Free Code Signing guide:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0028en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
