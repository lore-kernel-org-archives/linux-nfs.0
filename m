From: Olaf Kirch <okir@suse.de>
Subject: Re: Debian Bug#235886: nfs-kernel-server inducing load of 8-9 with no good reason for Linux 2.6 clients
Date: Fri, 19 Mar 2004 13:03:22 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040319120322.GL25649@suse.de>
References: <20040318210943.GK3605@perlsupport.com> <20040319084935.GB25649@suse.de> <200403191253.37489.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B4Iij-0007IK-50
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 04:03:25 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B4Iii-0007KF-G4
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 04:03:24 -0800
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200403191253.37489.bernd-schubert@web.de>
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

On Fri, Mar 19, 2004 at 12:53:30PM +0100, Bernd Schubert wrote:
> Now there's also unfs3 (http://unfs3.sourceforge.net/), which supports as the 
> name suggests v3.

Which I think has a striking resemblance to unfsd in some parts of the
code but neglects to acknowledge that, both in the copyright statements
and the READMEs...

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
