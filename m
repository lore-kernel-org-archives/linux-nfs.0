From: Ian Kent <raven@themaw.net>
Subject: RE: auto-discovery of exports?
Date: Thu, 8 Apr 2004 08:37:25 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0404080836220.8254@wombat.indigo.net.au>
References: <41089CB27BD8D24E8385C8003EDAF7AB08484E@karl.alexa.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Michael <mogmios@mlug.missouri.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBNSP-0005JT-Nv
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 17:31:49 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BBNSO-0007qx-T5
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 17:31:49 -0700
To: Guolin Cheng <guolin@alexa.com>
In-Reply-To: <41089CB27BD8D24E8385C8003EDAF7AB08484E@karl.alexa.com>
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

On Wed, 7 Apr 2004, Guolin Cheng wrote:

> Hi, Michael,
> 
>  Run shell command "showmount -e|--exports <server_to_be_questioned>".
> If you would like to scan your network to check each host, run a for
> loop, and in the loop put another command "rpcinfo -p
> <server_to_be_questions>  |grep nfs" to make sure whether the nfs server
> is running on the host, if so, run the showmount command to query the
> exported file system from the host. 

Fine but how would you enumerate the hosts?
Would you restrict this to the local subnet?

Ian



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
