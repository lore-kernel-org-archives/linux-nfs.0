From: Vince Busam <vbusam@google.com>
Subject: Re: mtime not updated in client cache?
Date: Mon, 12 Dec 2005 17:51:27 -0800
Message-ID: <439E291F.4000505@google.com>
References: <438B9C44.4030305@google.com>	 <1133225130.12178.9.camel@lade.trondhjem.org> <438E4CA7.2050405@google.com>	 <1133399727.8267.11.camel@lade.trondhjem.org> <43978AD2.8020000@google.com>		 <1134013082.8002.8.camel@lade.trondhjem.org> <43998F4C.6010902@redhat.com>	 <1134137783.8007.24.camel@lade.trondhjem.org> <439993B0.90801@redhat.com> <1134141589.8007.35.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ElzKS-0004lG-CB
	for nfs@lists.sourceforge.net; Mon, 12 Dec 2005 17:51:44 -0800
Received: from smtp-out.google.com ([216.239.45.12])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ElzKR-0001XO-BB
	for nfs@lists.sourceforge.net; Mon, 12 Dec 2005 17:51:44 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134141589.8007.35.camel@lade.trondhjem.org>
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

> Anyhow, the attached patch implements it. Lets try it out, and see how
> it does. Definitely _not_ a 2.6.15 candidate, though.

Without getting into the argument of whether this is the right thing to do or not, I will 
verify that this patch resolved the "problem" and that the example code acts as it does on 
2.4 and Solaris.

Thanks,
Vince


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
