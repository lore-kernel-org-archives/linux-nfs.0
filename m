From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 16:57:35 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0411221653180.5313@chaos.egr.duke.edu>
References: <20041122214605.8E2B31D0FE1@sc8-sf-uberspam1.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWMBn-0006Z2-4Q
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 13:57:39 -0800
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CWMBm-00087N-3N
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 13:57:39 -0800
Received: from chaos.egr.duke.edu (localhost.localdomain [127.0.0.1])
	by chaos.egr.duke.edu (8.12.11/8.12.11) with ESMTP id iAMLvZwC027809
	for <nfs@lists.sourceforge.net>; Mon, 22 Nov 2004 16:57:35 -0500
Received: from localhost (jlb@localhost)
	by chaos.egr.duke.edu (8.12.11/8.12.11/Submit) with ESMTP id iAMLvZ1U027805
	for <nfs@lists.sourceforge.net>; Mon, 22 Nov 2004 16:57:35 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <20041122214605.8E2B31D0FE1@sc8-sf-uberspam1.sourceforge.net>
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

On Mon, 22 Nov 2004 at 1:45pm, jehan.procaccia@int-evry.fr wrote

> Anyone is getting the same performance as me in server sync mode ?, if 
> someone could just tar xvfz any recent httpd.tar.gz file (nearly 3000 
> source files) and let me know how it take on their nfs configuration ?

Server: RH7.3, sync export
Client: Centos 3.3 (RHEL 3 U3 rebuild), async mount, UDP, 8K r/wsize

[jlb@chaos tmp]$ time tar xzf ~/tmp/httpd-2.0.52.tar.gz 

real    0m25.522s
user    0m0.520s
sys     0m0.560s

-- 
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
