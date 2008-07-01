From: Chuck Lever <chuck.lever@oracle.com>
Subject: incorrect entries in /etc/netconfig
Date: Tue, 1 Jul 2008 16:30:34 -0400
Message-ID: <BE9551A6-D4EB-4A8A-9D26-18C4722CF136@oracle.com>
Mime-Version: 1.0 (Apple Message framework v926)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:22759 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755573AbYGAUeZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2008 16:34:25 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve-

I'm trying out setconfigent() and friends from the new libtirpc.

It looks like the entries in the stock /etc/netconfig on Fedora are  
incorrect compared with Solaris.  My Fedora 8 system has this:

udp        tpi_clts      v     inet     udp     -       -
tcp        tpi_cots_ord  v     inet     tcp     -       -
udp6       tpi_clts      -     inet6    udp6     -       -
tcp6       tpi_cots_ord  -     inet6    tcp6    -       -

but my OpenSolaris 2008.5 system has this:

udp6       tpi_clts      v     inet6   udp    /dev/udp6       -
tcp6       tpi_cots_ord  v     inet6   tcp    /dev/tcp6       -
udp        tpi_clts      v     inet    udp    /dev/udp        -
tcp        tpi_cots_ord  v     inet    tcp    /dev/tcp        -

Note the contents of the fifth field in each row.  The Fedora  
netconfig has "udp6" and "tcp6" as the protonames, which I think is  
incorrect.  These should be "udp" and "tcp".  Only the netids (the  
first field) should have the extra "6" suffix.  The protocol names  
should always be "udp" or "tcp", no matter which address family is used.

Can you fix this up in the libtirpc package?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
