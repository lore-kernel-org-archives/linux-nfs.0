From: "Carl Gherardi" <Carl.Gherardi@nautronix.com.au>
Subject: Nfs stale file handles
Date: Fri, 9 May 2003 14:22:57 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CDF67C45E6F8384B996AC26A3B805782568785@exch-fremantle.nautronix>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 073.005.dsl.pth.iprimus.net.au ([203.134.183.73] helo=nautronix.com.au)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19E1Ha-0002Pu-00
	for <nfs@lists.sourceforge.net>; Thu, 08 May 2003 23:23:03 -0700
To: <nfs@lists.sourceforge.net>
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

Hi all,

I haven't been able to find anything in the archives about my problem so
I thought I'd post.

I'm running a bunch of Redhat 7.3 boxes that all automount various
directories on 2 servers.

Every time I adjust an export (add/remove or change map) I reexport the
file system and things work for about an hour or two, then I get a
series of reports of stale file hadles, and noone can mount several
(read as random) directories.

Running exportfs -r fixes the problem until the next time I adjust the
exports.

Has anyone experienced anything similar?

Thanks

Carl

NB: Locked into vendor kernels cause of a binary only fibre channel
card.
NBB: Sorry about crap to follow.=20


This email is confidential and intended solely for the use of the =
individual to=20
whom it is addressed.  Any views or opinions presented are solely those =
of the=20
author and do not necessarily represent those of Nautronix Ltd.

If you are not the intended recipient, you have received this email in =
error and
use, dissemination, forwarding, printing, or copying of this email is =
strictly
prohibited.  If you have received this email in error please contact the =
sender.

Although our computer systems use active virus protection software, and =
we take
various measures to reduce the risk of viruses being transmitted in =
e-mail
messages and attachments sent from this company, we cannot guarantee =
that such
e-mail messages and attachments are free from viruses on receipt.  It is =
a
condition of our using e-mail to correspond with you, that any and all =
liability
on our part arising directly or indirectly out of any virus is excluded.
Please ensure that you run virus checking software on all e-mail =
messages and
attachments before reading them.



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
