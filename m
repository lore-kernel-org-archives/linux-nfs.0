From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [PATCH] fix nfsidem cthon test
Date: Fri, 22 Oct 2004 12:38:33 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1098463114.8813.11.camel@lade.trondhjem.org>
References: <1098341478.21421.7.camel@hole.melbourne.sgi.com>
	 <1098343891.28394.15.camel@lade.trondhjem.org>
	 <20041021161309.GC24417@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Banks <gnb@melbourne.sgi.com>, Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CL2RI-0002Zr-Th
	for nfs@lists.sourceforge.net; Fri, 22 Oct 2004 09:38:52 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CL2RI-00011C-4J
	for nfs@lists.sourceforge.net; Fri, 22 Oct 2004 09:38:52 -0700
To: "Dr. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20041021161309.GC24417@fieldses.org>
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

to den 21.10.2004 Klokka 12:13 (-0400) skreiv J. Bruce Fields:

> We could do something like this for v4, though, couldn't we?
> 
> (I'm looking at rfc3530 section 9.3, which allows the client to assume
> two files are the same if the server returns the same fileid and fsid
> attributes for the two filehandles and doesn't return TRUE for
> unique_handles on either.)

I assume that the fsid does change if you cross "nohide" boundaries on
v2/v3 as well, so if you check the fsid, you can probably do it there
too.

The problem with fsid, is that it often changes under server reboot.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
