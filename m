From: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Subject: Re: Re: An interesting performance thing ?
Date: Fri, 16 Dec 2005 11:15:49 +0100
Message-ID: <43A293D5.9020007@ext.bull.net>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>	<17312.39940.985507.704832@cse.unsw.edu.au>	<43A0A0D5.4040804@citi.umich.edu>	<018401c60108$c9477f30$1500000a@americas.hpqcorp.net> <17312.45710.867019.969182@cse.unsw.edu.au> <43A0BC49.3070604@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Neil Brown <neilb@suse.de>, Iozone <capps@iozone.org>,
	wli@holomorphy.com, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EnCc2-0003DA-GO
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 02:14:54 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EnCc0-0000CF-QT
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 02:14:54 -0800
To: cel@citi.umich.edu
In-Reply-To: <43A0BC49.3070604@citi.umich.edu>
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

Chuck Lever wrote:

> we might also think a little bit of the future (IPv6).
>
> IPv6 addresses are larger than IPv4 addresses, so they will need their=20
> own hash function, *or* we will have to design a reasonable hash=20
> function for variably-sized addresses now, which seems like a harder=20
> problem.

For information, in the IPv6 client support, we are currently using the=20
hash_long function by doing a xor operation between the four 32 bit=20
parts or an IPv6 address.

 static inline int ip_map_hash(struct ip_map *item)
 {
 	return hash_str(item->m_class, IP_HASHBITS) ^=20
-		hash_long((unsigned long)item->m_addr.s_addr, IP_HASHBITS);
+		hash_long((unsigned long)(item->m_addr.s6_addr32[0] ^
+			    item->m_addr.s6_addr32[1] ^
+			    item->m_addr.s6_addr32[2] ^
+			    item->m_addr.s6_addr32[3]), IP_HASHBITS);
 }

Regards,

Aur=E9lien



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
