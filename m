From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Issues with nfs solaris server
Date: 19 Jun 2003 10:15:01 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shshe6mq99m.fsf@charged.uio.no>
References: <EE335453C5C57840823404C684F9F617012D6849@exmbx01sj.Cadence.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19T30D-0005li-00
	for <nfs@lists.sourceforge.net>; Thu, 19 Jun 2003 10:15:13 -0700
To: "Chris Croswhite" <csc@cadence.com>
In-Reply-To: <EE335453C5C57840823404C684F9F617012D6849@exmbx01sj.Cadence.COM>
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
