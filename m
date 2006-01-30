From: Olaf Kirch <okir@suse.de>
Subject: Re: virtual hostname support for sm-notify on SuSE
Date: Mon, 30 Jan 2006 10:56:52 +0100
Message-ID: <20060130095652.GC421@suse.de>
References: <OF322A73D5.EFCAF050-ON88257104.000C2815-88257104.000CB1F4@us.ibm.com> <43DAD784.8050409@almaden.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mehta kiran <kiranmehta1981@yahoo.com>,
	nfs@lists.sourceforge.net, nfs-admin@lists.sourceforge.net,
	Manoj Naik <manoj@almaden.ibm.com>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Marc Eshel <eshel@almaden.ibm.com>
In-Reply-To: <43DAD784.8050409@almaden.ibm.com>
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

Hi Marc,

I don't remember seeing that request, sorry. 

SLES10 will have a fix for this (which uses getaddrinfo rather than
gethostbyname, but otherwise it should work the same way as your patch)

Thanks,
Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
