From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: File monitoring
Date: Sat, 27 Jan 2007 16:41:36 -0500
Message-ID: <1169934096.5976.23.camel@lade.trondhjem.org>
References: <Pine.LNX.4.61.0701272123470.22295@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Jan Engelhardt <jengelh@linux01.gwdg.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HAvJ7-0001Q1-Hb
	for nfs@lists.sourceforge.net; Sat, 27 Jan 2007 13:41:57 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18ew1pPFrrOV7HQli6Ms7JTM2vAmc+pwNI=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HAvJ9-0007mr-5R
	for nfs@lists.sourceforge.net; Sat, 27 Jan 2007 13:41:59 -0800
In-Reply-To: <Pine.LNX.4.61.0701272123470.22295@yvahk01.tjqt.qr>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sat, 2007-01-27 at 21:31 +0100, Jan Engelhardt wrote:
> Hello list,
> 
> 
> as part of implementing a netboot solution, I observe that the client 
> pulls about 128 MB of data (measured in iptraf, so it includes 
> IPv4 headers too). You probably agree that this contributes to a boot 
> that could possibly be sped up (even if the same distribution was to 
> read from local disk). I wonder what files it actually accesses. Is 
> there some utility to get a listing of all the files that were accessed? 
> tcpdump provides a nice hint, e.g.
> 
> 21:29:09.877364 IP 192.168.222.34.3204330825 > 192.168.222.1.2049: 116 
> lookup fh 
> Unknown/0100000100160005118A180EF8B50D0D000000000000001068616C2D6765742D  
> "hal-get-property"
> 
> But at best I'd like to have the full pathname (to distinguish the 
> fictional case /bin/cat vs /usr/bin/cat)

Filehandles do not normally contain path information, but
Ethereal/Wireshark does have the ability to use the above LOOKUP
information to construct a reverse map, so you might want to try that.

Otherwise, the only way to do it is to use something like the "strace"
utility in order to ptrace the open() syscalls.

  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
