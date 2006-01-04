From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: virual hostname support for sm-notify on SuSE
Date: Tue, 3 Jan 2006 22:02:44 -0800 (PST)
Message-ID: <20060104060244.76161.qmail@web51613.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: okir@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Eu1ja-0006xe-Nx
	for nfs@lists.sourceforge.net; Tue, 03 Jan 2006 22:02:54 -0800
Received: from web51613.mail.yahoo.com ([68.142.224.86])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Eu1jY-0001R0-4G
	for nfs@lists.sourceforge.net; Tue, 03 Jan 2006 22:02:54 -0800
To: nfs@lists.sourceforge.net
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

Hi,
     I have noticed that
     sm-notify -v <virtual ip> works=20
     while sm-notify -v <virtual name> does not work.
     Virtual name may be required if nfs server fails=20
     over across subnets.
    =20

thanks,
 kiran


	=09
__________________________________________=20
Yahoo! DSL =96 Something to write home about.=20
Just $16.99/mo. or less.=20
dsl.yahoo.com=20



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
