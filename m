From: Jan Kasprzak <kas@fi.muni.cz>
Subject: Re: NFS mount hang (no response to getattr)
Date: Tue, 19 Oct 2004 15:42:41 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20041019134240.GS21046@fi.muni.cz>
References: <20041015144701.GD4473@fi.muni.cz> <20041019120517.GO21046@fi.muni.cz> <20041019133630.GR21046@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CJuGE-0007xS-2M
	for nfs@lists.sourceforge.net; Tue, 19 Oct 2004 06:42:46 -0700
Received: from anor.ics.muni.cz ([147.251.4.35] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CJuGC-0007dI-Di
	for nfs@lists.sourceforge.net; Tue, 19 Oct 2004 06:42:45 -0700
Received: from anxur.fi.muni.cz (IDENT:0@anxur.fi.muni.cz [147.251.48.3])
	by anor.ics.muni.cz (8.12.1/8.12.1) with ESMTP id i9JDgg4k029638
	for <nfs@lists.sourceforge.net>; Tue, 19 Oct 2004 15:42:42 +0200
Received: from anxur.fi.muni.cz (IDENT:11561@localhost [127.0.0.1])
	by anxur.fi.muni.cz (8.12.10/8.12.8) with ESMTP id i9JDgfc4023774
	for <nfs@lists.sourceforge.net>; Tue, 19 Oct 2004 15:42:41 +0200 (MEST)
Received: (from kas@localhost)
	by anxur.fi.muni.cz (8.12.10/8.12.8/Submit) id i9JDgfQg023773
	for nfs@lists.sourceforge.net; Tue, 19 Oct 2004 15:42:41 +0200 (MEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20041019133630.GR21046@fi.muni.cz>
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

	Another similar problem may be the one described in Red Hat
bugzilla id 127521:

	http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=127521

It is also related to wildcard/subnet exports as the one I posted today.

-Yenya

-- 
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - private}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18A5E |
| http://www.fi.muni.cz/~kas/   Czech Linux Homepage: http://www.linux.cz/ |
btw, David, I'm wondering about this loop: [...]  Is this
a busy-wait-until-someone-plugs-in-more-ram-chips thing? ;)  --Andrew Morton


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
