From: Steve Dickson <SteveD@redhat.com>
Subject: Re: RFC: mount.nfs
Date: Sat, 28 Aug 2004 13:21:37 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4130BF21.9000701@RedHat.com>
References: <20040827141529.GF23324@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C16tq-0006Eo-AS
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 10:21:58 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C16to-0002Nl-UH
	for nfs@lists.sourceforge.net; Sat, 28 Aug 2004 10:21:58 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040827141529.GF23324@suse.de>
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



Olaf Kirch wrote:

>Please find attached the code for mount.nfs, a drop-in replacement for
>the nfsmount code in mount(8). If you're adventurous, simply compile,
>and install in /sbin as mount.nfs.
>
>  
>
Nice!

>There's also no NFSv4 support yet, but if anyone would like to send
>me patches I will gladly incorporate them. I'm also open to design
>improvements that may make life for NFSv4 folks easier.
>  
>
Does it make senses to add NFS4 to this command or create a stand-alone
mount.nfs4 command as well? nfs4 is a separate filesystem type....

SteveD.


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
