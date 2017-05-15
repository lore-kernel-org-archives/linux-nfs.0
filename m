Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46914 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965824AbdEOPUd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 15 May 2017 11:20:33 -0400
Subject: [PATCH 16/21] NFS: Deindent nfs_sb_config_parse_option() [ver #3]
From: David Howells <dhowells@redhat.com>
To: mszeredi@redhat.com, viro@zeniv.linux.org.uk, jlayton@redhat.com
Cc: dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 15 May 2017 16:20:26 +0100
Message-ID: <149486162597.23956.16019513275574241153.stgit@warthog.procyon.org.uk>
In-Reply-To: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
References: <149486147335.23956.2504187638938281431.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Deindent nfs_sb_config_parse_option().
---

 fs/nfs/mount.c |  706 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 351 insertions(+), 355 deletions(-)

diff --git a/fs/nfs/mount.c b/fs/nfs/mount.c
index 26153b471e48..54c38e0ed167 100644
--- a/fs/nfs/mount.c
+++ b/fs/nfs/mount.c
@@ -498,395 +498,391 @@ static int nfs_get_option_ul_bound(substring_t args[], unsigned long *option,
  */
 static int nfs_sb_config_parse_option(struct nfs_sb_config *cfg, char *p)
 {
+	substring_t args[MAX_OPT_ARGS];
+	unsigned long option;
 	char *string;
-	int rc;
-
-	{
-		substring_t args[MAX_OPT_ARGS];
-		unsigned long option;
-		int token;
+	int rc, token;
 
-		dfprintk(MOUNT, "NFS:   parsing nfs mount option '%s'\n", p);
+	dfprintk(MOUNT, "NFS:   parsing nfs mount option '%s'\n", p);
 
-		token = match_token(p, nfs_mount_option_tokens, args);
-		switch (token) {
+	token = match_token(p, nfs_mount_option_tokens, args);
+	switch (token) {
 
 		/*
 		 * boolean options:  foo/nofoo
 		 */
-		case Opt_soft:
-			cfg->flags |= NFS_MOUNT_SOFT;
-			break;
-		case Opt_hard:
-			cfg->flags &= ~NFS_MOUNT_SOFT;
-			break;
-		case Opt_posix:
-			cfg->flags |= NFS_MOUNT_POSIX;
-			break;
-		case Opt_noposix:
-			cfg->flags &= ~NFS_MOUNT_POSIX;
-			break;
-		case Opt_cto:
-			cfg->flags &= ~NFS_MOUNT_NOCTO;
-			break;
-		case Opt_nocto:
-			cfg->flags |= NFS_MOUNT_NOCTO;
-			break;
-		case Opt_ac:
-			cfg->flags &= ~NFS_MOUNT_NOAC;
-			break;
-		case Opt_noac:
-			cfg->flags |= NFS_MOUNT_NOAC;
-			break;
-		case Opt_lock:
-			cfg->flags &= ~NFS_MOUNT_NONLM;
-			cfg->flags &= ~(NFS_MOUNT_LOCAL_FLOCK |
-					NFS_MOUNT_LOCAL_FCNTL);
-			break;
-		case Opt_nolock:
-			cfg->flags |= NFS_MOUNT_NONLM;
-			cfg->flags |= (NFS_MOUNT_LOCAL_FLOCK |
-				       NFS_MOUNT_LOCAL_FCNTL);
-			break;
-		case Opt_udp:
-			cfg->flags &= ~NFS_MOUNT_TCP;
-			cfg->nfs_server.protocol = XPRT_TRANSPORT_UDP;
-			break;
-		case Opt_tcp:
-			cfg->flags |= NFS_MOUNT_TCP;
-			cfg->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-			break;
-		case Opt_rdma:
-			cfg->flags |= NFS_MOUNT_TCP; /* for side protocols */
-			cfg->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
-			xprt_load_transport(p);
-			break;
-		case Opt_acl:
-			cfg->flags &= ~NFS_MOUNT_NOACL;
-			break;
-		case Opt_noacl:
-			cfg->flags |= NFS_MOUNT_NOACL;
-			break;
-		case Opt_rdirplus:
-			cfg->flags &= ~NFS_MOUNT_NORDIRPLUS;
-			break;
-		case Opt_nordirplus:
-			cfg->flags |= NFS_MOUNT_NORDIRPLUS;
-			break;
-		case Opt_sharecache:
-			cfg->flags &= ~NFS_MOUNT_UNSHARED;
-			break;
-		case Opt_nosharecache:
-			cfg->flags |= NFS_MOUNT_UNSHARED;
-			break;
-		case Opt_resvport:
-			cfg->flags &= ~NFS_MOUNT_NORESVPORT;
-			break;
-		case Opt_noresvport:
-			cfg->flags |= NFS_MOUNT_NORESVPORT;
-			break;
-		case Opt_fscache:
-			cfg->options |= NFS_OPTION_FSCACHE;
-			kfree(cfg->fscache_uniq);
-			cfg->fscache_uniq = NULL;
-			break;
-		case Opt_nofscache:
-			cfg->options &= ~NFS_OPTION_FSCACHE;
-			kfree(cfg->fscache_uniq);
-			cfg->fscache_uniq = NULL;
-			break;
-		case Opt_migration:
-			cfg->options |= NFS_OPTION_MIGRATION;
-			break;
-		case Opt_nomigration:
-			cfg->options &= NFS_OPTION_MIGRATION;
-			break;
+	case Opt_soft:
+		cfg->flags |= NFS_MOUNT_SOFT;
+		break;
+	case Opt_hard:
+		cfg->flags &= ~NFS_MOUNT_SOFT;
+		break;
+	case Opt_posix:
+		cfg->flags |= NFS_MOUNT_POSIX;
+		break;
+	case Opt_noposix:
+		cfg->flags &= ~NFS_MOUNT_POSIX;
+		break;
+	case Opt_cto:
+		cfg->flags &= ~NFS_MOUNT_NOCTO;
+		break;
+	case Opt_nocto:
+		cfg->flags |= NFS_MOUNT_NOCTO;
+		break;
+	case Opt_ac:
+		cfg->flags &= ~NFS_MOUNT_NOAC;
+		break;
+	case Opt_noac:
+		cfg->flags |= NFS_MOUNT_NOAC;
+		break;
+	case Opt_lock:
+		cfg->flags &= ~NFS_MOUNT_NONLM;
+		cfg->flags &= ~(NFS_MOUNT_LOCAL_FLOCK |
+				NFS_MOUNT_LOCAL_FCNTL);
+		break;
+	case Opt_nolock:
+		cfg->flags |= NFS_MOUNT_NONLM;
+		cfg->flags |= (NFS_MOUNT_LOCAL_FLOCK |
+			       NFS_MOUNT_LOCAL_FCNTL);
+		break;
+	case Opt_udp:
+		cfg->flags &= ~NFS_MOUNT_TCP;
+		cfg->nfs_server.protocol = XPRT_TRANSPORT_UDP;
+		break;
+	case Opt_tcp:
+		cfg->flags |= NFS_MOUNT_TCP;
+		cfg->nfs_server.protocol = XPRT_TRANSPORT_TCP;
+		break;
+	case Opt_rdma:
+		cfg->flags |= NFS_MOUNT_TCP; /* for side protocols */
+		cfg->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
+		xprt_load_transport(p);
+		break;
+	case Opt_acl:
+		cfg->flags &= ~NFS_MOUNT_NOACL;
+		break;
+	case Opt_noacl:
+		cfg->flags |= NFS_MOUNT_NOACL;
+		break;
+	case Opt_rdirplus:
+		cfg->flags &= ~NFS_MOUNT_NORDIRPLUS;
+		break;
+	case Opt_nordirplus:
+		cfg->flags |= NFS_MOUNT_NORDIRPLUS;
+		break;
+	case Opt_sharecache:
+		cfg->flags &= ~NFS_MOUNT_UNSHARED;
+		break;
+	case Opt_nosharecache:
+		cfg->flags |= NFS_MOUNT_UNSHARED;
+		break;
+	case Opt_resvport:
+		cfg->flags &= ~NFS_MOUNT_NORESVPORT;
+		break;
+	case Opt_noresvport:
+		cfg->flags |= NFS_MOUNT_NORESVPORT;
+		break;
+	case Opt_fscache:
+		cfg->options |= NFS_OPTION_FSCACHE;
+		kfree(cfg->fscache_uniq);
+		cfg->fscache_uniq = NULL;
+		break;
+	case Opt_nofscache:
+		cfg->options &= ~NFS_OPTION_FSCACHE;
+		kfree(cfg->fscache_uniq);
+		cfg->fscache_uniq = NULL;
+		break;
+	case Opt_migration:
+		cfg->options |= NFS_OPTION_MIGRATION;
+		break;
+	case Opt_nomigration:
+		cfg->options &= NFS_OPTION_MIGRATION;
+		break;
 
 		/*
 		 * options that take numeric values
 		 */
-		case Opt_port:
-			if (nfs_get_option_ul(args, &option) ||
-			    option > USHRT_MAX)
-				goto out_invalid_value;
-			cfg->nfs_server.port = option;
-			break;
-		case Opt_rsize:
-			if (nfs_get_option_ul(args, &option))
-				goto out_invalid_value;
-			cfg->rsize = option;
-			break;
-		case Opt_wsize:
-			if (nfs_get_option_ul(args, &option))
-				goto out_invalid_value;
-			cfg->wsize = option;
-			break;
-		case Opt_bsize:
-			if (nfs_get_option_ul(args, &option))
-				goto out_invalid_value;
-			cfg->bsize = option;
-			break;
-		case Opt_timeo:
-			if (nfs_get_option_ul_bound(args, &option, 1, INT_MAX))
-				goto out_invalid_value;
-			cfg->timeo = option;
-			break;
-		case Opt_retrans:
-			if (nfs_get_option_ul_bound(args, &option, 0, INT_MAX))
-				goto out_invalid_value;
-			cfg->retrans = option;
-			break;
-		case Opt_acregmin:
-			if (nfs_get_option_ul(args, &option))
-				goto out_invalid_value;
-			cfg->acregmin = option;
-			break;
-		case Opt_acregmax:
-			if (nfs_get_option_ul(args, &option))
-				goto out_invalid_value;
-			cfg->acregmax = option;
-			break;
-		case Opt_acdirmin:
-			if (nfs_get_option_ul(args, &option))
-				goto out_invalid_value;
-			cfg->acdirmin = option;
-			break;
-		case Opt_acdirmax:
-			if (nfs_get_option_ul(args, &option))
-				goto out_invalid_value;
-			cfg->acdirmax = option;
-			break;
-		case Opt_actimeo:
-			if (nfs_get_option_ul(args, &option))
-				goto out_invalid_value;
-			cfg->acregmin = cfg->acregmax =
+	case Opt_port:
+		if (nfs_get_option_ul(args, &option) ||
+		    option > USHRT_MAX)
+			goto out_invalid_value;
+		cfg->nfs_server.port = option;
+		break;
+	case Opt_rsize:
+		if (nfs_get_option_ul(args, &option))
+			goto out_invalid_value;
+		cfg->rsize = option;
+		break;
+	case Opt_wsize:
+		if (nfs_get_option_ul(args, &option))
+			goto out_invalid_value;
+		cfg->wsize = option;
+		break;
+	case Opt_bsize:
+		if (nfs_get_option_ul(args, &option))
+			goto out_invalid_value;
+		cfg->bsize = option;
+		break;
+	case Opt_timeo:
+		if (nfs_get_option_ul_bound(args, &option, 1, INT_MAX))
+			goto out_invalid_value;
+		cfg->timeo = option;
+		break;
+	case Opt_retrans:
+		if (nfs_get_option_ul_bound(args, &option, 0, INT_MAX))
+			goto out_invalid_value;
+		cfg->retrans = option;
+		break;
+	case Opt_acregmin:
+		if (nfs_get_option_ul(args, &option))
+			goto out_invalid_value;
+		cfg->acregmin = option;
+		break;
+	case Opt_acregmax:
+		if (nfs_get_option_ul(args, &option))
+			goto out_invalid_value;
+		cfg->acregmax = option;
+		break;
+	case Opt_acdirmin:
+		if (nfs_get_option_ul(args, &option))
+			goto out_invalid_value;
+		cfg->acdirmin = option;
+		break;
+	case Opt_acdirmax:
+		if (nfs_get_option_ul(args, &option))
+			goto out_invalid_value;
+		cfg->acdirmax = option;
+		break;
+	case Opt_actimeo:
+		if (nfs_get_option_ul(args, &option))
+			goto out_invalid_value;
+		cfg->acregmin = cfg->acregmax =
 			cfg->acdirmin = cfg->acdirmax = option;
-			break;
-		case Opt_namelen:
-			if (nfs_get_option_ul(args, &option))
-				goto out_invalid_value;
-			cfg->namlen = option;
-			break;
-		case Opt_mountport:
-			if (nfs_get_option_ul(args, &option) ||
-			    option > USHRT_MAX)
-				goto out_invalid_value;
-			cfg->mount_server.port = option;
-			break;
-		case Opt_mountvers:
-			if (nfs_get_option_ul(args, &option) ||
-			    option < NFS_MNT_VERSION ||
-			    option > NFS_MNT3_VERSION)
-				goto out_invalid_value;
-			cfg->mount_server.version = option;
-			break;
-		case Opt_minorversion:
-			if (nfs_get_option_ul(args, &option))
-				goto out_invalid_value;
-			if (option > NFS4_MAX_MINOR_VERSION)
-				goto out_invalid_value;
-			cfg->minorversion = option;
-			break;
+		break;
+	case Opt_namelen:
+		if (nfs_get_option_ul(args, &option))
+			goto out_invalid_value;
+		cfg->namlen = option;
+		break;
+	case Opt_mountport:
+		if (nfs_get_option_ul(args, &option) ||
+		    option > USHRT_MAX)
+			goto out_invalid_value;
+		cfg->mount_server.port = option;
+		break;
+	case Opt_mountvers:
+		if (nfs_get_option_ul(args, &option) ||
+		    option < NFS_MNT_VERSION ||
+		    option > NFS_MNT3_VERSION)
+			goto out_invalid_value;
+		cfg->mount_server.version = option;
+		break;
+	case Opt_minorversion:
+		if (nfs_get_option_ul(args, &option))
+			goto out_invalid_value;
+		if (option > NFS4_MAX_MINOR_VERSION)
+			goto out_invalid_value;
+		cfg->minorversion = option;
+		break;
 
 		/*
 		 * options that take text values
 		 */
-		case Opt_nfsvers:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = nfs_parse_version_string(string, cfg, args);
-			kfree(string);
-			if (!rc)
-				goto out_invalid_value;
+	case Opt_nfsvers:
+		string = match_strdup(args);
+		if (string == NULL)
+			goto out_nomem;
+		rc = nfs_parse_version_string(string, cfg, args);
+		kfree(string);
+		if (!rc)
+			goto out_invalid_value;
+		break;
+	case Opt_sec:
+		string = match_strdup(args);
+		if (string == NULL)
+			goto out_nomem;
+		rc = nfs_parse_security_flavors(string, cfg);
+		kfree(string);
+		if (!rc) {
+			dfprintk(MOUNT, "NFS:   unrecognized "
+				 "security flavor\n");
+			return -EINVAL;
+		}
+		break;
+	case Opt_proto:
+		string = match_strdup(args);
+		if (string == NULL)
+			goto out_nomem;
+		token = match_token(string,
+				    nfs_xprt_protocol_tokens, args);
+
+		cfg->protofamily = AF_INET;
+		switch (token) {
+		case Opt_xprt_udp6:
+			cfg->protofamily = AF_INET6;
+		case Opt_xprt_udp:
+			cfg->flags &= ~NFS_MOUNT_TCP;
+			cfg->nfs_server.protocol = XPRT_TRANSPORT_UDP;
 			break;
-		case Opt_sec:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			rc = nfs_parse_security_flavors(string, cfg);
-			kfree(string);
-			if (!rc) {
-				dfprintk(MOUNT, "NFS:   unrecognized "
-						"security flavor\n");
-				return -EINVAL;
-			}
+		case Opt_xprt_tcp6:
+			cfg->protofamily = AF_INET6;
+		case Opt_xprt_tcp:
+			cfg->flags |= NFS_MOUNT_TCP;
+			cfg->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 			break;
-		case Opt_proto:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			token = match_token(string,
-					    nfs_xprt_protocol_tokens, args);
-
-			cfg->protofamily = AF_INET;
-			switch (token) {
-			case Opt_xprt_udp6:
-				cfg->protofamily = AF_INET6;
-			case Opt_xprt_udp:
-				cfg->flags &= ~NFS_MOUNT_TCP;
-				cfg->nfs_server.protocol = XPRT_TRANSPORT_UDP;
-				break;
-			case Opt_xprt_tcp6:
-				cfg->protofamily = AF_INET6;
-			case Opt_xprt_tcp:
-				cfg->flags |= NFS_MOUNT_TCP;
-				cfg->nfs_server.protocol = XPRT_TRANSPORT_TCP;
-				break;
-			case Opt_xprt_rdma6:
-				cfg->protofamily = AF_INET6;
-			case Opt_xprt_rdma:
-				/* vector side protocols to TCP */
-				cfg->flags |= NFS_MOUNT_TCP;
-				cfg->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
-				xprt_load_transport(string);
-				break;
-			default:
-				dfprintk(MOUNT, "NFS:   unrecognized "
-						"transport protocol\n");
-				kfree(string);
-				return -EINVAL;
-			}
-			kfree(string);
+		case Opt_xprt_rdma6:
+			cfg->protofamily = AF_INET6;
+		case Opt_xprt_rdma:
+			/* vector side protocols to TCP */
+			cfg->flags |= NFS_MOUNT_TCP;
+			cfg->nfs_server.protocol = XPRT_TRANSPORT_RDMA;
+			xprt_load_transport(string);
 			break;
-		case Opt_mountproto:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			token = match_token(string,
-					    nfs_xprt_protocol_tokens, args);
+		default:
+			dfprintk(MOUNT, "NFS:   unrecognized "
+				 "transport protocol\n");
 			kfree(string);
+			return -EINVAL;
+		}
+		kfree(string);
+		break;
+	case Opt_mountproto:
+		string = match_strdup(args);
+		if (string == NULL)
+			goto out_nomem;
+		token = match_token(string,
+				    nfs_xprt_protocol_tokens, args);
+		kfree(string);
 
-			cfg->mountfamily = AF_INET;
-			switch (token) {
-			case Opt_xprt_udp6:
-				cfg->mountfamily = AF_INET6;
-			case Opt_xprt_udp:
-				cfg->mount_server.protocol = XPRT_TRANSPORT_UDP;
-				break;
-			case Opt_xprt_tcp6:
-				cfg->mountfamily = AF_INET6;
-			case Opt_xprt_tcp:
-				cfg->mount_server.protocol = XPRT_TRANSPORT_TCP;
-				break;
-			case Opt_xprt_rdma: /* not used for side protocols */
-			default:
-				dfprintk(MOUNT, "NFS:   unrecognized "
-						"transport protocol\n");
-				return -EINVAL;
-			}
+		cfg->mountfamily = AF_INET;
+		switch (token) {
+		case Opt_xprt_udp6:
+			cfg->mountfamily = AF_INET6;
+		case Opt_xprt_udp:
+			cfg->mount_server.protocol = XPRT_TRANSPORT_UDP;
 			break;
-		case Opt_addr:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			cfg->nfs_server.addrlen =
-				rpc_pton(cfg->net, string, strlen(string),
-					(struct sockaddr *)
-					&cfg->nfs_server.address,
-					sizeof(cfg->nfs_server.address));
-			kfree(string);
-			if (cfg->nfs_server.addrlen == 0)
-				goto out_invalid_address;
+		case Opt_xprt_tcp6:
+			cfg->mountfamily = AF_INET6;
+		case Opt_xprt_tcp:
+			cfg->mount_server.protocol = XPRT_TRANSPORT_TCP;
 			break;
-		case Opt_clientaddr:
-			if (nfs_get_option_str(args, &cfg->client_address))
-				goto out_nomem;
+		case Opt_xprt_rdma: /* not used for side protocols */
+		default:
+			dfprintk(MOUNT, "NFS:   unrecognized "
+				 "transport protocol\n");
+			return -EINVAL;
+		}
+		break;
+	case Opt_addr:
+		string = match_strdup(args);
+		if (string == NULL)
+			goto out_nomem;
+		cfg->nfs_server.addrlen =
+			rpc_pton(cfg->net, string, strlen(string),
+				 (struct sockaddr *)
+				 &cfg->nfs_server.address,
+				 sizeof(cfg->nfs_server.address));
+		kfree(string);
+		if (cfg->nfs_server.addrlen == 0)
+			goto out_invalid_address;
+		break;
+	case Opt_clientaddr:
+		if (nfs_get_option_str(args, &cfg->client_address))
+			goto out_nomem;
+		break;
+	case Opt_mounthost:
+		if (nfs_get_option_str(args,
+				       &cfg->mount_server.hostname))
+			goto out_nomem;
+		break;
+	case Opt_mountaddr:
+		string = match_strdup(args);
+		if (string == NULL)
+			goto out_nomem;
+		cfg->mount_server.addrlen =
+			rpc_pton(cfg->net, string, strlen(string),
+				 (struct sockaddr *)
+				 &cfg->mount_server.address,
+				 sizeof(cfg->mount_server.address));
+		kfree(string);
+		if (cfg->mount_server.addrlen == 0)
+			goto out_invalid_address;
+		break;
+	case Opt_lookupcache:
+		string = match_strdup(args);
+		if (string == NULL)
+			goto out_nomem;
+		token = match_token(string,
+				    nfs_lookupcache_tokens, args);
+		kfree(string);
+		switch (token) {
+		case Opt_lookupcache_all:
+			cfg->flags &= ~(NFS_MOUNT_LOOKUP_CACHE_NONEG|NFS_MOUNT_LOOKUP_CACHE_NONE);
 			break;
-		case Opt_mounthost:
-			if (nfs_get_option_str(args,
-					       &cfg->mount_server.hostname))
-				goto out_nomem;
+		case Opt_lookupcache_positive:
+			cfg->flags &= ~NFS_MOUNT_LOOKUP_CACHE_NONE;
+			cfg->flags |= NFS_MOUNT_LOOKUP_CACHE_NONEG;
 			break;
-		case Opt_mountaddr:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			cfg->mount_server.addrlen =
-				rpc_pton(cfg->net, string, strlen(string),
-					(struct sockaddr *)
-					&cfg->mount_server.address,
-					sizeof(cfg->mount_server.address));
-			kfree(string);
-			if (cfg->mount_server.addrlen == 0)
-				goto out_invalid_address;
+		case Opt_lookupcache_none:
+			cfg->flags |= NFS_MOUNT_LOOKUP_CACHE_NONEG|NFS_MOUNT_LOOKUP_CACHE_NONE;
 			break;
-		case Opt_lookupcache:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			token = match_token(string,
-					nfs_lookupcache_tokens, args);
-			kfree(string);
-			switch (token) {
-				case Opt_lookupcache_all:
-					cfg->flags &= ~(NFS_MOUNT_LOOKUP_CACHE_NONEG|NFS_MOUNT_LOOKUP_CACHE_NONE);
-					break;
-				case Opt_lookupcache_positive:
-					cfg->flags &= ~NFS_MOUNT_LOOKUP_CACHE_NONE;
-					cfg->flags |= NFS_MOUNT_LOOKUP_CACHE_NONEG;
-					break;
-				case Opt_lookupcache_none:
-					cfg->flags |= NFS_MOUNT_LOOKUP_CACHE_NONEG|NFS_MOUNT_LOOKUP_CACHE_NONE;
-					break;
-				default:
-					dfprintk(MOUNT, "NFS:   invalid "
-							"lookupcache argument\n");
-					return -EINVAL;
-			};
+		default:
+			dfprintk(MOUNT, "NFS:   invalid "
+				 "lookupcache argument\n");
+			return -EINVAL;
+		};
+		break;
+	case Opt_fscache_uniq:
+		if (nfs_get_option_str(args, &cfg->fscache_uniq))
+			goto out_nomem;
+		cfg->options |= NFS_OPTION_FSCACHE;
+		break;
+	case Opt_local_lock:
+		string = match_strdup(args);
+		if (string == NULL)
+			goto out_nomem;
+		token = match_token(string, nfs_local_lock_tokens,
+				    args);
+		kfree(string);
+		switch (token) {
+		case Opt_local_lock_all:
+			cfg->flags |= (NFS_MOUNT_LOCAL_FLOCK |
+				       NFS_MOUNT_LOCAL_FCNTL);
 			break;
-		case Opt_fscache_uniq:
-			if (nfs_get_option_str(args, &cfg->fscache_uniq))
-				goto out_nomem;
-			cfg->options |= NFS_OPTION_FSCACHE;
+		case Opt_local_lock_flock:
+			cfg->flags |= NFS_MOUNT_LOCAL_FLOCK;
 			break;
-		case Opt_local_lock:
-			string = match_strdup(args);
-			if (string == NULL)
-				goto out_nomem;
-			token = match_token(string, nfs_local_lock_tokens,
-					args);
-			kfree(string);
-			switch (token) {
-			case Opt_local_lock_all:
-				cfg->flags |= (NFS_MOUNT_LOCAL_FLOCK |
-					       NFS_MOUNT_LOCAL_FCNTL);
-				break;
-			case Opt_local_lock_flock:
-				cfg->flags |= NFS_MOUNT_LOCAL_FLOCK;
-				break;
-			case Opt_local_lock_posix:
-				cfg->flags |= NFS_MOUNT_LOCAL_FCNTL;
-				break;
-			case Opt_local_lock_none:
-				cfg->flags &= ~(NFS_MOUNT_LOCAL_FLOCK |
-						NFS_MOUNT_LOCAL_FCNTL);
-				break;
-			default:
-				dfprintk(MOUNT, "NFS:	invalid	"
-						"local_lock argument\n");
-				return -EINVAL;
-			};
+		case Opt_local_lock_posix:
+			cfg->flags |= NFS_MOUNT_LOCAL_FCNTL;
 			break;
+		case Opt_local_lock_none:
+			cfg->flags &= ~(NFS_MOUNT_LOCAL_FLOCK |
+					NFS_MOUNT_LOCAL_FCNTL);
+			break;
+		default:
+			dfprintk(MOUNT, "NFS:	invalid	"
+				 "local_lock argument\n");
+			return -EINVAL;
+		};
+		break;
 
 		/*
 		 * Special options
 		 */
-		case Opt_sloppy:
-			cfg->sloppy = 1;
-			dfprintk(MOUNT, "NFS:   relaxing parsing rules\n");
-			break;
-		case Opt_userspace:
-		case Opt_deprecated:
-			dfprintk(MOUNT, "NFS:   ignoring mount option "
-					"'%s'\n", p);
-			break;
+	case Opt_sloppy:
+		cfg->sloppy = 1;
+		dfprintk(MOUNT, "NFS:   relaxing parsing rules\n");
+		break;
+	case Opt_userspace:
+	case Opt_deprecated:
+		dfprintk(MOUNT, "NFS:   ignoring mount option "
+			 "'%s'\n", p);
+		break;
 
-		default:
-			dfprintk(MOUNT, "NFS:   unrecognized mount option "
-					"'%s'\n", p);
-			return -EINVAL;
-		}
+	default:
+		dfprintk(MOUNT, "NFS:   unrecognized mount option "
+			 "'%s'\n", p);
+		return -EINVAL;
 	}
 
 	return 0;

