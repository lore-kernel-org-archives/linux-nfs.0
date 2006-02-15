From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: query about clnt_create
Date: Wed, 15 Feb 2006 06:54:32 -0800 (PST)
Message-ID: <20060215145432.63194.qmail@web51604.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9O3E-0003E7-C4
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 06:54:40 -0800
Received: from web51604.mail.yahoo.com ([206.190.38.209])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1F9O3D-0001RN-1N
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 06:54:40 -0800
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
    Can clnt_create for NFS versions fail in any
    case due to security setting on NFS Sever ?
    Description: NFS client can mount exported FS.
    I have a small application which detects
    health of NFS server by creating client
    handle for required NFS version+protocol.
    Can this ever fail consistenly=20
    due to security or any other  =20
    settings on NFS server
    (nfs client system and server are connected to=20
    network, there is no hardware/(network load)=20
    problem and portmapper + all nfs daemons are=20
    runnnig)?
   =20
thanks,
 kiran
=20

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D103432&bid=3D230486&dat=3D=
121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
