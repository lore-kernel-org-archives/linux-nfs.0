From: <trond.myklebust@fys.uio.no>
Subject: Re: nfsroot & RPC_AUTH_NULL
Date: Mon, 12 Jan 2004 17:38:45 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <34126.68.42.103.198.1073925525.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Ag57V-0000im-FH
	for nfs@lists.sourceforge.net; Mon, 12 Jan 2004 08:40:53 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Ag57V-00080I-0E
	for nfs@lists.sourceforge.net; Mon, 12 Jan 2004 08:40:53 -0800
To: <martin.wilck@fujitsu-siemens.com>
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

På må , 12/01/2004 klokka 07:24, skreiv Martin Wilck:
> Can the above mentioned patch have any adverse effects?
> If no, is there any reason why it did not become part of either the
> mainline kernel or the patch collection at
> http://www.fys.uio.no/%7Etrondmy/src/ ?

No reason at all. Please just blame my failing memory for not having
done so already.

I'll try to get this done over the next couple of days together with the
other patches that are missing: There are the locking patches - anything
else?.

Cheers,
  Trond





-------------------------------------------------------
This SF.net email is sponsored by: Perforce Software.
Perforce is the Fast Software Configuration Management System offering
advanced branching capabilities and atomic changes on 50+ platforms.
Free Eval! http://www.perforce.com/perforce/loadprog.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
