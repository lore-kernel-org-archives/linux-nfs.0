From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: New version of nfs-utils please!
Date: Fri, 12 Sep 2003 16:45:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16225.27552.308538.665130@notabene.cse.unsw.edu.au>
References: <20030911153150.GA29368@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xhhE-0001tT-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Sep 2003 23:46:20 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19xhhD-0000IA-I8
	for nfs@lists.sourceforge.net; Thu, 11 Sep 2003 23:46:19 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <chip@pobox.com>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 12 Sep 2003 16:46:10 +1000
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: message from Chip Salzenberg on Thursday September 11
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

On Thursday September 11, chip@pobox.com wrote:
> I just fixed a crash bug in rpc.mountd and made an upload to Debian
> unstable, so Debian users are OK.  But what about everyone else?
> 
> Isn't it time to make a 1.0.6 version?

I guess so.  I've just fixed the reported 'statd segfaults' problem.

I've a long list of other things I want to fix, but they aren't
urgent, and they wont get done today!

I've updated configure and nfs-utils.spec.  If you would like to make
any appropriate changes to ChangeLog and debian/* to reflect the new
version number, I will tag it and make a release on Monday.

NeilBrown

(Thanks for fixing get_reliable_hostbyaddr.  That was my code.  I'm
ashamed....)



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
