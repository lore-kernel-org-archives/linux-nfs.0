From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 4] knfsd: Remove CONFIG_IPV6 ifdefs from sunrpc
	server code.
Date: Tue, 6 Mar 2007 13:15:10 +1100
Message-ID: <1070306021510.26907@suse.de>
References: <20070306131103.26638.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOPEC-0006hi-MP
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 18:16:36 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HOPEE-0007yb-2g
	for nfs@lists.sourceforge.net; Mon, 05 Mar 2007 18:16:38 -0800
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


They don't really save that much, and aren't worth the hassle.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./include/linux/sunrpc/svc.h |    2 --
 ./net/sunrpc/svcsock.c       |   13 +++----------
 2 files changed, 3 insertions(+), 12 deletions(-)

diff .prev/include/linux/sunrpc/svc.h ./include/linux/sunrpc/svc.h
--- .prev/include/linux/sunrpc/svc.h	2007-03-06 11:02:46.000000000 +1100
+++ ./include/linux/sunrpc/svc.h	2007-03-06 11:12:40.000000000 +1100
@@ -194,9 +194,7 @@ static inline void svc_putu32(struct kve
 
 union svc_addr_u {
     struct in_addr	addr;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
     struct in6_addr	addr6;
-#endif
 };
 
 /*

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2007-03-06 11:10:09.000000000 +1100
+++ ./net/sunrpc/svcsock.c	2007-03-06 11:12:40.000000000 +1100
@@ -131,13 +131,13 @@ static char *__svc_print_addr(struct soc
 			NIPQUAD(((struct sockaddr_in *) addr)->sin_addr),
 			htons(((struct sockaddr_in *) addr)->sin_port));
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+
 	case AF_INET6:
 		snprintf(buf, len, "%x:%x:%x:%x:%x:%x:%x:%x, port=%u",
 			NIP6(((struct sockaddr_in6 *) addr)->sin6_addr),
 			htons(((struct sockaddr_in6 *) addr)->sin6_port));
 		break;
-#endif
+
 	default:
 		snprintf(buf, len, "unknown address type: %d", addr->sa_family);
 		break;
@@ -449,9 +449,7 @@ svc_wake_up(struct svc_serv *serv)
 
 union svc_pktinfo_u {
 	struct in_pktinfo pkti;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	struct in6_pktinfo pkti6;
-#endif
 };
 
 static void svc_set_cmsg_data(struct svc_rqst *rqstp, struct cmsghdr *cmh)
@@ -467,7 +465,7 @@ static void svc_set_cmsg_data(struct svc
 			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
 		}
 		break;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+
 	case AF_INET6: {
 			struct in6_pktinfo *pki = CMSG_DATA(cmh);
 
@@ -479,7 +477,6 @@ static void svc_set_cmsg_data(struct svc
 			cmh->cmsg_len = CMSG_LEN(sizeof(*pki));
 		}
 		break;
-#endif
 	}
 	return;
 }
@@ -730,13 +727,11 @@ static inline void svc_udp_get_dest_addr
 		rqstp->rq_daddr.addr.s_addr = pki->ipi_spec_dst.s_addr;
 		break;
 		}
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6: {
 		struct in6_pktinfo *pki = CMSG_DATA(cmh);
 		ipv6_addr_copy(&rqstp->rq_daddr.addr6, &pki->ipi6_addr);
 		break;
 		}
-#endif
 	}
 }
 
@@ -985,11 +980,9 @@ static inline int svc_port_is_privileged
 	case AF_INET:
 		return ntohs(((struct sockaddr_in *)sin)->sin_port)
 			< PROT_SOCK;
-#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case AF_INET6:
 		return ntohs(((struct sockaddr_in6 *)sin)->sin6_port)
 			< PROT_SOCK;
-#endif
 	default:
 		return 0;
 	}

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
