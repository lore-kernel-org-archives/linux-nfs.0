From: Steve Dickson <SteveD@redhat.com>
Subject: Re: rpcbind behavior on Fedora 7
Date: Thu, 26 Jul 2007 08:20:20 -0400
Message-ID: <46A89184.7020103@RedHat.com>
References: <46A672EA.9000705@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IE2KP-0002UV-Va
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 05:20:26 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IE2KT-0003du-K4
	for nfs@lists.sourceforge.net; Thu, 26 Jul 2007 05:20:29 -0700
In-Reply-To: <46A672EA.9000705@oracle.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Sorry for the delayed response... I was traveling...

Chuck Lever wrote:
> I was trying out the mount.nfs test case for another bug (see attached). 
>  The test case didn't work against a Fedora 7 server.  Trying to mount 
> with UDP against a specific port just hangs.  So I tried an rpcinfo 
> against it to see what the current configuration was.
In /etc/netconfig switch the order of the udp/tcp and udp6/tcp6
entries making the udp/tcp entires first. Similar to:

--- /etc/netconfig.orig   2005-05-18 01:10:50.000000000 -0400
+++ /etc/netconfig    2007-07-24 09:45:40.000000000 -0400
@@ -10,10 +10,10 @@
  # The <device> and <nametoaddr_libs> fields are always empty in this
  # implementation.
  #
-udp6       tpi_clts      v     inet6    udp     -       -
-tcp6       tpi_cots_ord  v     inet6    tcp     -       -
  udp        tpi_clts      v     inet     udp     -       -
  tcp        tpi_cots_ord  v     inet     tcp     -       -
+udp6       tpi_clts      v     inet6    udp     -       -
+tcp6       tpi_cots_ord  v     inet6    tcp     -       -
  rawip      tpi_raw       -     inet      -      -       -
  local      tpi_cots_ord  -     loopback  -      -       -
  unix       tpi_cots_ord  -     loopback  -      -       -


steved.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
