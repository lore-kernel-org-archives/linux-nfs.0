From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [nfsv4] Re:  NFSv4 ACL and POSIX interaction / mask,
	draft-ietf-nfsv4-acls-00 not ready
Date: Fri, 14 Jul 2006 14:32:44 -0400
Message-ID: <20060714183243.GF20999@fieldses.org>
References: <C98692FD98048C41885E0B0FACD9DFB8023DF690@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Sam Falkner <Sam.Falkner@sun.com>, nfs@lists.sourceforge.net,
	Spencer Shepler <spencer.shepler@sun.com>,
	"Pawlowski,  Brian" <beepy@netapp.com>, nfsv4@ietf.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G1ST1-0004AD-ED
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 11:32:47 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=pickle.fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G1ST1-0007Q4-HJ
	for nfs@lists.sourceforge.net; Fri, 14 Jul 2006 11:32:47 -0700
To: "Noveck, Dave" <Dave.Noveck@netapp.com>
In-Reply-To: <C98692FD98048C41885E0B0FACD9DFB8023DF690@exnane01.hq.netapp.com>
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

On Fri, Jul 14, 2006 at 02:29:42PM -0400, Noveck, Dave wrote:
> I'm not aware of any case in which you 
> will get different values for a single attribute (no error in 
> either case) based on whether you are asking for a different 
> attribute.

Yeah, OK.  So, like I say, it's an odd thing to do.  I haven't managed
to come up with any fundamental reason why it won't work, though.

--b.


-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
