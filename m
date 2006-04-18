From: "Gabor Z. Papp" <gzp@papp.hu>
Subject: Re: ANNOUNCE: nfs-utils 1.0.8 (final)
Date: Tue, 18 Apr 2006 08:58:02 +0200
Message-ID: <x6d5ff4bgl@gzp>
References: <17468.29136.672049.677855@cse.unsw.edu.au> <x6ek0018da@gzp>
	<17474.64699.722635.687707@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FVkA6-0005AR-H1
	for nfs@lists.sourceforge.net; Mon, 17 Apr 2006 23:58:10 -0700
Received: from odpn1.odpn.net ([212.40.96.53])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FVkA5-0002UV-7Y
	for nfs@lists.sourceforge.net; Mon, 17 Apr 2006 23:58:10 -0700
To: Neil Brown <neilb@suse.de>
Sender: nfs-admin@lists.sourceforge.net
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

* Neil Brown <neilb@suse.de>:

| > Probably my glibc is outdated, but works well. ;-)

| Probably it is.  It doesn't work well enough for nfs-utils :-(

| ifaddrs.h was added to glibc in July 2002, which I think was about
| 2.2.6.

Thought 2.2.5 was the latest from the 2.2 series. At least I can't see
2.2.6 on gnu.org. Anyway, I know its old and outdated for the current
tools, so I'm not complaining. ;-)

| I guess we should get 'configure' to check for ifaddrs, and exclude
| the code that uses it if not available.

| For now you can try backing out the following patch.

Compiles fine.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
