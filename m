From: Paul Jakma <paul@clubi.ie>
Subject: Re: Re: "nfs warning: mount version older than kernel" reported
 for 2.6.4 kernel on Fedora Core 1.0
Date: Sun, 4 Apr 2004 00:08:41 +0100 (IST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0404040006440.25515@hibernia.jakma.org>
References: <41089CB27BD8D24E8385C8003EDAF7AB084833@karl.alexa.com>
 <20040319184931.GF29237@perlsupport.com> <1079725155.2530.30.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Chip Salzenberg <chip@pobox.com>, Guolin Cheng <guolin@alexa.com>,
        "NFSUserList (E-mail)" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9uMz-00051A-Qg
	for nfs@lists.sourceforge.net; Sat, 03 Apr 2004 15:16:09 -0800
Received: from hibernia.jakma.org ([212.17.55.49])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1B9uMy-00082X-Vn
	for nfs@lists.sourceforge.net; Sat, 03 Apr 2004 15:16:09 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1079725155.2530.30.camel@lade.trondhjem.org>
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

On Fri, 19 Mar 2004, Trond Myklebust wrote:

> One such change is to allow NFSv2/v3 to use RPCSEC_GSS (BTW: we're
> *still* waiting to hear from this list about including the
> RPCSEC_GSS + NFSv4 support daemons into the official nfs-utils) 

I dont know what the pitfalls would be, but if there arent too many, 
my vote is "in". As soon as fedora has v4 enabled nfs-utils, i intend 
to try it with rpcsec_gss.

regards,
-- 
Paul Jakma	paul@clubi.ie	paul@jakma.org	Key ID: 64A2FF6A
	warning: do not ever send email to spam@dishone.st
Fortune:
There appears to be irrefutable evidence that the mere fact of overcrowding
induces violence.
		-- Harvey Wheeler


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
