From: Steve Dickson <SteveD@redhat.com>
Subject: Re: incorrect entries in /etc/netconfig
Date: Tue, 08 Jul 2008 13:40:17 -0400
Message-ID: <4873A681.5080409@RedHat.com>
References: <BE9551A6-D4EB-4A8A-9D26-18C4722CF136@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54019 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756730AbYGHRl3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jul 2008 13:41:29 -0400
In-Reply-To: <BE9551A6-D4EB-4A8A-9D26-18C4722CF136@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for taking soo long to address this... 

Chuck Lever wrote:
> Hi Steve-
> 
> I'm trying out setconfigent() and friends from the new libtirpc.
> 
> It looks like the entries in the stock /etc/netconfig on Fedora are
> incorrect compared with Solaris.  My Fedora 8 system has this:
> 
> udp        tpi_clts      v     inet     udp     -       -
> tcp        tpi_cots_ord  v     inet     tcp     -       -
> udp6       tpi_clts      -     inet6    udp6     -       -
> tcp6       tpi_cots_ord  -     inet6    tcp6    -       -
> 
> but my OpenSolaris 2008.5 system has this:
> 
> udp6       tpi_clts      v     inet6   udp    /dev/udp6       -
> tcp6       tpi_cots_ord  v     inet6   tcp    /dev/tcp6       -
> udp        tpi_clts      v     inet    udp    /dev/udp        -
> tcp        tpi_cots_ord  v     inet    tcp    /dev/tcp        -
> 
> Note the contents of the fifth field in each row.  The Fedora netconfig
> has "udp6" and "tcp6" as the protonames, which I think is incorrect. 
> These should be "udp" and "tcp".  Only the netids (the first field)
> should have the extra "6" suffix.  The protocol names should always be
> "udp" or "tcp", no matter which address family is used.
> 
> Can you fix this up in the libtirpc package?
It is in later releases... to be honest I'm not sure how
it got that way.. It did not seem to be broken in the 
stock F8 (libtirpc-0.1.7-12), F9 or rawhide packages 

steved.
