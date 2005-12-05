From: Dale Blount <linux-nfs@dale.us>
Subject: NFS tracing script
Date: Mon, 05 Dec 2005 10:47:24 -0500
Message-ID: <1133797644.17027.17.camel@dale.velocity.net>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EjIZ0-0005qw-2J
	for nfs@lists.sourceforge.net; Mon, 05 Dec 2005 07:47:38 -0800
Received: from mail.velocity.net ([66.211.211.55])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EjIYy-0001GJ-Nb
	for nfs@lists.sourceforge.net; Mon, 05 Dec 2005 07:47:38 -0800
Received: from dale.velocity.net (dale.velocity.net [66.211.211.211])
	by mail.velocity.net (Postfix) with ESMTP id 141C81773A6
	for <nfs@lists.sourceforge.net>; Mon,  5 Dec 2005 10:47:25 -0500 (EST)
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

Hello List,

I'm looking for a tool to analyze what requests my Linux 2.6 NFS server
handles.  It has around 10 clients (all Linux 2.6), each with a
different load pattern.

I remember reading about a set of (perl?) scripts to parse the output of
tcpdump from an nfs server to analyze the requests.  Does anyone know
where these are? or if a better tool exists?  I'm mainly looking for
host breakdowns and getting the filename back from the request.

Thanks,

Dale



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
