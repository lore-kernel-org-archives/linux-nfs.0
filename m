From: Olaf Kirch <okir@suse.de>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 16:36:55 +0100
Message-ID: <20041122153655.GH1291@suse.de>
References: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWGFR-0008DN-AO
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 07:37:01 -0800
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CWGFP-0007Q1-BE
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 07:37:01 -0800
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id 4C218114FB5D
	for <nfs@lists.sourceforge.net>; Mon, 22 Nov 2004 16:36:55 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <482A3FA0050D21419C269D13989C61130435EB6E@lavender-fe.eng.netapp.com>
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

On Tue, Nov 16, 2004 at 10:48:12AM -0800, Lever, Charles wrote:
> i'm just looking for clarification so i can provide a good explanation
> in the Linux NFS FAQ about the evils of using "async."  i'll cruise
> through the server code.

Just about the only reason for async I can think of is if you have an
incoming data stream you need to write at a constant rate (think of a
diskless set top box writing an mpeg2 stream)

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
