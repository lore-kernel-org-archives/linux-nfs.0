From: Alan Glait <aglait@renatre.org.ar>
Subject: Errors ...
Date: Tue, 08 Nov 2005 10:41:40 -0300
Message-ID: <4370AB14.9020203@renatre.org.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EZTiA-0005d6-Rl
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 05:40:30 -0800
Received: from host132.200-45-109.telecom.net.ar ([200.45.109.132] helo=gate.renatre.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EZTiA-0003am-BH
	for nfs@lists.sourceforge.net; Tue, 08 Nov 2005 05:40:30 -0800
Received: from mx2.renatre.org.ar (mx2.renatre.org.ar [192.168.1.4])
	by gate.renatre.org (8.12.10/8.12.10) with ESMTP id jA8DeFnD013110
	for <nfs@lists.sourceforge.net>; Tue, 8 Nov 2005 10:40:15 -0300
Received: from [192.168.1.5] (unknown [192.168.1.5])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.renatre.org.ar (Postfix) with ESMTP id 13708619B
	for <nfs@lists.sourceforge.net>; Tue,  8 Nov 2005 10:51:37 -0300 (ART)
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

Hi !
I have an Fedora core 4 exporting a directory. It have 2.6.13 kernel.
I mount it on Red Hat Enterprise Linux AS release 3 with 2.4.21-4.ELsmp 
kernel. In the server, I get "svc: unknown version (0)" everytime. In 
the client i get :nfsd: last server has exited
                                                             nfsd: 
unexporting all filesystems
                                                             nfsd: last 
server has exited
                                                             nfsd: 
unexporting all filesystems
                                                             portmap: 
server localhost not responding, timed out
all time.
There is no problem but sometimes in the client it start to consume a 
lot of the processors and I cant to stop it. The service stop ok but it 
doesnt "release the usage" of th precessors ... in a top, a see iowait 
at 100% or 98% .

What can I do ??
thanx for any help



-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
