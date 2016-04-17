Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout01.posteo.de ([185.67.36.65]:56811 "EHLO mout01.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751560AbcDQJLx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 17 Apr 2016 05:11:53 -0400
Received: from dovecot03.posteo.de (dovecot03.posteo.de [172.16.0.13])
	by mout01.posteo.de (Postfix) with ESMTPS id E02F220A60
	for <linux-nfs@vger.kernel.org>; Sun, 17 Apr 2016 11:11:51 +0200 (CEST)
Date: Sun, 17 Apr 2016 11:11:13 +0200
From: Felix Janda <felix.janda@posteo.de>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 7/7] Deduplicate extern "C" blocks
Message-ID: <20160417091113.GF2737@nyan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
 tirpc/rpc/auth.h      | 62 +++++++--------------------------------------------
 tirpc/rpc/auth_des.h  | 14 +++++-------
 tirpc/rpc/clnt.h      | 50 +++++++----------------------------------
 tirpc/rpc/clnt_soc.h  | 27 +++++-----------------
 tirpc/rpc/des_crypt.h | 20 +++++------------
 tirpc/rpc/rpc.h       | 14 +++++-------
 tirpc/rpc/svc.h       | 55 ++++++---------------------------------------
 tirpc/rpc/svc_soc.h   | 38 +++++--------------------------
 tirpc/rpc/xdr.h       | 15 +++++--------
 9 files changed, 54 insertions(+), 241 deletions(-)

diff --git a/tirpc/rpc/auth.h b/tirpc/rpc/auth.h
index 5f8ea72..f743034 100644
--- a/tirpc/rpc/auth.h
+++ b/tirpc/rpc/auth.h
@@ -46,6 +46,10 @@
 #ifndef _TIRPC_AUTH_H
 #define  _TIRPC_AUTH_H
 
+#ifdef __cplusplus
+extern "C" {
+#endif
+
 #include <rpc/xdr.h>
 #include <rpc/clnt_stat.h>
 #include <sys/socket.h>
@@ -148,13 +152,7 @@ union des_block {
 	char c[8];
 };
 typedef union des_block des_block;
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern bool_t xdr_des_block(XDR *, des_block *);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Authentication info.  Opaque to client.
@@ -241,13 +239,7 @@ typedef struct __auth {
 		xfunc, xwhere))
 
 
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern struct opaque_auth _null_auth;
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Any style authentication.  These routines can be used by any
@@ -268,15 +260,9 @@ int authany_wrap(void), authany_unwrap(void);
  *	int len;
  *	int *aup_gids;
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern AUTH *authunix_create(char *, uid_t, uid_t, int, uid_t *);
 extern AUTH *authunix_create_default(void);	/* takes no parameters */
 extern AUTH *authnone_create(void);		/* takes no parameters */
-#ifdef __cplusplus
-}
-#endif
 /*
  * DES style authentication
  * AUTH *authsecdes_create(servername, window, timehost, ckey)
@@ -285,25 +271,13 @@ extern AUTH *authnone_create(void);		/* takes no parameters */
  * 	const char *timehost;			- optional hostname to sync with
  * 	des_block *ckey;		- optional conversation key to use
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern AUTH *authdes_create (char *, u_int, struct sockaddr *, des_block *);
 extern AUTH *authdes_pk_create (char *, netobj *, u_int,
 				struct sockaddr *, des_block *);
 extern AUTH *authdes_seccreate (const char *, const u_int, const  char *,
     const  des_block *);
-#ifdef __cplusplus
-}
-#endif
 
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern bool_t xdr_opaque_auth		(XDR *, struct opaque_auth *);
-#ifdef __cplusplus
-}
-#endif
 
 #define authsys_create(c,i1,i2,i3,ip) authunix_create((c),(i1),(i2),(i3),(ip))
 #define authsys_create_default() authunix_create_default()
@@ -311,61 +285,37 @@ extern bool_t xdr_opaque_auth		(XDR *, struct opaque_auth *);
 /*
  * Netname manipulation routines.
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern int getnetname(char *);
 extern int host2netname(char *, const char *, const char *);
 extern int user2netname(char *, const uid_t, const char *);
 extern int netname2user(char *, uid_t *, gid_t *, int *, gid_t *);
 extern int netname2host(char *, char *, const int);
 extern void passwd2des ( char *, char * );
-#ifdef __cplusplus
-}
-#endif
 
 /*
  *
  * These routines interface to the keyserv daemon
  *
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern int key_decryptsession(const char *, des_block *);
 extern int key_encryptsession(const char *, des_block *);
 extern int key_gendes(des_block *);
 extern int key_setsecret(const char *);
 extern int key_secretkey_is_set(void);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Publickey routines.
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern int getpublickey (const char *, char *);
 extern int getpublicandprivatekey (char *, char *);
 extern int getsecretkey (char *, char *, char *);
-#ifdef __cplusplus
-}
-#endif
 
-#ifdef __cplusplus
-extern "C" {
-#endif
 struct svc_req;
 struct rpc_msg;
 enum auth_stat _svcauth_none (struct svc_req *, struct rpc_msg *);
 enum auth_stat _svcauth_short (struct svc_req *, struct rpc_msg *);
 enum auth_stat _svcauth_unix (struct svc_req *, struct rpc_msg *);
 enum auth_stat _svcauth_gss (struct svc_req *, struct rpc_msg *, bool_t *);
-#ifdef __cplusplus
-}
-#endif
 
 #define AUTH_NONE	0		/* no authentication */
 #define	AUTH_NULL	0		/* backward compatibility */
@@ -377,4 +327,8 @@ enum auth_stat _svcauth_gss (struct svc_req *, struct rpc_msg *, bool_t *);
 #define AUTH_KERB	4		/* kerberos style */
 #define RPCSEC_GSS	6		/* RPCSEC_GSS */
 
+#ifdef __cplusplus
+}
+#endif
+
 #endif /* !_TIRPC_AUTH_H */
diff --git a/tirpc/rpc/auth_des.h b/tirpc/rpc/auth_des.h
index 73103c6..67e5136 100644
--- a/tirpc/rpc/auth_des.h
+++ b/tirpc/rpc/auth_des.h
@@ -42,6 +42,10 @@
 #ifndef _TI_AUTH_DES_
 #define _TI_AUTH_DES_
 
+#ifdef __cplusplus
+extern "C" {
+#endif
+
 #include <rpc/auth.h>
 
 /*
@@ -114,23 +118,15 @@ struct authdes_verf {
  * Map a des credential into a unix cred.
  *
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern int authdes_getucred( struct authdes_cred *, uid_t *, gid_t *, int *, gid_t * );
-#ifdef __cplusplus
-}
-#endif
 
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern bool_t	xdr_authdes_cred(XDR *, struct authdes_cred *);
 extern bool_t	xdr_authdes_verf(XDR *, struct authdes_verf *);
 extern int	rtime(struct sockaddr_in *, struct timeval *,
 		    struct timeval *);
 extern void	kgetnetname(char *);
 extern enum auth_stat _svcauth_des(struct svc_req *, struct rpc_msg *);
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/tirpc/rpc/clnt.h b/tirpc/rpc/clnt.h
index 05f2215..6a827f4 100644
--- a/tirpc/rpc/clnt.h
+++ b/tirpc/rpc/clnt.h
@@ -39,6 +39,10 @@
 #ifndef _TIRPC_CLNT_H_
 #define _TIRPC_CLNT_H_
 
+#ifdef __cplusplus
+extern "C" {
+#endif
+
 #include <rpc/clnt_stat.h>
 #include <rpc/auth.h>
 
@@ -266,9 +270,6 @@ struct rpc_timers {
  * Generic client creation routine. Supported protocols are those that
  * belong to the nettype namespace (/etc/netconfig).
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern CLIENT *clnt_create(const char *, const rpcprog_t, const rpcvers_t,
 			   const char *);
 /*
@@ -415,46 +416,25 @@ extern CLIENT *clnt_dg_create(const int, const struct netbuf *,
  */
 extern CLIENT *clnt_raw_create(rpcprog_t, rpcvers_t);
 
-#ifdef __cplusplus
-}
-#endif
 
 
 /*
  * Print why creation failed
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern void clnt_pcreateerror(const char *);			/* stderr */
 extern char *clnt_spcreateerror(const char *);			/* string */
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Like clnt_perror(), but is more verbose in its output
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern void clnt_perrno(enum clnt_stat);		/* stderr */
 extern char *clnt_sperrno(enum clnt_stat);		/* string */
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Print an English error message, given the client error code
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern void clnt_perror(CLIENT *, const char *);	 	/* stderr */
 extern char *clnt_sperror(CLIENT *, const char *);		/* string */
-#ifdef __cplusplus
-}
-#endif
 
 
 /*
@@ -465,13 +445,7 @@ struct rpc_createerr {
 	struct rpc_err cf_error; /* useful when cf_stat == RPC_PMAPFAILURE */
 };
 
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern struct rpc_createerr	*__rpc_createerr(void);
-#ifdef __cplusplus
-}
-#endif
 #define get_rpc_createerr()	(*(__rpc_createerr()))
 #define rpc_createerr		(*(__rpc_createerr()))
 
@@ -488,16 +462,10 @@ extern struct rpc_createerr	*__rpc_createerr(void);
  *	char *out;
  *	const char *nettype;
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern enum clnt_stat rpc_call(const char *, const rpcprog_t,
 			       const rpcvers_t, const rpcproc_t,
 			       const xdrproc_t, const char *,
 			       const xdrproc_t, char *, const char *);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * RPC broadcast interface
@@ -545,9 +513,6 @@ extern enum clnt_stat rpc_call(const char *, const rpcprog_t,
 
 typedef bool_t (*resultproc_t)(caddr_t, ...);
 
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern enum clnt_stat rpc_broadcast(const rpcprog_t, const rpcvers_t,
 				    const rpcproc_t, const xdrproc_t,
 				    caddr_t, const xdrproc_t, caddr_t,
@@ -557,11 +522,12 @@ extern enum clnt_stat rpc_broadcast_exp(const rpcprog_t, const rpcvers_t,
 					caddr_t, const xdrproc_t, caddr_t,
 					const resultproc_t, const int,
 					const int, const char *);
-#ifdef __cplusplus
-}
-#endif
 
 /* For backward compatibility */
 #include <rpc/clnt_soc.h>
 
+#ifdef __cplusplus
+}
+#endif
+
 #endif /* !_TIRPC_CLNT_H_ */
diff --git a/tirpc/rpc/clnt_soc.h b/tirpc/rpc/clnt_soc.h
index 6ec545c..5781d2f 100644
--- a/tirpc/rpc/clnt_soc.h
+++ b/tirpc/rpc/clnt_soc.h
@@ -39,6 +39,10 @@
 #ifndef _RPC_CLNT_SOC_H
 #define _RPC_CLNT_SOC_H
 
+#ifdef __cplusplus
+extern "C" {
+#endif
+
 /* derived from clnt_soc.h 1.3 88/12/17 SMI     */
 
 /*
@@ -60,39 +64,21 @@
  *	u_int sendsz;
  *	u_int recvsz;
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern CLIENT *clnttcp_create(struct sockaddr_in *, u_long, u_long, int *,
 			      u_int, u_int);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Raw (memory) rpc.
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern CLIENT *clntraw_create(u_long, u_long);
-#ifdef __cplusplus
-}
-#endif
 
 
 /*
 IPv6 socket version 
 */
 #ifdef INET6
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern CLIENT *clnttcp6_create(struct sockaddr_in6 *, u_long, u_long, int *,
 			      u_int, u_int);
-#ifdef __cplusplus
-}
-#endif
 #endif
 
 /*
@@ -116,9 +102,6 @@ extern CLIENT *clnttcp6_create(struct sockaddr_in6 *, u_long, u_long, int *,
  *	u_int sendsz;
  *	u_int recvsz;
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern CLIENT *clntudp_create(struct sockaddr_in *, u_long, u_long, 
 			      struct timeval, int *);
 extern CLIENT *clntudp_bufcreate(struct sockaddr_in *, u_long, u_long,
@@ -129,9 +112,9 @@ extern CLIENT *clntudp6_create(struct sockaddr_in6 *, u_long, u_long,
 extern CLIENT *clntudp6_bufcreate(struct sockaddr_in6 *, u_long, u_long,
 				 struct timeval, int *, u_int, u_int);
 #endif
+
 #ifdef __cplusplus
 }
 #endif
 
-
 #endif /* _RPC_CLNT_SOC_H */
diff --git a/tirpc/rpc/des_crypt.h b/tirpc/rpc/des_crypt.h
index 2358960..18f094e 100644
--- a/tirpc/rpc/des_crypt.h
+++ b/tirpc/rpc/des_crypt.h
@@ -43,6 +43,10 @@
 #ifndef _DES_DES_CRYPT_H
 #define _DES_DES_CRYPT_H
 
+#ifdef __cplusplus
+extern "C" {
+#endif
+
 #include <rpc/rpc.h>
 
 #define DES_MAXDATA 8192	/* max bytes encrypted in one call */
@@ -82,33 +86,19 @@
 /*
  * Cipher Block Chaining mode
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 int cbc_crypt( char *, char *, unsigned int, unsigned int, char *);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Electronic Code Book mode
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 int ecb_crypt( char *, char *, unsigned int, unsigned int );
-#ifdef __cplusplus
-}
-#endif
 
 /* 
  * Set des parity for a key.
  * DES parity is odd and in the low bit of each byte
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 void des_setparity( char *);
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/tirpc/rpc/rpc.h b/tirpc/rpc/rpc.h
index c3055ba..2e29ea4 100644
--- a/tirpc/rpc/rpc.h
+++ b/tirpc/rpc/rpc.h
@@ -35,6 +35,10 @@
 #ifndef _TIRPC_RPC_H
 #define _TIRPC_RPC_H
 
+#ifdef __cplusplus
+extern "C" {
+#endif
+
 #include <rpc/types.h>		/* some typedefs */
 #include <sys/socket.h>
 #include <netinet/in.h>
@@ -76,9 +80,6 @@
 #define UDPMSGSIZE 8800
 #endif
 
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern int get_myaddress(struct sockaddr_in *);
 extern int bindresvport(int, struct sockaddr_in *);
 extern int registerrpc(int, int, int, char *(*)(char [UDPMSGSIZE]),
@@ -92,22 +93,17 @@ struct netbuf *uaddr2taddr(const struct netconfig *, const char *);
 
 struct sockaddr;
 extern int bindresvport_sa(int, struct sockaddr *);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * The following are not exported interfaces, they are for internal library
  * and rpcbind use only. Do not use, they may change without notice.
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 int __rpc_nconf2fd(const struct netconfig *);
 int __rpc_nconf2fd_flags(const struct netconfig *, int);
 int __rpc_nconf2sockinfo(const struct netconfig *, struct __rpc_sockinfo *);
 int __rpc_fd2sockinfo(int, struct __rpc_sockinfo *);
 u_int __rpc_get_t_size(int, int, int);
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/tirpc/rpc/svc.h b/tirpc/rpc/svc.h
index 6d176f0..4664286 100644
--- a/tirpc/rpc/svc.h
+++ b/tirpc/rpc/svc.h
@@ -41,6 +41,10 @@
 #ifndef _TIRPC_SVC_H
 #define _TIRPC_SVC_H
 
+#ifdef __cplusplus
+extern "C" {
+#endif
+
 /*
  * This interface must manage two items concerning remote procedure calling:
  *
@@ -199,15 +203,9 @@ struct svc_req {
  *	const struct netconfig *nconf;
  */
 
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern bool_t	svc_reg(SVCXPRT *, const rpcprog_t, const rpcvers_t,
 			void (*)(struct svc_req *, SVCXPRT *),
 			const struct netconfig *);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Service un-registration
@@ -217,13 +215,7 @@ extern bool_t	svc_reg(SVCXPRT *, const rpcprog_t, const rpcvers_t,
  *	const rpcvers_t vers;
  */
 
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern void	svc_unreg(const rpcprog_t, const rpcvers_t);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Transport registration.
@@ -231,13 +223,7 @@ extern void	svc_unreg(const rpcprog_t, const rpcvers_t);
  * xprt_register(xprt)
  *	SVCXPRT *xprt;
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern void	xprt_register(SVCXPRT *);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Transport un-register
@@ -245,13 +231,7 @@ extern void	xprt_register(SVCXPRT *);
  * xprt_unregister(xprt)
  *	SVCXPRT *xprt;
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern void	xprt_unregister(SVCXPRT *);
-#ifdef __cplusplus
-}
-#endif
 
 
 /*
@@ -280,9 +260,6 @@ extern void	xprt_unregister(SVCXPRT *);
  * deadlock the caller and server processes!
  */
 
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern bool_t	svc_sendreply(SVCXPRT *, xdrproc_t, void *);
 extern void	svcerr_decode(SVCXPRT *);
 extern void	svcerr_weakauth(SVCXPRT *);
@@ -294,9 +271,6 @@ extern void	svcerr_systemerr(SVCXPRT *);
 extern int	rpc_reg(rpcprog_t, rpcvers_t, rpcproc_t,
 			char *(*)(char *), xdrproc_t, xdrproc_t,
 			char *);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Lowest level dispatching -OR- who owns this process anyway.
@@ -323,17 +297,8 @@ extern int svc_max_pollfd;
  * a small program implemented by the svc_rpc implementation itself;
  * also see clnt.h for protocol numbers.
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern void rpctest_service(void);
-#ifdef __cplusplus
-}
-#endif
 
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern void	svc_getreq(int);
 extern void	svc_getreqset(fd_set *);
 extern void	svc_getreq_common(int);
@@ -342,9 +307,6 @@ extern void	svc_getreq_poll(struct pollfd *, int);
 
 extern void	svc_run(void);
 extern void	svc_exit(void);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Socket to use on svcxxx_create call to get default socket
@@ -356,9 +318,6 @@ extern void	svc_exit(void);
  * These are the existing service side transport implementations
  */
 
-#ifdef __cplusplus
-extern "C" {
-#endif
 /*
  * Transport independent svc_create routine.
  */
@@ -454,14 +413,14 @@ int svc_dg_enablecache(SVCXPRT *, const u_int);
 
 int __rpc_get_local_uid(SVCXPRT *_transp, uid_t *_uid);
 
-#ifdef __cplusplus
-}
-#endif
 
 
 /* for backward compatibility */
 #include <rpc/svc_soc.h>
 
 
+#ifdef __cplusplus
+}
+#endif
 
 #endif /* !_TIRPC_SVC_H */
diff --git a/tirpc/rpc/svc_soc.h b/tirpc/rpc/svc_soc.h
index 9b7befa..94b88bf 100644
--- a/tirpc/rpc/svc_soc.h
+++ b/tirpc/rpc/svc_soc.h
@@ -39,6 +39,10 @@
 #ifndef _RPC_SVC_SOC_H
 #define _RPC_SVC_SOC_H
 
+#ifdef __cplusplus
+extern "C" {
+#endif
+
 /* #pragma ident   "@(#)svc_soc.h  1.11    94/04/25 SMI" */
 /*      svc_soc.h 1.8 89/05/01 SMI      */
 
@@ -63,14 +67,8 @@
  *	void (*dispatch)();
  *	int protocol;    like TCP or UDP, zero means do not register 
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern bool_t	svc_register(SVCXPRT *, u_long, u_long,
 		    void (*)(struct svc_req *, SVCXPRT *), int);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Service un-registration
@@ -79,62 +77,36 @@ extern bool_t	svc_register(SVCXPRT *, u_long, u_long,
  *	u_long prog;
  *	u_long vers;
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern void	svc_unregister(u_long, u_long);
-#ifdef __cplusplus
-}
-#endif
 
 
 /*
  * Memory based rpc for testing and timing.
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern SVCXPRT *svcraw_create(void);
-#ifdef __cplusplus
-}
-#endif
 
 
 /*
  * Udp based rpc.
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern SVCXPRT *svcudp_create(int);
 extern SVCXPRT *svcudp_bufcreate(int, u_int, u_int);
 extern int svcudp_enablecache(SVCXPRT *, u_long);
 extern SVCXPRT *svcudp6_create(int);
 extern SVCXPRT *svcudp6_bufcreate(int, u_int, u_int);
-#ifdef __cplusplus
-}
-#endif
 
 
 /*
  * Tcp based rpc.
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern SVCXPRT *svctcp_create(int, u_int, u_int);
 extern SVCXPRT *svctcp6_create(int, u_int, u_int);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Fd based rpc.
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern SVCXPRT *svcfd_create(int, u_int, u_int);
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/tirpc/rpc/xdr.h b/tirpc/rpc/xdr.h
index 80b35ce..3a45c8c 100644
--- a/tirpc/rpc/xdr.h
+++ b/tirpc/rpc/xdr.h
@@ -40,6 +40,11 @@
 
 #ifndef _TIRPC_XDR_H
 #define _TIRPC_XDR_H
+
+#ifdef __cplusplus
+extern "C" {
+#endif
+
 #include <stdio.h>
 #include <netinet/in.h>
 
@@ -282,9 +287,6 @@ struct xdr_discrim {
 /*
  * These are the "generic" xdr routines.
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 extern bool_t	xdr_void(void);
 extern bool_t	xdr_int(XDR *, int *);
 extern bool_t	xdr_u_int(XDR *, u_int *);
@@ -328,9 +330,6 @@ extern bool_t	xdr_u_hyper(XDR *, u_quad_t *);
 extern bool_t	xdr_longlong_t(XDR *, quad_t *);
 extern bool_t	xdr_u_longlong_t(XDR *, u_quad_t *);
 extern u_long	xdr_sizeof(xdrproc_t, void *);
-#ifdef __cplusplus
-}
-#endif
 
 /*
  * Common opaque bytes objects used by many rpc protocols;
@@ -348,9 +347,6 @@ extern bool_t   xdr_netobj(XDR *, struct netobj *);
  * These are the public routines for the various implementations of
  * xdr streams.
  */
-#ifdef __cplusplus
-extern "C" {
-#endif
 /* XDR using memory buffers */
 extern void   xdrmem_create(XDR *, char *, u_int, enum xdr_op);
 
@@ -371,6 +367,7 @@ extern bool_t xdrrec_skiprecord(XDR *);
 /* true if no more input */
 extern bool_t xdrrec_eof(XDR *);
 extern u_int xdrrec_readbytes(XDR *, caddr_t, u_int);
+
 #ifdef __cplusplus
 }
 #endif
-- 
2.7.3
