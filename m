From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Performance udp vs. tcp
Date: Mon, 23 Aug 2004 11:57:40 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4129BF94.20902@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BzBaj-0002Ck-Vy
	for nfs@lists.sourceforge.net; Mon, 23 Aug 2004 02:58:17 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BzBai-00055s-8k
	for nfs@lists.sourceforge.net; Mon, 23 Aug 2004 02:58:17 -0700
Received: from internaldeliver.acheron.informatik.uni-muenchen.de (localhost [127.0.0.1])
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 06DAC43594
	for <nfs@lists.sourceforge.net>; Mon, 23 Aug 2004 11:57:42 +0200 (CEST)
Received: from [141.84.1.141] (galois.bio.ifi.lmu.de [141.84.1.141])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id EDA254358C
	for <nfs@lists.sourceforge.net>; Mon, 23 Aug 2004 11:57:41 +0200 (CEST)
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

Hi,

I just ran some bonnie++ tests to measure the nfs performance of udp vs.
tcp, expecting tcp to be better (after reading this list and some newsgroups).
Amazingly, it turned out that udp with rsize/wsize 16k was the best, taking
the average over all tests. tcp was a little better in some of the large-file
tests, but especially with creating/stating/deleting 16 thousands of small
file, sequentially and randomly, udp was better than tcp in every test
(between 5-15 % faster). I rann all the tests also with differenct tcp windows
sizes, and a larger window size speeded up udp and tcp more or less in the
same way.

I was very amazed by this, but I guess this could be caused by our network,
which is a fully switched "100mbit for client/1gbit for servers" network,
so we have almost no packet loss.

If I got the discussions on the list and in the newsgroups right, on a
lossy network udp would slow down due to the packet loss and resends.

So, can my result be correct for a really fast and stable network? Or is
it some "bonnie++ likes udp" effect? :-)

cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
