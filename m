From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: NFS server not responding
Date: Mon, 1 Dec 2003 11:58:37 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0312011151270.23297-100000@kenzo.iwr.uni-heidelberg.de>
References: <1070222510.14818.10.camel@binkley>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Douglas Furlong <douglas.furlong@firebox.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AQllN-0007SC-00
	for <nfs@lists.sourceforge.net>; Mon, 01 Dec 2003 02:58:45 -0800
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AQllM-0001Y4-S4
	for nfs@lists.sourceforge.net; Mon, 01 Dec 2003 02:58:45 -0800
To: seth vidal <skvidal@phy.duke.edu>
In-Reply-To: <1070222510.14818.10.camel@binkley>
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

On Sun, 30 Nov 2003, seth vidal wrote:

> I bet it's related to that problem.

Nope... The NFS server for this cluster is a single AMD Athlon with 256MiB 
RAM. I did not see any kscand or equivalent taking so much CPU as 
described in the bug reports. When the load is high, all top users are 
nfsd threads.
One of the reports however reminded me of the readahead discussion. I did 
some tests some time ago with 2.4.20-based kernel and did not see much 
difference, however I will try it now too and write back if I see some 
advantage.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
