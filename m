From: Tony Reix <tony.reix@bull.net>
Subject: Re: NLM test suites : locks
Date: Mon, 20 Feb 2006 11:03:22 +0100
Message-ID: <1140429802.17001.175.camel@frecb000687.frec.bull.fr>
References: <7A16AC014E394147A587615D96BF666FBF6D1D@it.ssc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ROQUETA VINCENT <Vincent.Roqueta@ext.bull.net>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FB7tf-00064I-6a
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 02:03:59 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FB7tc-000349-Fc
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 02:03:59 -0800
To: dshaffer <dshaffer@ssc-corp.com>
In-Reply-To: <7A16AC014E394147A587615D96BF666FBF6D1D@it.ssc>
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

Hi Dan,

Le vendredi 17 f=E9vrier 2006 =E0 16:24 -0600, dshaffer a =E9crit :
>=20
>         I have been searching the Web without any luck. Are there any
> test suites that will test both synchronous and asynchronous (NLM V3 &
> 4 preferably) locking for either Redhat or Solaris?  I have SpecSFS,
> Cthon02, 03 and 04 but they do not test the asynchronous locking when
> I look at traces.

Have you looked at:
	http://nfsv4.bullopensource.org/archive.php?archive=3Dfull

There are 4 "News" talking about lock tests, starting at:
	http://nfsv4.bullopensource.org/tools/tests/page39.php


Is it what you need ?
If you need more details, please ask Vincent.

Regards,

Tony



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
