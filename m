From: Paul Stepowski <p.stepowski@qut.edu.au>
Subject: NFS honouring chattr +a
Date: Tue, 03 May 2005 15:29:07 +1000
Message-ID: <42770C23.8050403@qut.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DSpyE-0005v8-Qh
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 22:29:22 -0700
Received: from mail.qut.edu.au ([131.181.254.7] helo=mail-router01.qut.edu.au)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DSpyC-0003kH-9y
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 22:29:22 -0700
To: nfs@lists.sourceforge.net
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

Hi,

I've already searched the archives on this topic and didn't see anything useful. 
  I set up a test NFS server (v3) on a linux box and exported a partition 
rw,no_squash_root.  I set the attributes of a file in the exported partition as 
follows:

# chattr +a <file>

So the file is append only. When I attempt to read/write/append to the file I 
get a permission denied errror. Is there any way of getting NFS to honour this 
attribute as append only?

NOTE: I saw an archived post from Chris Mason suggesting a patch that looks like 
it will do what I'm asking, but there was no response to his message.

Thanks,

Paul


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
