From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH RFC 1/1] NLM GRANTED callback race
Date: Wed, 17 Oct 2007 19:25:19 -0400
Message-ID: <EXNANE01Gh05YFRcmVF00000752@exnane01.hq.netapp.com>
References: <EXNANE01OSQeSOzNCWb00000734@exnane01.hq.netapp.com>
	<1192639478.7573.50.camel@heimdal.trondhjem.org>
	<EXNANE013Bma4RCIlWr00000742@exnane01.hq.netapp.com>
	<20071017192340.GK2328@fieldses.org>
	<EXNANE01NMjiGwYt7yi00000750@exnane01.hq.netapp.com>
	<20071017222549.GQ2328@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IiIGU-0003dp-Ms
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 16:25:27 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IiIGZ-0000lL-0X
	for nfs@lists.sourceforge.net; Wed, 17 Oct 2007 16:25:32 -0700
In-Reply-To: <20071017222549.GQ2328@fieldses.org>
References: <EXNANE01OSQeSOzNCWb00000734@exnane01.hq.netapp.com>
	<1192639478.7573.50.camel@heimdal.trondhjem.org>
	<EXNANE013Bma4RCIlWr00000742@exnane01.hq.netapp.com>
	<20071017192340.GK2328@fieldses.org>
	<EXNANE01NMjiGwYt7yi00000750@exnane01.hq.netapp.com>
	<20071017222549.GQ2328@fieldses.org>
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

At 06:25 PM 10/17/2007, J. Bruce Fields wrote:
>OK.  But it's possible it might be a slightly different race?  Your
>description of the race certainly doesn't match my understanding of the
>server nlm code, but of course it's possible I could be missing
>something.

To be clear, I first detected this error when serving off a NetApp filer.
I believe a similar issue can occur with a Linux server, but the manifestation
may well be different. It's just as serious (false locks, data corruption,
and client deadlock).

I'll drop you a line tomorrow.

Tom.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
