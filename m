From: Alex Thiel <alex.lists@freenet.de>
Subject: Re: Doubly mounting same directory
Date: Mon, 29 Jul 2002 12:33:18 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207291233.19518.alex.lists@freenet.de>
References: <20020726182729H.miyoshi@hpc.bs1.fc.nec.co.jp>
Reply-To: alex.lists@freenet.de
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Z7q0-00014V-00
	for <nfs@lists.sourceforge.net>; Mon, 29 Jul 2002 03:33:16 -0700
Received: from ix.urz.uni-heidelberg.de (mail.urz.uni-heidelberg.de [129.206.119.234])
	by relay.uni-heidelberg.de (8.12.4/8.12.4) with ESMTP id g6TAXBU5020824
	for <nfs@lists.sourceforge.net>; Mon, 29 Jul 2002 12:33:11 +0200 (MET DST)
Received: from extmail.urz.uni-heidelberg.de (extmail.urz.uni-heidelberg.de [129.206.100.140])
	by ix.urz.uni-heidelberg.de (8.8.8/8.8.8) with SMTP id MAA31296
	for <nfs@lists.sourceforge.net>; Mon, 29 Jul 2002 12:33:11 +0200
To: miyoshi@hpc.bs1.fc.nec.co.jp, nfs@lists.sourceforge.net
In-Reply-To: <20020726182729H.miyoshi@hpc.bs1.fc.nec.co.jp>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Friday 26 July 2002 11:27, miyoshi@hpc.bs1.fc.nec.co.jp wrote:
> Hi, all.
>
> I am newbie to NFS, and I have a question about Linux NFS.
>
> On most unix systems, mounting the same remote directory to
> the same local mount point will cause mount error.
>
> On linux boxes, we can do that without error.
> It seems there are some semantic difference between
> Linux NFS and other implementations,
> but what is the difference?
>
> Thanks,

This is not an NFS issue; you can do this with local drives also. As far =
as I=20
can remember the semantics changed in the 2.4.x kernel series.

Regards,

=09Alex




-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
