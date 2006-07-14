From: "Noveck, Dave" <Dave.Noveck@netapp.com>
Subject: Re: [nfsv4] Re:  NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Fri, 14 Jul 2006 14:29:42 -0400
Message-ID: <C98692FD98048C41885E0B0FACD9DFB8023DF690@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Sam Falkner <Sam.Falkner@sun.com>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@sun.com>,
	"Pawlowski,  Brian" <beepy@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1SR6-00040M-JB
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 11:30:48 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1G1SR3-0005sS-Pg
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 11:30:49 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>, <nfsv4@ietf.org>
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

I think in all the cases you mentioned, we a have situation in 
which the set of attributes you ask for can effect whether you 
get an error or not.  I'm not aware of any case in which you 
will get different values for a single attribute (no error in 
either case) based on whether you are asking for a different 
attribute.  Other than things like asking for an attribute
that doesn't exist will cause an error to be set in rdattr_error,
but that is part of the function of rdattr_error.

-----Original Message-----
From: J. Bruce Fields [mailto:bfields@fieldses.org] 
Sent: Friday, July 14, 2006 2:23 PM
To: nfsv4@ietf.org
Cc: Sam Falkner; Pawlowski, Brian; Spencer Shepler;
nfs@lists.sourceforge.net
Subject: Re: [nfsv4] Re: [NFS] NFSv4 ACL and POSIX interaction /
mask,draft-ietf-nfsv4-acls-00 not ready


On Fri, Jul 14, 2006 at 01:59:30PM -0400, J. Bruce Fields wrote:
> For a client that doesn't support the new attributes, a server can
apply
> the mask attributes to the ACL before returning it.  I suppose a
> multi-protocol server would do the same for CIFS clients.

By the way, the proposed protocol behavior here is odd:  the server
returns a different ACL depending on whether the client requested any of
the new mask attributes in the same GETATTR.

But I suppose there are other cases (rdattr_error, maybe some migration
cases??) where what we return can depend in strange ways on which
attributes were requested, so maybe it's not totally without precedent?

--b.

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www1.ietf.org/mailman/listinfo/nfsv4


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
