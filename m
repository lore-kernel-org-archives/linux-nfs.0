From: Christopher Huhn <C.Huhn@gsi.de>
Subject: executable but not readable
Date: Thu, 25 Mar 2004 19:00:18 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40631E32.1020707@gsi.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6Z9c-0000G2-99
	for nfs@lists.sourceforge.net; Thu, 25 Mar 2004 10:00:32 -0800
Received: from lxmta2.gsi.de ([140.181.67.43])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B6Z9b-0003z9-Sa
	for nfs@lists.sourceforge.net; Thu, 25 Mar 2004 10:00:32 -0800
Received: from localhost (localhost [127.0.0.1])
	by lxmta2.gsi.de (Postfix) with ESMTP id C80CC1926CB
	for <nfs@lists.sourceforge.net>; Thu, 25 Mar 2004 19:00:23 +0100 (CET)
Received: from lxmta2.gsi.de ([127.0.0.1])
	by localhost (lxmta2 [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 03549-89 for <nfs@lists.sourceforge.net>;
	Thu, 25 Mar 2004 19:00:19 +0100 (CET)
Received: from gsi.de (lxg0815.gsi.de [140.181.70.60])
	by lxmta2.gsi.de (Postfix) with ESMTP id 1D2371926C1
	for <nfs@lists.sourceforge.net>; Thu, 25 Mar 2004 19:00:19 +0100 (CET)
To: nfs@lists.sourceforge.net
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

Hi alltogether,

(I'm sorry to bother you with this but I could not find any clues yet)

Szenario:

   * a server exports shell scripts to clients with root_squash
   * these scripts have -rwx-r-x--x (root:root) rights (executable but 
not readable)

The clients are able to run these scripts with server kernel version 2.4.20.
Now we switched the server to 2.4.25 and get "permission denied" on 
execution.

As far as I comprehend file permissions this should never have worked?
But nobody ever noticed as long as it worked and the guy in charge says: 
"This was always a feature on VMS." :-P  

This assumption is confirmed by the fact that "su nobody -c 
/usr/local/sbin/mkclonediskremupdate" executed on the server does not 
work either.

Are these observations correct or am I missing something?

Sorry for the silly question.

Regards,

    Christopher


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
