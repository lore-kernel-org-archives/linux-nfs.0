From: Seb James <seb@peak.uklinux.net>
Subject: Re: NFS (and NIS) client causes server to semi-hang
Date: 12 Jun 2003 12:44:48 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1055418287.1984.38.camel@circle.hypercube>
References: <1055413060.1984.34.camel@circle.hypercube>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from s4.uklinux.net ([80.84.72.14] helo=mail2.uklinux.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19QQVj-0006WE-00
	for <nfs@lists.sourceforge.net>; Thu, 12 Jun 2003 04:44:55 -0700
Received: from localhost (s4.uklinux.net [127.0.0.1])
	by mail2.uklinux.net (Postfix) with ESMTP id B3C56409FD7
	for <nfs@lists.sourceforge.net>; Thu, 12 Jun 2003 11:44:50 +0000 (UTC)
Received: from mail2.uklinux.net ([127.0.0.1])
 by localhost (s4.uklinux.net [127.0.0.1:10024]) (amavisd-new) with ESMTP
 id 17150-05 for <nfs@lists.sourceforge.net>;
 Thu, 12 Jun 2003 12:44:48 +0100 (BST)
Received: from [192.168.0.2] (unknown [195.137.117.140])
	by mail2.uklinux.net (Postfix) with ESMTP id 6D8CB409FC2
	for <nfs@lists.sourceforge.net>; Thu, 12 Jun 2003 11:44:48 +0000 (UTC)
To: NFS Mailing list <nfs@lists.sourceforge.net>
In-Reply-To: <1055413060.1984.34.camel@circle.hypercube>
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

On Thu, 2003-06-12 at 11:17, Seb James wrote:
> Hello,
> 
> I've come across a rather worrying problem.

[ snip ]

> Does anyone have any ideas?
> 
> Also, is there a suitable NIS related list to post this message to, as I
> think it's relevant for that, too.


Fixed: darius was not listed in the /etc/hosts.allow file. However, it
doesn't seem right that such a problem should lead to the server
freezing up in the way that it did.

Cheers,

Seb.

-- 
Seb James <seb@peak.uklinux.net>



-------------------------------------------------------
This SF.NET email is sponsored by: eBay
Great deals on office technology -- on eBay now! Click here:
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
