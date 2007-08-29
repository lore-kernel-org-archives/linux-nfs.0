From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: need info on IPv6 support for NFS in RHEL and SLES	distros
Date: Wed, 29 Aug 2007 23:08:28 +0200
Message-ID: <20070829210828.GA21877@uio.no>
References: <3DFE68BCB5D6994994AA6CB1EC581EA30411E61E@qcaexc02.asiapacific.cpqcorp.net>
	<46D59C8F.8070508@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQUmE-0006hz-DK
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 14:08:38 -0700
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQUmH-000851-06
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 14:08:42 -0700
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net) by cassarossa.samfundet.no with esmtps
	(TLS-1.0:RSA_AES_256_CBC_SHA1:32) (Exim 4.63)
	(envelope-from <sesse@samfundet.no>) id 1IQUm5-0002tC-2E
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 23:08:29 +0200
Received: from root by trofast.sesse.net with local (Exim 4.67)
	(envelope-from <sesse@samfundet.no>) id 1IQUm4-0005jV-Bo
	for nfs@lists.sourceforge.net; Wed, 29 Aug 2007 23:08:28 +0200
In-Reply-To: <46D59C8F.8070508@oracle.com>
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

On Wed, Aug 29, 2007 at 12:19:27PM -0400, Chuck Lever wrote:
> No Linux distribution contains IPv6 support for NFS right now.  The 
> implementation is still being developed.

Speaking of which, what's missing now? I see text-based mounts, client-side
IPv6 RPC and server-side transport switch (of which the first two are already
in mainline, and the last seems to be on its way) -- my impression was that
these are all important building blocks. I guess nfs-utils will also need
some patching, and an IPv6 transport will be needed for plugging into the
server side transport switch, but after that?

/* Steinar */
-- 
Homepage: http://www.sesse.net/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
