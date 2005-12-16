From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd ] Fix hash function for IP addresses on 64bit little-endian machines.
Date: Fri, 16 Dec 2005 15:22:04 +1100
Message-ID: <1051216042204.5009@cse.unsw.edu.au>
References: <20051216152056.4989.patches@notabene>
Cc: "Iozone" <capps@iozone.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1En76k-0004Gi-6F
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 20:22:14 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1En76j-0007Q7-RN
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 20:22:14 -0800
To: Andrew Morton <akpm@osdl.org>
Cc: nfs@lists.sourceforge.net
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

This patch against 2.6.15-rc5-mm2 is suitable, but not critical, for 2.6.15.

--
The hash.h hash_long function, when used on a 64 bit machine, ignores
many of the middle-order bits. (The prime chosen it too bit-sparse).

IP addresses for clients of an NFS server are very likely to differ
only in the low-order bits.  As addresses are stored in
network-byte-order, these bits become middle-order bits in a
little-endian 64bit 'long', and so do not contribute to the hash.
Thus you can have the situation where all clients appear on one hash chain.

So, until hash_long is fixed (or maybe forever), us a hash function
that works well on IP addresses - xor the bytes together.

Thanks to "Iozone" <capps@iozone.org> for identifying this problem.

Cc: "Iozone" <capps@iozone.org>

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcauth_unix.c |   14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff ./net/sunrpc/svcauth_unix.c~current~ ./net/sunrpc/svcauth_unix.c
--- ./net/sunrpc/svcauth_unix.c~current~	2005-12-16 15:10:12.000000000 +1100
+++ ./net/sunrpc/svcauth_unix.c	2005-12-16 15:12:00.000000000 +1100
@@ -101,10 +101,22 @@ static void ip_map_put(struct cache_head
 	}
 }
 
+#if IP_HASHBITS == 8
+/* hash_long on a 64 bit machine is currently REALLY BAD for
+ * IP addresses in reverse-endian (i.e. on a little-endian machine).
+ * So use a trivial but reliable hash instead
+ */
+static inline int hash_ip(unsigned long ip)
+{
+	int hash = ip ^ (ip>>16);
+	return (hash ^ (hash>>8)) & 0xff;
+}
+#endif
+
 static inline int ip_map_hash(struct ip_map *item)
 {
 	return hash_str(item->m_class, IP_HASHBITS) ^ 
-		hash_long((unsigned long)item->m_addr.s_addr, IP_HASHBITS);
+		hash_ip((unsigned long)item->m_addr.s_addr);
 }
 static inline int ip_map_match(struct ip_map *item, struct ip_map *tmp)
 {


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
