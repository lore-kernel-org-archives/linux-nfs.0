From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: NFS server not responding
Date: Fri, 5 Dec 2003 16:50:55 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0312051646330.15003-100000@kenzo.iwr.uni-heidelberg.de>
References: <shsr7zk5sw4.fsf@guts.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Steve Dickson <SteveD@redhat.com>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ASIEQ-0003Aj-Gv
	for nfs@lists.sourceforge.net; Fri, 05 Dec 2003 07:51:02 -0800
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ASIEP-0003DT-TB
	for nfs@lists.sourceforge.net; Fri, 05 Dec 2003 07:51:02 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsr7zk5sw4.fsf@guts.uio.no>
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

On 4 Dec 2003, Trond Myklebust wrote:

> This might indeed explain why people are seeing an increase in resends
> and 'server not responding' messages.

It does not explain my case though... Going from <=2.4.18 to the FC1
kernel means an increase in timeout value.

But still no time to go deeper...

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
