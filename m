From: Wade Hampton <wade.hampton@nsc1.net>
Subject: Re: RE: Linux client on Solaris 7 NFS server
Date: Mon, 05 Jan 2004 14:46:04 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FF9BEFC.6030609@nsc1.net>
References: <200401051731.i05HVaa15457@supercomputer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Ian Kent <raven@themaw.net>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Adafw-0003WX-S6
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 11:46:08 -0800
Received: from www.nsc1.net ([4.22.175.200] helo=mail.nsc1.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Adafw-0004GV-Hb
	for nfs@lists.sourceforge.net; Mon, 05 Jan 2004 11:46:08 -0800
To: dwight@supercomputer.org
In-Reply-To: <200401051731.i05HVaa15457@supercomputer.org>
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

Slightly off topic, but have either of you seen a problem with
a Solaris 7 server locking up or having networking problems
when moving data to a linux client (read only)?

I was locked up my solaris 7 x86 server several times
with Fedora 1.0 (kernel 2.4.22-1.2115).  I changed
rsize=32768,wsize=32768 and have not seen a problem
since.

Thanks,
--
Wade Hampton




-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
