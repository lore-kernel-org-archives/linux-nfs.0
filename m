From: Frank van Maarseveen <frankvm@xs4all.nl>
Subject: chmod 1777 not working
Date: Thu, 19 Aug 2004 15:51:17 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040819135117.GA18593@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BxnKC-0005Eb-79
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 06:51:28 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BxnKA-0005yn-EB
	for nfs@lists.sourceforge.net; Thu, 19 Aug 2004 06:51:26 -0700
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
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

NFSv3, UDP.
client: 2.4.27 (RH9)

in a directory mounted from a HP OSF1 V5.1 1885 alpha server:

$ chmod 1777 .
$ chmod: changing permissions of `.' (requested: 1777, actual: 0777): Operation not permitted.

It did change the mode bits masked by 0777 however. Only the 01000 bit
didn't come through.

tcpdump:
15:42:35.644411 172.17.1.64.490930292 > 172.17.1.1.2049: 168 getattr fh 2878,245260/302892 (DF) (ttl 64, id 0, len 196)
15:42:35.644607 172.17.1.1.2049 > 172.17.1.64.490930292: reply ok 112 getattr DIR 755 ids 363/1522 sz 0x000002000  (ttl 60, id 51728, len 140)
15:42:35.644843 172.17.1.64.507707508 > 172.17.1.1.2049: 200 setattr fh 2878,245260/302892 (DF) (ttl 64, id 0, len 228)
15:42:35.645631 172.17.1.1.2049 > 172.17.1.64.507707508: reply ok 120 setattr POST: DIR 777 ids 363/1522 sz 0x000002000  (ttl 60, id 51729, len 148)
15:42:35.646924 172.17.1.64.524484724 > 172.17.1.1.2049: 168 getattr fh 2878,245260/302892 (DF) (ttl 64, id 0, len 196)
15:42:35.647127 172.17.1.1.2049 > 172.17.1.64.524484724: reply ok 112 getattr DIR 777 ids 363/1522 sz 0x000002000  (ttl 60, id 51732, len 140)

Against a Linux 2.4.26 server (NFSv3, UDP) works. tcpdump:
14:35:14.601275 172.17.1.64.842858612 > 172.17.1.66.2049: 156 getattr fh Unknown/1 (DF) (ttl 64, id 0, len 184)
14:35:14.601447 172.17.1.66.2049 > 172.17.1.64.842858612: reply ok 112 getattr DIR 40755 ids 363/1522 sz 0x000001000  (DF) (ttl 64, id 0, len 140)
14:35:14.601695 172.17.1.64.859635828 > 172.17.1.66.2049: 188 setattr fh Unknown/1 (DF) (ttl 64, id 0, len 216)
14:35:14.607469 172.17.1.66.2049 > 172.17.1.64.859635828: reply ok 120 setattr POST: DIR 41777 ids 363/1522 sz 0x000001000  (DF) (ttl 64, id 0, len 148)
14:35:14.607772 172.17.1.64.876413044 > 172.17.1.66.2049: 156 getattr fh Unknown/1 (DF) (ttl 64, id 0, len 184)
14:35:14.608009 172.17.1.66.2049 > 172.17.1.64.876413044: reply ok 112 getattr DIR 41777 ids 363/1522 sz 0x000001000  (DF) (ttl 64, id 0, len 140)

Notice that tcpdump reports "DIR xxx" in the bad case and "DIR 40xxx"
when it works. Significant?

-- 
Frank


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
