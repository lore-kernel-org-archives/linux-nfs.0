From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH] SGI 900985: fix nohide export option for nfsv3
Date: Thu, 16 Oct 2003 12:40:19 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F8E0513.C9CC3590@melbourne.sgi.com>
References: <3F7CF147.B778D07B@melbourne.sgi.com>
		<16266.17267.491587.121802@notabene.cse.unsw.edu.au>
		<3F8A58E9.9A5D3102@melbourne.sgi.com> <16269.59642.406190.261861@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9y9Q-00014j-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Oct 2003 19:46:08 -0700
Received: from panoramix.vasoftware.com
	([198.186.202.147] helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A9y98-0006nf-Ds
	for nfs@lists.sourceforge.net; Wed, 15 Oct 2003 19:45:50 -0700
Received: from zok.sgi.com ([204.94.215.101]:57576)
	by externalmx.vasoftware.com with esmtp (Exim 4.22 #1 (Debian))
	id 1A9y7Q-000481-BR
	for <nfs@lists.sourceforge.net>; Wed, 15 Oct 2003 19:44:04 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Neil Brown wrote:
> 
> On Monday October 13, gnb@melbourne.sgi.com wrote:
> > The thing is, [...] Having it work on v2 and silently fail on v3 is
> > really submarvellous.
> 
> Certainly there is no suggestion of not supporting it for V3. 

Sorry, I missed your "Ok, thanks" for the first part of the diff.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
