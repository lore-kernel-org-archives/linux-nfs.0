From: Steve Dickson <SteveD@redhat.com>
Subject: Re: 'random' diskless clients hangs
Date: Wed, 03 Sep 2003 14:02:13 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F562CA5.7030002@RedHat.com>
References: <NEBBIHNAFKJAFOHBHGCOKEHLEFAA.robert@heessels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ubwJ-0002aI-00
	for <nfs@lists.sourceforge.net>; Wed, 03 Sep 2003 11:01:07 -0700
Received: from pix-525-pool.redhat.com ([66.187.233.200] helo=lacrosse.corp.redhat.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19ubwI-0000qj-TX
	for nfs@lists.sourceforge.net; Wed, 03 Sep 2003 11:01:07 -0700
To: Robert Heessels <robert@heessels.com>
In-Reply-To: <NEBBIHNAFKJAFOHBHGCOKEHLEFAA.robert@heessels.com>
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

Hello,

Robert Heessels wrote:

>All clients run fine for days at a time, but every now and then a client
>hangs. Most of the time the process that is probably causing the hang is
>either rhn_check (from Red Hat Network) or httpsd with user psaadm (from
>Plesk 6.0.1).
>
This is simply not enough information to even try to guess what's
happening... Have you tried upgrading to a more recent kernel to see
if the problem goes away?

SteveD.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
