From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: nfs_statfs: statfs error = 116
Date: Fri, 14 Nov 2003 15:57:08 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB4ED44.9030109@inf.ethz.ch>
References: <3F698142.6070404@inf.ethz.ch> <200309182124.08706.bernd-schubert@web.de> <1063913505.1552.30.camel@localhost> <200309182149.02062.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKfNp-0008UD-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Nov 2003 06:57:13 -0800
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AKfNo-0003Rj-MM
	for nfs@lists.sourceforge.net; Fri, 14 Nov 2003 06:57:12 -0800
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200309182149.02062.bernd-schubert@web.de>
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

Hi Bernd,

Thanks for that hint, I've used it a couple of times meanwhile and it 
works fine.

    Marc

Bernd Schubert wrote:

> No, no, I simply mean:
>
>mount -t nfs server:export_dir   target_dir 
>
>so just 'overmounting' the already mounted directory.
>
>Hope it helps,
>Bernd
>  
>



-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
