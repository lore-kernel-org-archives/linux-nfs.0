From: "Dennis, Richard" <Richard.Dennis@lehman.com>
Subject: RE: Issues with nfs solaris server
Date: Thu, 19 Jun 2003 15:59:37 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0073ECCF4F99D611810B0002A58F26560EB31523@exnyc03.lehman.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail-chi.bigfish.com ([63.161.60.29] helo=mail5-kan-R.bigfish.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19T5bD-0003Jm-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 13:01:35 -0700
To: "'Trond Myklebust'" <trond.myklebust@fys.uio.no>,
	"Chris Croswhite" <csc@cadence.com>
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

Also, can you provide "rpcinfo -p <servername>".  I have seen RPC lock
manager threads disappear/die (just a particular thread for NLM v3 udp) on
Solaris NFS servers when Linux clients were mounted...turned out that latest
patches from Sun resolved this. 

--Rick

-----Original Message-----
From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no] 
Sent: Thursday, June 19, 2003 1:15 PM
To: Chris Croswhite
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] Issues with nfs solaris server


>>>>> " " == Chris Croswhite <csc@cadence.com> writes:

     > Guys, We are seeing issues with solaris nfs servers.  Every
     > once in a while, mount points die and are not recoverable
     > (except to reboot).  nfsutils 1.0.3 kernel 2.4.19.  I had heard
     > someone mention that it might be a spinlock within the kernel.

Could you elaborte on what you mean by 'die'? Also, what type of mount
options are you using (is it TCP or UDP)?

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

------------------------------------------------------------------------------
This message is intended only for the personal and confidential use of the designated recipient(s) named above.  If you are not the intended recipient of this message you are hereby notified that any review, dissemination, distribution or copying of this message is strictly prohibited.  This communication is for information purposes only and should not be regarded as an offer to sell or as a solicitation of an offer to buy any financial product, an official confirmation of any transaction, or as an official statement of Lehman Brothers.  Email transmission cannot be guaranteed to be secure or error-free.  Therefore, we do not represent that this information is complete or accurate and it should not be relied upon as such.  All information is subject to change without notice.




-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
