From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: NFS server on startup on Redhat
Date: Thu, 09 Sep 2004 23:02:11 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4140C4D3.6070503@inf.ethz.ch>
References: <0CF6F73B3B779D43B160B85FD0CC2D37035C546D@xch-sw-07.sw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5Vzr-0008Ra-3w
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 13:58:23 -0700
Received: from xsmtp.ethz.ch ([129.132.97.6])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C5Vzo-00019i-1n
	for nfs@lists.sourceforge.net; Thu, 09 Sep 2004 13:58:22 -0700
To: "Hyatt, Daniel J" <daniel.j.hyatt@boeing.com>
In-Reply-To: <0CF6F73B3B779D43B160B85FD0CC2D37035C546D@xch-sw-07.sw.nos.boeing.com>
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

Hi Daniel,

chkconfig is your friend. `chkconfig nfs on` will do all the necessary 
stuff to start nfs upon boot.

Greetins,
	Marc

Hyatt, Daniel J wrote:
> But on startup it wont start the NFS server.



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
