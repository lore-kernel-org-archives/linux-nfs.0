From: Ian Kent <raven@themaw.net>
Subject: RE: RPC Time Out
Date: Fri, 5 Dec 2003 16:01:18 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0312051555290.12887-100000@wombat.indigo.net.au>
References: <NFBBLPFNOLCEIKDDCMDIMEEMCGAA.efw@fast.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ASAro-0002dA-TE
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 23:59:12 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1ASAro-0003fP-85
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 23:59:12 -0800
To: Gene & Marla Weber <efw@fast.net>
In-Reply-To: <NFBBLPFNOLCEIKDDCMDIMEEMCGAA.efw@fast.net>
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

On Thu, 4 Dec 2003, Gene & Marla Weber wrote:

>
> (Why /dev/hdc and not /dev/cdrom?)

/dev/cdrom is a soft link. exports are usually reduced to canonical from.

>
> But the next time I ran it I got an RPC timeout. Same with running
> showmount -e 192.186.2.57 on the client. One time it shows the two lines,
> other times it times out.

This is no good.

It must work always or nfs will not work.

Sorry I forget, but what does the rpcinfo -p show?

>From the client as

rpcinfo -p

and from the client as

rpcinfo -p <server ip>


-- 

   ,-._|\    Ian Kent
  /      \   Perth, Western Australia
  *_.--._/   E-mail: raven@themaw.net
        v    Web: http://themaw.net/



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
