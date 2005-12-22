From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS TCP settings
Date: Thu, 22 Dec 2005 17:41:31 -0500
Message-ID: <1135291291.9769.32.camel@lade.trondhjem.org>
References: <20051221163254.70779.qmail@web34105.mail.mud.yahoo.com>
	 <1135191742.1122.402.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kenny Simpson <theonetruekenny@yahoo.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EpZ88-0004gX-GA
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 14:41:48 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EpZ87-0006GW-Fc
	for nfs@lists.sourceforge.net; Thu, 22 Dec 2005 14:41:48 -0800
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1135191742.1122.402.camel@seki.nac.uci.edu>
Sender: nfs-admin@lists.sourceforge.net
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

On Wed, 2005-12-21 at 11:02 -0800, Dan Stromberg wrote:

> I have some connection between some pairs of hosts for which all of the
> following appear to be true:
> 
> 1) TCP Window Scaling is enabled on both endpoints
> 2) TCP Window Scaling is mentioned in the initial SYN and SYN/ACK
> 3) tcptrace thinks that TCP Window Scaling isn't happening
> 
> Is there something other than the SYN and SYN/ACK that might cause TCP
> Window Scaling to go away?

Routers/switches that don't support TCP window scaling are a typical
cause.

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
