Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51268 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753576AbaLIFlU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:41:20 -0500
Subject: [PATCH 06/19] nfs-utils: gssd - move over pipfs scanning code
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:41:10 +0100
Message-ID: <20141209054110.24756.5878.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Move all rpc_pipefs scanning code from gssd_proc.c to gssd.c in
preparation for later patches.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gss_util.h  |    2 
 utils/gssd/gssd.c      |  568 ++++++++++++++++++++++++++++++++++++++++++++++++
 utils/gssd/gssd.h      |   16 -
 utils/gssd/gssd_proc.c |  543 ----------------------------------------------
 4 files changed, 566 insertions(+), 563 deletions(-)

diff --git a/utils/gssd/gss_util.h b/utils/gssd/gss_util.h
index c81fc5a..aa9f778 100644
--- a/utils/gssd/gss_util.h
+++ b/utils/gssd/gss_util.h
@@ -52,6 +52,4 @@ int gssd_check_mechs(void);
 		gss_krb5_set_allowable_enctypes(min, cred, num, types)
 #endif
 
-extern int avoid_dns;
-
 #endif /* _GSS_UTIL_H_ */
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 716a387..21abaed 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -46,9 +46,12 @@
 
 #include <sys/param.h>
 #include <sys/socket.h>
+#include <sys/time.h>
+#include <sys/resource.h>
 #include <sys/poll.h>
 #include <rpc/rpc.h>
 #include <netinet/in.h>
+#include <arpa/inet.h>
 
 #include <unistd.h>
 #include <err.h>
@@ -60,6 +63,7 @@
 #include <memory.h>
 #include <fcntl.h>
 #include <dirent.h>
+#include <netdb.h>
 
 #include "gssd.h"
 #include "err_util.h"
@@ -75,11 +79,19 @@ int  root_uses_machine_creds = 1;
 unsigned int  context_timeout = 0;
 unsigned int  rpc_timeout = 5;
 char *preferred_realm = NULL;
-extern struct pollfd *pollarray;
-extern unsigned long pollsize;
 
 #define POLL_MILLISECS	500
 
+TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
+
+TAILQ_HEAD(topdirs_list_head, topdirs_info) topdirs_list;
+
+struct topdirs_info {
+	TAILQ_ENTRY(topdirs_info)	list;
+	int				fd;
+	char				dirname[];
+};
+
 static volatile int dir_changed = 1;
 
 static void dir_notify_handler(__attribute__((unused))int sig)
@@ -87,6 +99,536 @@ static void dir_notify_handler(__attribute__((unused))int sig)
 	dir_changed = 1;
 }
 
+
+/*
+ * pollarray:
+ *      array of struct pollfd suitable to pass to poll. initialized to
+ *      zero - a zero struct is ignored by poll() because the events mask is 0.
+ *
+ * clnt_list:
+ *      linked list of struct clnt_info which associates a clntXXX directory
+ *	with an index into pollarray[], and other basic data about that client.
+ *
+ * Directory structure: created by the kernel
+ *      {rpc_pipefs}/{dir}/clntXX         : one per rpc_clnt struct in the kernel
+ *      {rpc_pipefs}/{dir}/clntXX/krb5    : read uid for which kernel wants
+ *					    a context, write the resulting context
+ *      {rpc_pipefs}/{dir}/clntXX/info    : stores info such as server name
+ *      {rpc_pipefs}/{dir}/clntXX/gssd    : pipe for all gss mechanisms using
+ *					    a text-based string of parameters
+ *
+ * Algorithm:
+ *      Poll all {rpc_pipefs}/{dir}/clntXX/YYYY files.  When data is ready,
+ *      read and process; performs rpcsec_gss context initialization protocol to
+ *      get a cred for that user.  Writes result to corresponding krb5 file
+ *      in a form the kernel code will understand.
+ *      In addition, we make sure we are notified whenever anything is
+ *      created or destroyed in {rpc_pipefs} or in any of the clntXX directories,
+ *      and rescan the whole {rpc_pipefs} when this happens.
+ */
+
+static struct pollfd * pollarray;
+
+static unsigned long pollsize;  /* the size of pollaray (in pollfd's) */
+
+/* Avoid DNS reverse lookups on server names */
+static int avoid_dns = 1;
+
+/*
+ * convert a presentation address string to a sockaddr_storage struct. Returns
+ * true on success or false on failure.
+ *
+ * Note that we do not populate the sin6_scope_id field here for IPv6 addrs.
+ * gssd nececessarily relies on hostname resolution and DNS AAAA records
+ * do not generally contain scope-id's. This means that GSSAPI auth really
+ * can't work with IPv6 link-local addresses.
+ *
+ * We *could* consider changing this if we did something like adopt the
+ * Microsoft "standard" of using the ipv6-literal.net domainname, but it's
+ * not really feasible at present.
+ */
+static int
+addrstr_to_sockaddr(struct sockaddr *sa, const char *node, const char *port)
+{
+	int rc;
+	struct addrinfo *res;
+	struct addrinfo hints = { .ai_flags = AI_NUMERICHOST | AI_NUMERICSERV };
+
+#ifndef IPV6_SUPPORTED
+	hints.ai_family = AF_INET;
+#endif /* IPV6_SUPPORTED */
+
+	rc = getaddrinfo(node, port, &hints, &res);
+	if (rc) {
+		printerr(0, "ERROR: unable to convert %s|%s to sockaddr: %s\n",
+			 node, port, rc == EAI_SYSTEM ? strerror(errno) :
+						gai_strerror(rc));
+		return 0;
+	}
+
+#ifdef IPV6_SUPPORTED
+	/*
+	 * getnameinfo ignores the scopeid. If the address turns out to have
+	 * a non-zero scopeid, we can't use it -- the resolved host might be
+	 * completely different from the one intended.
+	 */
+	if (res->ai_addr->sa_family == AF_INET6) {
+		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)res->ai_addr;
+		if (sin6->sin6_scope_id) {
+			printerr(0, "ERROR: address %s has non-zero "
+				    "sin6_scope_id!\n", node);
+			freeaddrinfo(res);
+			return 0;
+		}
+	}
+#endif /* IPV6_SUPPORTED */
+
+	memcpy(sa, res->ai_addr, res->ai_addrlen);
+	freeaddrinfo(res);
+	return 1;
+}
+
+/*
+ * convert a sockaddr to a hostname
+ */
+static char *
+get_servername(const char *name, const struct sockaddr *sa, const char *addr)
+{
+	socklen_t		addrlen;
+	int			err;
+	char			*hostname;
+	char			hbuf[NI_MAXHOST];
+	unsigned char		buf[sizeof(struct in6_addr)];
+
+	if (avoid_dns) {
+		/*
+		 * Determine if this is a server name, or an IP address.
+		 * If it is an IP address, do the DNS lookup otherwise
+		 * skip the DNS lookup.
+		 */
+		int is_fqdn = 1;
+		if (strchr(name, '.') == NULL)
+			is_fqdn = 0; /* local name */
+		else if (inet_pton(AF_INET, name, buf) == 1)
+			is_fqdn = 0; /* IPv4 address */
+		else if (inet_pton(AF_INET6, name, buf) == 1)
+			is_fqdn = 0; /* IPv6 addrss */
+
+		if (is_fqdn) {
+			return strdup(name);
+		}
+		/* Sorry, cannot avoid dns after all */
+	}
+
+	switch (sa->sa_family) {
+	case AF_INET:
+		addrlen = sizeof(struct sockaddr_in);
+		break;
+#ifdef IPV6_SUPPORTED
+	case AF_INET6:
+		addrlen = sizeof(struct sockaddr_in6);
+		break;
+#endif /* IPV6_SUPPORTED */
+	default:
+		printerr(0, "ERROR: unrecognized addr family %d\n",
+			 sa->sa_family);
+		return NULL;
+	}
+
+	err = getnameinfo(sa, addrlen, hbuf, sizeof(hbuf), NULL, 0,
+			  NI_NAMEREQD);
+	if (err) {
+		printerr(0, "ERROR: unable to resolve %s to hostname: %s\n",
+			 addr, err == EAI_SYSTEM ? strerror(errno) :
+						   gai_strerror(err));
+		return NULL;
+	}
+
+	hostname = strdup(hbuf);
+
+	return hostname;
+}
+
+/* XXX buffer problems: */
+static int
+read_service_info(char *info_file_name, char **servicename, char **servername,
+		  int *prog, int *vers, char **protocol,
+		  struct sockaddr *addr) {
+#define INFOBUFLEN 256
+	char		buf[INFOBUFLEN + 1];
+	static char	server[128];
+	int		nbytes;
+	static char	service[128];
+	static char	address[128];
+	char		program[16];
+	char		version[16];
+	char		protoname[16];
+	char		port[128];
+	char		*p;
+	int		fd = -1;
+	int		numfields;
+
+	*servicename = *servername = *protocol = NULL;
+
+	if ((fd = open(info_file_name, O_RDONLY)) == -1) {
+		printerr(0, "ERROR: can't open %s: %s\n", info_file_name,
+			 strerror(errno));
+		goto fail;
+	}
+	if ((nbytes = read(fd, buf, INFOBUFLEN)) == -1)
+		goto fail;
+	close(fd);
+	fd = -1;
+	buf[nbytes] = '\0';
+
+	numfields = sscanf(buf,"RPC server: %127s\n"
+		   "service: %127s %15s version %15s\n"
+		   "address: %127s\n"
+		   "protocol: %15s\n",
+		   server,
+		   service, program, version,
+		   address,
+		   protoname);
+
+	if (numfields == 5) {
+		strcpy(protoname, "tcp");
+	} else if (numfields != 6) {
+		goto fail;
+	}
+
+	port[0] = '\0';
+	if ((p = strstr(buf, "port")) != NULL)
+		sscanf(p, "port: %127s\n", port);
+
+	/* get program, and version numbers */
+	*prog = atoi(program + 1); /* skip open paren */
+	*vers = atoi(version);
+
+	if (!addrstr_to_sockaddr(addr, address, port))
+		goto fail;
+
+	*servername = get_servername(server, addr, address);
+	if (*servername == NULL)
+		goto fail;
+
+	nbytes = snprintf(buf, INFOBUFLEN, "%s@%s", service, *servername);
+	if (nbytes > INFOBUFLEN)
+		goto fail;
+
+	if (!(*servicename = calloc(strlen(buf) + 1, 1)))
+		goto fail;
+	memcpy(*servicename, buf, strlen(buf));
+
+	if (!(*protocol = strdup(protoname)))
+		goto fail;
+	return 0;
+fail:
+	printerr(0, "ERROR: failed to read service info\n");
+	if (fd != -1) close(fd);
+	free(*servername);
+	free(*servicename);
+	free(*protocol);
+	*servicename = *servername = *protocol = NULL;
+	return -1;
+}
+
+static void
+destroy_client(struct clnt_info *clp)
+{
+	if (clp->krb5_poll_index != -1)
+		memset(&pollarray[clp->krb5_poll_index], 0,
+					sizeof(struct pollfd));
+	if (clp->gssd_poll_index != -1)
+		memset(&pollarray[clp->gssd_poll_index], 0,
+					sizeof(struct pollfd));
+	if (clp->dir_fd != -1) close(clp->dir_fd);
+	if (clp->krb5_fd != -1) close(clp->krb5_fd);
+	if (clp->gssd_fd != -1) close(clp->gssd_fd);
+	free(clp->dirname);
+	free(clp->pdir);
+	free(clp->servicename);
+	free(clp->servername);
+	free(clp->protocol);
+	free(clp);
+}
+
+static struct clnt_info *
+insert_new_clnt(void)
+{
+	struct clnt_info	*clp = NULL;
+
+	if (!(clp = (struct clnt_info *)calloc(1,sizeof(struct clnt_info)))) {
+		printerr(0, "ERROR: can't malloc clnt_info: %s\n",
+			 strerror(errno));
+		goto out;
+	}
+	clp->krb5_poll_index = -1;
+	clp->gssd_poll_index = -1;
+	clp->krb5_fd = -1;
+	clp->gssd_fd = -1;
+	clp->dir_fd = -1;
+
+	TAILQ_INSERT_HEAD(&clnt_list, clp, list);
+out:
+	return clp;
+}
+
+static int
+process_clnt_dir_files(struct clnt_info * clp)
+{
+	char	name[PATH_MAX];
+	char	gname[PATH_MAX];
+	char	info_file_name[PATH_MAX];
+
+	if (clp->gssd_close_me) {
+		printerr(2, "Closing 'gssd' pipe for %s\n", clp->dirname);
+		close(clp->gssd_fd);
+		memset(&pollarray[clp->gssd_poll_index], 0,
+			sizeof(struct pollfd));
+		clp->gssd_fd = -1;
+		clp->gssd_poll_index = -1;
+		clp->gssd_close_me = 0;
+	}
+	if (clp->krb5_close_me) {
+		printerr(2, "Closing 'krb5' pipe for %s\n", clp->dirname);
+		close(clp->krb5_fd);
+		memset(&pollarray[clp->krb5_poll_index], 0,
+			sizeof(struct pollfd));
+		clp->krb5_fd = -1;
+		clp->krb5_poll_index = -1;
+		clp->krb5_close_me = 0;
+	}
+
+	if (clp->gssd_fd == -1) {
+		snprintf(gname, sizeof(gname), "%s/gssd", clp->dirname);
+		clp->gssd_fd = open(gname, O_RDWR);
+	}
+	if (clp->gssd_fd == -1) {
+		if (clp->krb5_fd == -1) {
+			snprintf(name, sizeof(name), "%s/krb5", clp->dirname);
+			clp->krb5_fd = open(name, O_RDWR);
+		}
+
+		/* If we opened a gss-specific pipe, let's try opening
+		 * the new upcall pipe again. If we succeed, close
+		 * gss-specific pipe(s).
+		 */
+		if (clp->krb5_fd != -1) {
+			clp->gssd_fd = open(gname, O_RDWR);
+			if (clp->gssd_fd != -1) {
+				if (clp->krb5_fd != -1)
+					close(clp->krb5_fd);
+				clp->krb5_fd = -1;
+			}
+		}
+	}
+
+	if ((clp->krb5_fd == -1) && (clp->gssd_fd == -1))
+		return -1;
+	snprintf(info_file_name, sizeof(info_file_name), "%s/info",
+			clp->dirname);
+	if (clp->prog == 0)
+		read_service_info(info_file_name, &clp->servicename,
+				  &clp->servername, &clp->prog, &clp->vers,
+				  &clp->protocol, (struct sockaddr *) &clp->addr);
+	return 0;
+}
+
+static int
+get_poll_index(int *ind)
+{
+	unsigned int i;
+
+	*ind = -1;
+	for (i=0; i<pollsize; i++) {
+		if (pollarray[i].events == 0) {
+			*ind = i;
+			break;
+		}
+	}
+	if (*ind == -1) {
+		printerr(0, "ERROR: No pollarray slots open\n");
+		return -1;
+	}
+	return 0;
+}
+
+
+static int
+insert_clnt_poll(struct clnt_info *clp)
+{
+	if ((clp->gssd_fd != -1) && (clp->gssd_poll_index == -1)) {
+		if (get_poll_index(&clp->gssd_poll_index)) {
+			printerr(0, "ERROR: Too many gssd clients\n");
+			return -1;
+		}
+		pollarray[clp->gssd_poll_index].fd = clp->gssd_fd;
+		pollarray[clp->gssd_poll_index].events |= POLLIN;
+	}
+
+	if ((clp->krb5_fd != -1) && (clp->krb5_poll_index == -1)) {
+		if (get_poll_index(&clp->krb5_poll_index)) {
+			printerr(0, "ERROR: Too many krb5 clients\n");
+			return -1;
+		}
+		pollarray[clp->krb5_poll_index].fd = clp->krb5_fd;
+		pollarray[clp->krb5_poll_index].events |= POLLIN;
+	}
+
+	return 0;
+}
+
+static void
+process_clnt_dir(char *dir, char *pdir)
+{
+	struct clnt_info *	clp;
+
+	if (!(clp = insert_new_clnt()))
+		goto fail_destroy_client;
+
+	if (!(clp->pdir = strdup(pdir)))
+		goto fail_destroy_client;
+
+	/* An extra for the '/', and an extra for the null */
+	if (!(clp->dirname = calloc(strlen(dir) + strlen(pdir) + 2, 1))) {
+		goto fail_destroy_client;
+	}
+	sprintf(clp->dirname, "%s/%s", pdir, dir);
+	if ((clp->dir_fd = open(clp->dirname, O_RDONLY)) == -1) {
+		if (errno != ENOENT)
+			printerr(0, "ERROR: can't open %s: %s\n",
+				 clp->dirname, strerror(errno));
+		goto fail_destroy_client;
+	}
+	fcntl(clp->dir_fd, F_SETSIG, DNOTIFY_SIGNAL);
+	fcntl(clp->dir_fd, F_NOTIFY, DN_CREATE | DN_DELETE | DN_MULTISHOT);
+
+	if (process_clnt_dir_files(clp))
+		goto fail_keep_client;
+
+	if (insert_clnt_poll(clp))
+		goto fail_destroy_client;
+
+	return;
+
+fail_destroy_client:
+	if (clp) {
+		TAILQ_REMOVE(&clnt_list, clp, list);
+		destroy_client(clp);
+	}
+fail_keep_client:
+	/* We couldn't find some subdirectories, but we keep the client
+	 * around in case we get a notification on the directory when the
+	 * subdirectories are created. */
+	return;
+}
+
+/*
+ * This is run after a DNOTIFY signal, and should clear up any
+ * directories that are no longer around, and re-scan any existing
+ * directories, since the DNOTIFY could have been in there.
+ */
+static void
+update_old_clients(struct dirent **namelist, int size, char *pdir)
+{
+	struct clnt_info *clp;
+	void *saveprev;
+	int i, stillhere;
+	char fname[PATH_MAX];
+
+	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next) {
+		/* only compare entries in the global list that are from the
+		 * same pipefs parent directory as "pdir"
+		 */
+		if (strcmp(clp->pdir, pdir) != 0) continue;
+
+		stillhere = 0;
+		for (i=0; i < size; i++) {
+			snprintf(fname, sizeof(fname), "%s/%s",
+				 pdir, namelist[i]->d_name);
+			if (strcmp(clp->dirname, fname) == 0) {
+				stillhere = 1;
+				break;
+			}
+		}
+		if (!stillhere) {
+			printerr(2, "destroying client %s\n", clp->dirname);
+			saveprev = clp->list.tqe_prev;
+			TAILQ_REMOVE(&clnt_list, clp, list);
+			destroy_client(clp);
+			clp = saveprev;
+		}
+	}
+	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next) {
+		if (!process_clnt_dir_files(clp))
+			insert_clnt_poll(clp);
+	}
+}
+
+/* Search for a client by directory name, return 1 if found, 0 otherwise */
+static int
+find_client(char *dirname, char *pdir)
+{
+	struct clnt_info	*clp;
+	char fname[PATH_MAX];
+
+	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next) {
+		snprintf(fname, sizeof(fname), "%s/%s", pdir, dirname);
+		if (strcmp(clp->dirname, fname) == 0)
+			return 1;
+	}
+	return 0;
+}
+
+static int
+process_pipedir(char *pipe_name)
+{
+	struct dirent **namelist;
+	int i, j;
+
+	if (chdir(pipe_name) < 0) {
+		printerr(0, "ERROR: can't chdir to %s: %s\n",
+			 pipe_name, strerror(errno));
+		return -1;
+	}
+
+	j = scandir(pipe_name, &namelist, NULL, alphasort);
+	if (j < 0) {
+		printerr(0, "ERROR: can't scandir %s: %s\n",
+			 pipe_name, strerror(errno));
+		return -1;
+	}
+
+	update_old_clients(namelist, j, pipe_name);
+	for (i=0; i < j; i++) {
+		if (!strncmp(namelist[i]->d_name, "clnt", 4)
+		    && !find_client(namelist[i]->d_name, pipe_name))
+			process_clnt_dir(namelist[i]->d_name, pipe_name);
+		free(namelist[i]);
+	}
+
+	free(namelist);
+
+	return 0;
+}
+
+/* Used to read (and re-read) list of clients, set up poll array. */
+static int
+update_client_list(void)
+{
+	int retval = -1;
+	struct topdirs_info *tdi;
+
+	TAILQ_FOREACH(tdi, &topdirs_list, list) {
+		retval = process_pipedir(tdi->dirname);
+		if (retval)
+			printerr(1, "WARNING: error processing %s\n",
+				 tdi->dirname);
+
+	}
+	return retval;
+}
+
 static void
 scan_poll_results(int ret)
 {
@@ -223,6 +765,28 @@ static void gssd_poll(struct pollfd *fds, unsigned long nfds)
 }
 #endif	/* !HAVE_PPOLL */
 
+
+#define FD_ALLOC_BLOCK		256
+static void
+init_client_list(void)
+{
+	struct rlimit rlim;
+
+	TAILQ_INIT(&clnt_list);
+
+	/* Eventually plan to grow/shrink poll array: */
+	if (!getrlimit(RLIMIT_NOFILE, &rlim) && rlim.rlim_cur != RLIM_INFINITY)
+		pollsize = rlim.rlim_cur;
+	else
+		pollsize = FD_ALLOC_BLOCK;
+
+	pollarray = calloc(pollsize, sizeof(struct pollfd));
+	if (!pollarray) {
+		printerr(1, "ERROR: calloc failed\n");
+		exit(EXIT_FAILURE);
+	}
+}
+
 static void
 gssd_run(void)
 {
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 91be83b..72e68d9 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -35,13 +35,9 @@
 #include <sys/queue.h>
 #include <gssapi/gssapi.h>
 
-#define MAX_FILE_NAMELEN	32
-#define FD_ALLOC_BLOCK		256
 #ifndef GSSD_PIPEFS_DIR
 #define GSSD_PIPEFS_DIR		"/var/lib/nfs/rpc_pipefs"
 #endif
-#define INFO			"info"
-#define KRB5			"krb5"
 #define DNOTIFY_SIGNAL		(SIGRTMIN + 3)
 
 #define GSSD_DEFAULT_CRED_DIR			"/tmp"
@@ -50,7 +46,6 @@
 #define GSSD_DEFAULT_MACHINE_CRED_SUFFIX	"machine"
 #define GSSD_DEFAULT_KEYTAB_FILE		"/etc/krb5.keytab"
 #define GSSD_SERVICE_NAME			"nfs"
-#define GSSD_SERVICE_NAME_LEN			3
 
 /*
  * The gss mechanisms that we can handle
@@ -65,8 +60,6 @@ extern unsigned int 		context_timeout;
 extern unsigned int rpc_timeout;
 extern char			*preferred_realm;
 
-TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;
-
 struct clnt_info {
 	TAILQ_ENTRY(clnt_info)	list;
 	char			*dirname;
@@ -86,16 +79,7 @@ struct clnt_info {
 	struct sockaddr_storage addr;
 };
 
-TAILQ_HEAD(topdirs_list_head, topdirs_info) topdirs_list;
-
-struct topdirs_info {
-	TAILQ_ENTRY(topdirs_info)	list;
-	int				fd;
-	char				dirname[];
-};
 
-void init_client_list(void);
-int update_client_list(void);
 void handle_krb5_upcall(struct clnt_info *clp);
 void handle_gssd_upcall(struct clnt_info *clp);
 
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 1d8e6a7..8957b27 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -52,7 +52,6 @@
 #include <sys/socket.h>
 #include <arpa/inet.h>
 #include <sys/fsuid.h>
-#include <sys/resource.h>
 
 #include <stdio.h>
 #include <stdlib.h>
@@ -80,548 +79,6 @@
 #include "gss_names.h"
 #include "misc.h"
 
-/*
- * pollarray:
- *      array of struct pollfd suitable to pass to poll. initialized to
- *      zero - a zero struct is ignored by poll() because the events mask is 0.
- *
- * clnt_list:
- *      linked list of struct clnt_info which associates a clntXXX directory
- *	with an index into pollarray[], and other basic data about that client.
- *
- * Directory structure: created by the kernel
- *      {rpc_pipefs}/{dir}/clntXX         : one per rpc_clnt struct in the kernel
- *      {rpc_pipefs}/{dir}/clntXX/krb5    : read uid for which kernel wants
- *					    a context, write the resulting context
- *      {rpc_pipefs}/{dir}/clntXX/info    : stores info such as server name
- *      {rpc_pipefs}/{dir}/clntXX/gssd    : pipe for all gss mechanisms using
- *					    a text-based string of parameters
- *
- * Algorithm:
- *      Poll all {rpc_pipefs}/{dir}/clntXX/YYYY files.  When data is ready,
- *      read and process; performs rpcsec_gss context initialization protocol to
- *      get a cred for that user.  Writes result to corresponding krb5 file
- *      in a form the kernel code will understand.
- *      In addition, we make sure we are notified whenever anything is
- *      created or destroyed in {rpc_pipefs} or in any of the clntXX directories,
- *      and rescan the whole {rpc_pipefs} when this happens.
- */
-
-struct pollfd * pollarray;
-
-unsigned long pollsize;  /* the size of pollaray (in pollfd's) */
-
-/* Avoid DNS reverse lookups on server names */
-int avoid_dns = 1;
-
-/*
- * convert a presentation address string to a sockaddr_storage struct. Returns
- * true on success or false on failure.
- *
- * Note that we do not populate the sin6_scope_id field here for IPv6 addrs.
- * gssd nececessarily relies on hostname resolution and DNS AAAA records
- * do not generally contain scope-id's. This means that GSSAPI auth really
- * can't work with IPv6 link-local addresses.
- *
- * We *could* consider changing this if we did something like adopt the
- * Microsoft "standard" of using the ipv6-literal.net domainname, but it's
- * not really feasible at present.
- */
-static int
-addrstr_to_sockaddr(struct sockaddr *sa, const char *node, const char *port)
-{
-	int rc;
-	struct addrinfo *res;
-	struct addrinfo hints = { .ai_flags = AI_NUMERICHOST | AI_NUMERICSERV };
-
-#ifndef IPV6_SUPPORTED
-	hints.ai_family = AF_INET;
-#endif /* IPV6_SUPPORTED */
-
-	rc = getaddrinfo(node, port, &hints, &res);
-	if (rc) {
-		printerr(0, "ERROR: unable to convert %s|%s to sockaddr: %s\n",
-			 node, port, rc == EAI_SYSTEM ? strerror(errno) :
-						gai_strerror(rc));
-		return 0;
-	}
-
-#ifdef IPV6_SUPPORTED
-	/*
-	 * getnameinfo ignores the scopeid. If the address turns out to have
-	 * a non-zero scopeid, we can't use it -- the resolved host might be
-	 * completely different from the one intended.
-	 */
-	if (res->ai_addr->sa_family == AF_INET6) {
-		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)res->ai_addr;
-		if (sin6->sin6_scope_id) {
-			printerr(0, "ERROR: address %s has non-zero "
-				    "sin6_scope_id!\n", node);
-			freeaddrinfo(res);
-			return 0;
-		}
-	}
-#endif /* IPV6_SUPPORTED */
-
-	memcpy(sa, res->ai_addr, res->ai_addrlen);
-	freeaddrinfo(res);
-	return 1;
-}
-
-/*
- * convert a sockaddr to a hostname
- */
-static char *
-get_servername(const char *name, const struct sockaddr *sa, const char *addr)
-{
-	socklen_t		addrlen;
-	int			err;
-	char			*hostname;
-	char			hbuf[NI_MAXHOST];
-	unsigned char		buf[sizeof(struct in6_addr)];
-
-	if (avoid_dns) {
-		/*
-		 * Determine if this is a server name, or an IP address.
-		 * If it is an IP address, do the DNS lookup otherwise
-		 * skip the DNS lookup.
-		 */
-		int is_fqdn = 1;
-		if (strchr(name, '.') == NULL)
-			is_fqdn = 0; /* local name */
-		else if (inet_pton(AF_INET, name, buf) == 1)
-			is_fqdn = 0; /* IPv4 address */
-		else if (inet_pton(AF_INET6, name, buf) == 1)
-			is_fqdn = 0; /* IPv6 addrss */
-
-		if (is_fqdn) {
-			return strdup(name);
-		}
-		/* Sorry, cannot avoid dns after all */
-	}
-
-	switch (sa->sa_family) {
-	case AF_INET:
-		addrlen = sizeof(struct sockaddr_in);
-		break;
-#ifdef IPV6_SUPPORTED
-	case AF_INET6:
-		addrlen = sizeof(struct sockaddr_in6);
-		break;
-#endif /* IPV6_SUPPORTED */
-	default:
-		printerr(0, "ERROR: unrecognized addr family %d\n",
-			 sa->sa_family);
-		return NULL;
-	}
-
-	err = getnameinfo(sa, addrlen, hbuf, sizeof(hbuf), NULL, 0,
-			  NI_NAMEREQD);
-	if (err) {
-		printerr(0, "ERROR: unable to resolve %s to hostname: %s\n",
-			 addr, err == EAI_SYSTEM ? strerror(errno) :
-						   gai_strerror(err));
-		return NULL;
-	}
-
-	hostname = strdup(hbuf);
-
-	return hostname;
-}
-
-/* XXX buffer problems: */
-static int
-read_service_info(char *info_file_name, char **servicename, char **servername,
-		  int *prog, int *vers, char **protocol,
-		  struct sockaddr *addr) {
-#define INFOBUFLEN 256
-	char		buf[INFOBUFLEN + 1];
-	static char	server[128];
-	int		nbytes;
-	static char	service[128];
-	static char	address[128];
-	char		program[16];
-	char		version[16];
-	char		protoname[16];
-	char		port[128];
-	char		*p;
-	int		fd = -1;
-	int		numfields;
-
-	*servicename = *servername = *protocol = NULL;
-
-	if ((fd = open(info_file_name, O_RDONLY)) == -1) {
-		printerr(0, "ERROR: can't open %s: %s\n", info_file_name,
-			 strerror(errno));
-		goto fail;
-	}
-	if ((nbytes = read(fd, buf, INFOBUFLEN)) == -1)
-		goto fail;
-	close(fd);
-	fd = -1;
-	buf[nbytes] = '\0';
-
-	numfields = sscanf(buf,"RPC server: %127s\n"
-		   "service: %127s %15s version %15s\n"
-		   "address: %127s\n"
-		   "protocol: %15s\n",
-		   server,
-		   service, program, version,
-		   address,
-		   protoname);
-
-	if (numfields == 5) {
-		strcpy(protoname, "tcp");
-	} else if (numfields != 6) {
-		goto fail;
-	}
-
-	port[0] = '\0';
-	if ((p = strstr(buf, "port")) != NULL)
-		sscanf(p, "port: %127s\n", port);
-
-	/* get program, and version numbers */
-	*prog = atoi(program + 1); /* skip open paren */
-	*vers = atoi(version);
-
-	if (!addrstr_to_sockaddr(addr, address, port))
-		goto fail;
-
-	*servername = get_servername(server, addr, address);
-	if (*servername == NULL)
-		goto fail;
-
-	nbytes = snprintf(buf, INFOBUFLEN, "%s@%s", service, *servername);
-	if (nbytes > INFOBUFLEN)
-		goto fail;
-
-	if (!(*servicename = calloc(strlen(buf) + 1, 1)))
-		goto fail;
-	memcpy(*servicename, buf, strlen(buf));
-
-	if (!(*protocol = strdup(protoname)))
-		goto fail;
-	return 0;
-fail:
-	printerr(0, "ERROR: failed to read service info\n");
-	if (fd != -1) close(fd);
-	free(*servername);
-	free(*servicename);
-	free(*protocol);
-	*servicename = *servername = *protocol = NULL;
-	return -1;
-}
-
-static void
-destroy_client(struct clnt_info *clp)
-{
-	if (clp->krb5_poll_index != -1)
-		memset(&pollarray[clp->krb5_poll_index], 0,
-					sizeof(struct pollfd));
-	if (clp->gssd_poll_index != -1)
-		memset(&pollarray[clp->gssd_poll_index], 0,
-					sizeof(struct pollfd));
-	if (clp->dir_fd != -1) close(clp->dir_fd);
-	if (clp->krb5_fd != -1) close(clp->krb5_fd);
-	if (clp->gssd_fd != -1) close(clp->gssd_fd);
-	free(clp->dirname);
-	free(clp->pdir);
-	free(clp->servicename);
-	free(clp->servername);
-	free(clp->protocol);
-	free(clp);
-}
-
-static struct clnt_info *
-insert_new_clnt(void)
-{
-	struct clnt_info	*clp = NULL;
-
-	if (!(clp = (struct clnt_info *)calloc(1,sizeof(struct clnt_info)))) {
-		printerr(0, "ERROR: can't malloc clnt_info: %s\n",
-			 strerror(errno));
-		goto out;
-	}
-	clp->krb5_poll_index = -1;
-	clp->gssd_poll_index = -1;
-	clp->krb5_fd = -1;
-	clp->gssd_fd = -1;
-	clp->dir_fd = -1;
-
-	TAILQ_INSERT_HEAD(&clnt_list, clp, list);
-out:
-	return clp;
-}
-
-static int
-process_clnt_dir_files(struct clnt_info * clp)
-{
-	char	name[PATH_MAX];
-	char	gname[PATH_MAX];
-	char	info_file_name[PATH_MAX];
-
-	if (clp->gssd_close_me) {
-		printerr(2, "Closing 'gssd' pipe for %s\n", clp->dirname);
-		close(clp->gssd_fd);
-		memset(&pollarray[clp->gssd_poll_index], 0,
-			sizeof(struct pollfd));
-		clp->gssd_fd = -1;
-		clp->gssd_poll_index = -1;
-		clp->gssd_close_me = 0;
-	}
-	if (clp->krb5_close_me) {
-		printerr(2, "Closing 'krb5' pipe for %s\n", clp->dirname);
-		close(clp->krb5_fd);
-		memset(&pollarray[clp->krb5_poll_index], 0,
-			sizeof(struct pollfd));
-		clp->krb5_fd = -1;
-		clp->krb5_poll_index = -1;
-		clp->krb5_close_me = 0;
-	}
-
-	if (clp->gssd_fd == -1) {
-		snprintf(gname, sizeof(gname), "%s/gssd", clp->dirname);
-		clp->gssd_fd = open(gname, O_RDWR);
-	}
-	if (clp->gssd_fd == -1) {
-		if (clp->krb5_fd == -1) {
-			snprintf(name, sizeof(name), "%s/krb5", clp->dirname);
-			clp->krb5_fd = open(name, O_RDWR);
-		}
-
-		/* If we opened a gss-specific pipe, let's try opening
-		 * the new upcall pipe again. If we succeed, close
-		 * gss-specific pipe(s).
-		 */
-		if (clp->krb5_fd != -1) {
-			clp->gssd_fd = open(gname, O_RDWR);
-			if (clp->gssd_fd != -1) {
-				if (clp->krb5_fd != -1)
-					close(clp->krb5_fd);
-				clp->krb5_fd = -1;
-			}
-		}
-	}
-
-	if ((clp->krb5_fd == -1) && (clp->gssd_fd == -1))
-		return -1;
-	snprintf(info_file_name, sizeof(info_file_name), "%s/info",
-			clp->dirname);
-	if (clp->prog == 0)
-		read_service_info(info_file_name, &clp->servicename,
-				  &clp->servername, &clp->prog, &clp->vers,
-				  &clp->protocol, (struct sockaddr *) &clp->addr);
-	return 0;
-}
-
-static int
-get_poll_index(int *ind)
-{
-	unsigned int i;
-
-	*ind = -1;
-	for (i=0; i<pollsize; i++) {
-		if (pollarray[i].events == 0) {
-			*ind = i;
-			break;
-		}
-	}
-	if (*ind == -1) {
-		printerr(0, "ERROR: No pollarray slots open\n");
-		return -1;
-	}
-	return 0;
-}
-
-
-static int
-insert_clnt_poll(struct clnt_info *clp)
-{
-	if ((clp->gssd_fd != -1) && (clp->gssd_poll_index == -1)) {
-		if (get_poll_index(&clp->gssd_poll_index)) {
-			printerr(0, "ERROR: Too many gssd clients\n");
-			return -1;
-		}
-		pollarray[clp->gssd_poll_index].fd = clp->gssd_fd;
-		pollarray[clp->gssd_poll_index].events |= POLLIN;
-	}
-
-	if ((clp->krb5_fd != -1) && (clp->krb5_poll_index == -1)) {
-		if (get_poll_index(&clp->krb5_poll_index)) {
-			printerr(0, "ERROR: Too many krb5 clients\n");
-			return -1;
-		}
-		pollarray[clp->krb5_poll_index].fd = clp->krb5_fd;
-		pollarray[clp->krb5_poll_index].events |= POLLIN;
-	}
-
-	return 0;
-}
-
-static void
-process_clnt_dir(char *dir, char *pdir)
-{
-	struct clnt_info *	clp;
-
-	if (!(clp = insert_new_clnt()))
-		goto fail_destroy_client;
-
-	if (!(clp->pdir = strdup(pdir)))
-		goto fail_destroy_client;
-
-	/* An extra for the '/', and an extra for the null */
-	if (!(clp->dirname = calloc(strlen(dir) + strlen(pdir) + 2, 1))) {
-		goto fail_destroy_client;
-	}
-	sprintf(clp->dirname, "%s/%s", pdir, dir);
-	if ((clp->dir_fd = open(clp->dirname, O_RDONLY)) == -1) {
-		if (errno != ENOENT)
-			printerr(0, "ERROR: can't open %s: %s\n",
-				 clp->dirname, strerror(errno));
-		goto fail_destroy_client;
-	}
-	fcntl(clp->dir_fd, F_SETSIG, DNOTIFY_SIGNAL);
-	fcntl(clp->dir_fd, F_NOTIFY, DN_CREATE | DN_DELETE | DN_MULTISHOT);
-
-	if (process_clnt_dir_files(clp))
-		goto fail_keep_client;
-
-	if (insert_clnt_poll(clp))
-		goto fail_destroy_client;
-
-	return;
-
-fail_destroy_client:
-	if (clp) {
-		TAILQ_REMOVE(&clnt_list, clp, list);
-		destroy_client(clp);
-	}
-fail_keep_client:
-	/* We couldn't find some subdirectories, but we keep the client
-	 * around in case we get a notification on the directory when the
-	 * subdirectories are created. */
-	return;
-}
-
-void
-init_client_list(void)
-{
-	struct rlimit rlim;
-	TAILQ_INIT(&clnt_list);
-	/* Eventually plan to grow/shrink poll array: */
-	pollsize = FD_ALLOC_BLOCK;
-	if (getrlimit(RLIMIT_NOFILE, &rlim) == 0 &&
-	    rlim.rlim_cur != RLIM_INFINITY)
-		pollsize = rlim.rlim_cur;
-	pollarray = calloc(pollsize, sizeof(struct pollfd));
-}
-
-/*
- * This is run after a DNOTIFY signal, and should clear up any
- * directories that are no longer around, and re-scan any existing
- * directories, since the DNOTIFY could have been in there.
- */
-static void
-update_old_clients(struct dirent **namelist, int size, char *pdir)
-{
-	struct clnt_info *clp;
-	void *saveprev;
-	int i, stillhere;
-	char fname[PATH_MAX];
-
-	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next) {
-		/* only compare entries in the global list that are from the
-		 * same pipefs parent directory as "pdir"
-		 */
-		if (strcmp(clp->pdir, pdir) != 0) continue;
-
-		stillhere = 0;
-		for (i=0; i < size; i++) {
-			snprintf(fname, sizeof(fname), "%s/%s",
-				 pdir, namelist[i]->d_name);
-			if (strcmp(clp->dirname, fname) == 0) {
-				stillhere = 1;
-				break;
-			}
-		}
-		if (!stillhere) {
-			printerr(2, "destroying client %s\n", clp->dirname);
-			saveprev = clp->list.tqe_prev;
-			TAILQ_REMOVE(&clnt_list, clp, list);
-			destroy_client(clp);
-			clp = saveprev;
-		}
-	}
-	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next) {
-		if (!process_clnt_dir_files(clp))
-			insert_clnt_poll(clp);
-	}
-}
-
-/* Search for a client by directory name, return 1 if found, 0 otherwise */
-static int
-find_client(char *dirname, char *pdir)
-{
-	struct clnt_info	*clp;
-	char fname[PATH_MAX];
-
-	for (clp = clnt_list.tqh_first; clp != NULL; clp = clp->list.tqe_next) {
-		snprintf(fname, sizeof(fname), "%s/%s", pdir, dirname);
-		if (strcmp(clp->dirname, fname) == 0)
-			return 1;
-	}
-	return 0;
-}
-
-static int
-process_pipedir(char *pipe_name)
-{
-	struct dirent **namelist;
-	int i, j;
-
-	if (chdir(pipe_name) < 0) {
-		printerr(0, "ERROR: can't chdir to %s: %s\n",
-			 pipe_name, strerror(errno));
-		return -1;
-	}
-
-	j = scandir(pipe_name, &namelist, NULL, alphasort);
-	if (j < 0) {
-		printerr(0, "ERROR: can't scandir %s: %s\n",
-			 pipe_name, strerror(errno));
-		return -1;
-	}
-
-	update_old_clients(namelist, j, pipe_name);
-	for (i=0; i < j; i++) {
-		if (!strncmp(namelist[i]->d_name, "clnt", 4)
-		    && !find_client(namelist[i]->d_name, pipe_name))
-			process_clnt_dir(namelist[i]->d_name, pipe_name);
-		free(namelist[i]);
-	}
-
-	free(namelist);
-
-	return 0;
-}
-
-/* Used to read (and re-read) list of clients, set up poll array. */
-int
-update_client_list(void)
-{
-	int retval = -1;
-	struct topdirs_info *tdi;
-
-	TAILQ_FOREACH(tdi, &topdirs_list, list) {
-		retval = process_pipedir(tdi->dirname);
-		if (retval)
-			printerr(1, "WARNING: error processing %s\n",
-				 tdi->dirname);
-
-	}
-	return retval;
-}
-
 /* Encryption types supported by the kernel rpcsec_gss code */
 int num_krb5_enctypes = 0;
 krb5_enctype *krb5_enctypes = NULL;

