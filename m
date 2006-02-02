From: Ingo Lantschner <ingo.lists@vum.at>
Subject: SOLVED: udp port sunrpc unreachable
Date: Thu, 02 Feb 2006 19:25:27 +0100
Message-ID: <drtiqn$205$1@sea.gmane.org>
References: <drsiub$vok$1@sea.gmane.org>	 <1138890697.8894.2.camel@lade.trondhjem.org>	 <20060202151908.GB12118@fieldses.org>	 <1138893904.8894.11.camel@lade.trondhjem.org>	 <20060202152909.GC12118@fieldses.org> <1138894614.8894.13.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4jAn-0001nN-H8
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 10:27:13 -0800
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F4jAl-00080C-Tw
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 10:27:13 -0800
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1F4j9s-0007ZH-Po
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 19:26:16 +0100
Received: from 85-124-230-82.work.xdsl-line.inode.at ([85.124.230.82])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 02 Feb 2006 19:26:16 +0100
Received: from ingo.lists by 85-124-230-82.work.xdsl-line.inode.at with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 02 Feb 2006 19:26:16 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <1138894614.8894.13.camel@lade.trondhjem.org>
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


Hi all!
Thanks for your help - you hit the nail!! After comenting the obvious 
(and only) line in /etc/default/portmap anything went fine.

Trond Myklebust wrote:
>>>>I think that's actually the debian default setting these days; with the
>>>>debconf verbosity at the default, it should have asked you about this
>>>>when portmap was installed.  Just edit /etc/default/portmap to comment
>>>>out the obvious line.
>>>
>>>If true, then that would appear to be a rather ridiculous default. Have
>>>they put out a rationale for this?
>>
>>Nope, I'm wrong, the default is the opposite.  So probably someone chose the
>>more secure-sounding option at install time and then forgot about it....
No, it IS the default - I have never been asked (installed with apt-get 
install portmap). I use ubuntu Hoary.
May be, because it targets the desktop-user the default is only loopback.
Anyway, now its fine, thanks again to all who answered and helped.

Regards, Ingo.



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
