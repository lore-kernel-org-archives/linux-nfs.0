From: Tom Tucker <tom@opengridcomputing.com>
Subject: Question about svc_age_temp_sockets
Date: Sun, 09 Sep 2007 12:33:44 -0500
Message-ID: <C30998A8.138C0%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUQeb-0001uA-9r
	for nfs@lists.sourceforge.net; Sun, 09 Sep 2007 10:33:01 -0700
Received: from mail.es335.com ([67.65.19.105])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUQef-0005bf-QQ
	for nfs@lists.sourceforge.net; Sun, 09 Sep 2007 10:33:06 -0700
Received: from [192.168.1.100] (unknown [10.10.105.1])
	by mail.es335.com (Postfix) with ESMTP id 506BAA0BE
	for <nfs@lists.sourceforge.net>; Sun,  9 Sep 2007 12:16:23 -0500 (CDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


I'm confused about how svc_age_temp_sockets is supposed to work. From my
reading, the timer fires every 6 minutes and calls the svc_age_temp_sockets
function. This function sweeps the tempsocks list and unconditionally
test_and_sets every transport SK_OLD. If it was the first to set it, it will
test if the transport's not busy and then shut it down. So here's what I
don't get:

- A transport that was added 5 minutes into the timer period, could get shut
down after only a minute of idleness

- A transport that was busy may _never_ get shutdown because it will already
have it's SK_OLD bit set when it comes back through 6 minutes later. If no
more requests ever arrive from the client, the SK_OLD bit will never get
reset and the test_and_set check skips the transport if the bit's already
set.

- There's a check for a zero sk_inuse count. I don't see a legitimate way
for a socket to be on the tempsocks list with a zero refcount.

Am I just hopelessly confused here or is this code broken?

Tom



-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
