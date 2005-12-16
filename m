From: "Iozone" <capps@iozone.org>
Subject: Re: Re: An interesting performance thing ?
Date: Fri, 16 Dec 2005 08:23:32 -0600
Message-ID: <059c01c6024c$4b3851b0$1500000a@americas.hpqcorp.net>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>
 <17312.39940.985507.704832@cse.unsw.edu.au>	<43A0A0D5.4040804@citi.umich.edu>
 <018401c60108$c9477f30$1500000a@americas.hpqcorp.net>
 <17312.45710.867019.969182@cse.unsw.edu.au> <43A0BC49.3070604@citi.umich.edu>
 <43A293D5.9020007@ext.bull.net>
Reply-To: "Iozone" <capps@iozone.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=iso-8859-1; reply-type=response
Cc: "Neil Brown" <neilb@suse.de>, <wli@holomorphy.com>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EnGUj-0002Tj-4f
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 06:23:37 -0800
Received: from vms040pub.verizon.net ([206.46.252.40])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EnGUh-0000xD-O4
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 06:23:37 -0800
Received: from cappsnc ([71.96.135.143])
 by vms040.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0IRL001DGHB89QA0@vms040.mailsrvcs.net> for
 nfs@lists.sourceforge.net; Fri, 16 Dec 2005 08:23:33 -0600 (CST)
To: =?iso-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>,
	<cel@citi.umich.edu>
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


----- Original Message -----=20
=46rom: "Aur=E9lien Charbon" <aurelien.charbon@ext.bull.net>
To: <cel@citi.umich.edu>
Cc: "Neil Brown" <neilb@suse.de>; "Iozone" <capps@iozone.org>;=20
<wli@holomorphy.com>; <nfs@lists.sourceforge.net>
Sent: Friday, December 16, 2005 4:15 AM
Subject: Re: [NFS] Re: An interesting performance thing ?


Chuck Lever wrote:

> we might also think a little bit of the future (IPv6).
>
> IPv6 addresses are larger than IPv4 addresses, so they will need th=
eir own=20
> hash function, *or* we will have to design a reasonable hash functi=
on for=20
> variably-sized addresses now, which seems like a harder problem.

For information, in the IPv6 client support, we are currently using t=
he
hash_long function by doing a xor operation between the four 32 bit
parts or an IPv6 address.

 static inline int ip_map_hash(struct ip_map *item)
 {
  return hash_str(item->m_class, IP_HASHBITS) ^
- hash_long((unsigned long)item->m_addr.s_addr, IP_HASHBITS);
+ hash_long((unsigned long)(item->m_addr.s6_addr32[0] ^
+     item->m_addr.s6_addr32[1] ^
+     item->m_addr.s6_addr32[2] ^
+     item->m_addr.s6_addr32[3]), IP_HASHBITS);
 }

Regards,

Aur=E9lien
-------------

Aur=E9lien,

    Perhaps in the future one might consider using Neil's new
    hash for IP addresses ?  Something like:

 static inline int ip_map_hash(struct ip_map *item)
 {
  return hash_str(item->m_class, IP_HASHBITS) ^
- hash_long((unsigned long)item->m_addr.s_addr, IP_HASHBITS);
+ hash_ip((unsigned long)(item->m_addr.s6_addr32[0] ^
+     item->m_addr.s6_addr32[1] ^
+     item->m_addr.s6_addr32[2] ^
+     item->m_addr.s6_addr32[3]));
 }

Enjoy,
Don Capps








-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
