From: =?ISO-8859-1?Q?Sven_K=F6hler?= <skoehler@upb.de>
Subject: Re: export directory under different name
Date: Sun, 26 Sep 2004 20:56:06 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <415710C6.4010409@upb.de>
References: <cj4fts$6mm$1@sea.gmane.org> <17453.1096224299@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CBeBK-0005mO-1p
	for nfs@lists.sourceforge.net; Sun, 26 Sep 2004 11:55:34 -0700
Received: from mailgate.uni-paderborn.de ([131.234.22.32])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CBeBJ-000831-Dd
	for nfs@lists.sourceforge.net; Sun, 26 Sep 2004 11:55:33 -0700
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
In-Reply-To: <17453.1096224299@marajade.sandelman.ottawa.on.ca>
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

>   No, it is not. 
>   There is no theorectical reason why mountd can not do more complicated
> mappings before giving out file handles, but it does not (to my
> knowledge) do so.
>   It does follow symlinks, though.

Symlinks should be sufficient for me. I didn't expect mountd to follow 
symlinks, so i didn't try that. I just did, and it works as expected.

Thx
   Sven


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
