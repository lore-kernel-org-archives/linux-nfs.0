From: Juri Haberland <list-linux.nfs@spoiled.org>
Subject: Re: limitations at 5,8 GB?
Date: Wed, 31 Dec 2003 09:56:42 +0000 (UTC)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <news2mail-bsu6gq$rfj$1@cartman.spoiled.org>
References: <200312251945.42382.nuway@gmx.net>
Reply-To: Juri Haberland <juri@koschikode.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1Abd5W-0005SM-Iz
	for nfs@lists.sourceforge.net; Wed, 31 Dec 2003 01:56:26 -0800
Received: from cartman.spoiled.org ([80.190.101.194] helo=a.mx.spoiled.org)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Abd5W-0000LT-5A
	for nfs@lists.sourceforge.net; Wed, 31 Dec 2003 01:56:26 -0800
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

Stefan Ewert <nuway@gmx.net> wrote:

> I got a 100 GIG harddisk on my server and i mounted it on my client without 
> any  warnings or problems. the only thing is that i now have 5.8 GB instead 
> of 100. Are there any restrictions in nfs protocol, or do u know a possible 
> solution for this prob?

I don't know where your problem is but there is no restriction of that
size in the NFS protocol.

This what I get from 'df' on one of my clients:
...
nfs:/export/data     160066688 150683400   9383288  95% /net/data
...

You can see that I can access an exported disk with the size of 160GB.

Cheers,
Juri

-- 
Juri Haberland  <juri@koschikode.com> 



-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
