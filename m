From: Chip Salzenberg <chip@pobox.com>
Subject: Proposal: Rename log() function due to conflict with ISO standard
Date: Wed, 20 Aug 2003 17:58:35 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030820215835.GA14355@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19payi-0002CV-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Aug 2003 14:58:52 -0700
Received: from tytlal.hmsonline.com
	([207.43.94.202] helo=tytlal ident=mail)
	by tandu.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 19payA-0005I6-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Aug 2003 14:58:18 -0700
Received: from chip by tytlal with local (Exim 3.35 #1 (Debian))
	id 19payR-0004am-00
	for <nfs@lists.sourceforge.net>; Wed, 20 Aug 2003 17:58:35 -0400
To: nfs@lists.sourceforge.net
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

ISO C reserves the names of standard functions.  It's not legal to
define a function called log(), and even though gcc happens to permit
it, the permission comes only with obnoxious warnings.

What say I rename this function to something else?  (Suggestions?)
-- 
Chip Salzenberg               - a.k.a. -               <chip@pobox.com>
"I wanted to play hopscotch with the impenetrable mystery of existence,
    but he stepped in a wormhole and had to go in early."  // MST3K


-------------------------------------------------------
This SF.net email is sponsored by Dice.com.
Did you know that Dice has over 25,000 tech jobs available today? From
careers in IT to Engineering to Tech Sales, Dice has tech jobs from the
best hiring companies. http://www.dice.com/index.epl?rel_code=104
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
