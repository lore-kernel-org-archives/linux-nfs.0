From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] nfs-utils: introduce new statd implementation (2nd part)
Date: Wed, 05 Aug 2009 10:45:54 -0400
Message-ID: <20090805144553.12866.1607.stgit@matisse.1015granger.net>
References: <20090805143550.12866.8377.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:43643 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934578AbZHEOqX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2009 10:46:23 -0400
In-Reply-To: <20090805143550.12866.8377.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Finish introducing source files for new statd.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/new-statd/smncall.c |  774 +++++++++++++++++++++++++++++++++++++++++
 utils/new-statd/svc.c     |  841 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 1615 insertions(+), 0 deletions(-)
 create mode 100644 utils/new-statd/smncall.c
 create mode 100644 utils/new-statd/svc.c

diff --git a/utils/new-statd/smncall.c b/utils/new-statd/smncall.c
new file mode 100644
index 0000000..e6aba47
--- /dev/null
+++ b/utils/new-statd/smncall.c
@@ -0,0 +1,774 @@
+/*
+ * Copyright 2009 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * nfs-utils is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+/*
+ * NSM for Linux.
+ */
+
+/*
+ * Send reboot notifications to remote peers on our notify list.
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <unistd.h>
+#include <signal.h>
+#include <fcntl.h>
+#include <errno.h>
+
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <sys/wait.h>
+
+#include <netinet/in.h>
+#include <arpa/inet.h>
+
+#include "statd.h"
+#include "nfsrpc.h"
+
+static const char *statd_pgmtbl[] = {
+       "status",
+       NULL,
+};
+
+static void
+statd_delete_notified_host(const char *mon_name, const char *my_name)
+{
+	sqlite3_stmt *stmt;
+	sqlite3 *db;
+	char *sql;
+	bool_t rc;
+
+	db = statd_open_db(SQLITE_OPEN_READWRITE);
+	if (db == NULL)
+		return;
+
+	sql = sqlite3_mprintf("DELETE FROM " STATD_NOTIFY_TABLENAME
+				" WHERE mon_name='%q' and my_name='%q'",
+					mon_name, my_name);
+	if (sql == NULL) {
+		xlog(L_ERROR, "Failed to generate DELETE FROM statement", __func__);
+		goto out_close;
+	}
+
+	rc = statd_prepare_stmt(db, &stmt, sql);
+	sqlite3_free(sql);
+	if (!rc)
+		goto out_close;
+
+	switch (sqlite3_step(stmt)) {
+	case SQLITE_DONE:
+		if (sqlite3_changes(db) == 0)
+			xlog(L_ERROR, "Mon_name '%s' not found "
+					"in the notify list", mon_name);
+		else
+			xlog(D_GENERAL, "Mon_name '%s' removed from notify list",
+					mon_name);
+		break;
+	default:
+		xlog(L_ERROR, "Failed to delete row for mon_name '%s': %s",
+				mon_name, sqlite3_errmsg(db));
+	}
+
+	statd_finalize_stmt(stmt);
+
+out_close:
+	statd_close_db(db);
+}
+
+/*
+ * Returns 1 if the table already exists, or was created; otherwise
+ * zero is returned if an error occurred.
+ */
+static bool_t
+statd_create_notify_table(sqlite3 *db)
+{
+	sqlite3_stmt *stmt;
+	bool_t result;
+	int rc;
+
+	result = FALSE;
+
+	rc = sqlite3_prepare_v2(db, "CREATE TABLE " STATD_NOTIFY_TABLENAME
+					" (mon_name TEXT NOT NULL,"
+					" my_name TEXT NOT NULL,"
+					" protocol TEXT NOT NULL,"
+					" UNIQUE(mon_name, my_name));",
+						-1, &stmt, NULL);
+	switch (rc) {
+	case SQLITE_OK:
+		rc = sqlite3_step(stmt);
+		switch (rc) {
+		case SQLITE_DONE:
+			result = TRUE;
+			xlog(D_GENERAL, "Table '" STATD_NOTIFY_TABLENAME
+					"' created successfully");
+			break;
+		default:
+			xlog(L_ERROR, "Failed to create table '"
+					STATD_NOTIFY_TABLENAME "': %s",
+					sqlite3_errmsg(db));
+		}
+
+		statd_finalize_stmt(stmt);
+		break;
+	case SQLITE_ERROR:
+		result = TRUE;
+		xlog(D_GENERAL, "Table '" STATD_NOTIFY_TABLENAME
+				"' already exists");
+		break;
+	default:
+		xlog(L_ERROR, "Failed to compile SQL: %s",
+				sqlite3_errmsg(db));
+		xlog(L_ERROR, "SQL: %s");
+		break;
+	}
+
+	return result;
+}
+
+static bool_t
+statd_merge_notify_list(sqlite3 *db)
+{
+	char *err_msg;
+
+	if (sqlite3_exec(db,
+		"INSERT OR REPLACE INTO " STATD_NOTIFY_TABLENAME
+		" SELECT mon_name,my_name,protocol FROM " STATD_MONITOR_TABLENAME ";",
+					NULL, 0, &err_msg) != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to merge notify list: %s", err_msg);
+		sqlite3_free(err_msg);
+		return FALSE;
+	}
+	return TRUE;
+}
+
+static bool_t
+statd_empty_monitor_list(sqlite3 *db)
+{
+	char *err_msg;
+
+	err_msg = NULL;
+	if (sqlite3_exec(db, "DELETE FROM " STATD_MONITOR_TABLENAME ,
+					NULL, 0, &err_msg) != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to empty the monitor list: %s",
+					sqlite3_errmsg(db));
+		sqlite3_free(err_msg);
+		return FALSE;
+	}
+
+	xlog(D_GENERAL, "All monitor list entries were deleted");
+	return TRUE;
+}
+
+/*
+ * Returns 1 if monitor list was retired.  Returns zero if there
+ * were no hosts to notify.  Otherwise -1 is returned if some
+ * error occurred.
+ */
+static int
+statd_retire_monitor_list(void)
+{
+	sqlite3 *db;
+	int result;
+
+	result = 0;
+
+	db = statd_open_db(SQLITE_OPEN_READWRITE);
+	if (db == NULL)
+		return result;
+
+	if (!statd_begin_transaction(db))
+		goto out_close;
+
+	if (!statd_update_nsm_state(db))
+		goto out_rollback;
+
+	if (!statd_create_notify_table(db))
+		goto out_rollback;
+
+	if (!statd_merge_notify_list(db))
+		goto out_rollback;
+
+	if (!statd_empty_monitor_list(db))
+		goto out_rollback;
+
+	statd_end_transaction(db);
+	result = 1;
+
+	xlog(D_CALL, "Retired monitor list");
+
+out_close:
+	statd_close_db(db);
+	return result;
+
+out_rollback:
+	statd_rollback_transaction(db);
+	goto out_close;
+}
+
+/*
+ * Ensure IP addresses and hostnames are mapped to a working address.
+ * If @hostname is NULL, generate an appropriate ANYADDR address instead.
+ *
+ * You might think the bind address is loop invariant (ie the same for
+ * all notified peers).  Unfortunately the DNS lookup here will fail if
+ * sm-notify is started before networking is up on the local host.  So
+ * we have to make statd_verify_bindaddr() part of the retry loop.
+ */
+static struct addrinfo *
+statd_verify_bindaddr(const char *hostname, const uint16_t port,
+		const int family, const int transport)
+{
+	struct addrinfo gai_hint = {
+		.ai_flags	= AI_NUMERICSERV,
+		.ai_family	= family,
+		.ai_protocol	= transport,
+	};
+	struct addrinfo	*gai_results;
+	char buf[8];
+	int error;
+
+	buf[0] = '\0';
+	if (port != 0)
+		(void)snprintf(buf, sizeof(buf), "%u", port);
+	if (hostname == NULL)
+		gai_hint.ai_flags = AI_PASSIVE;
+	error = getaddrinfo(hostname, buf, &gai_hint, &gai_results);
+	switch (error) {
+	case 0:
+		return gai_results;
+	case EAI_NONAME:
+		if (hostname != NULL)
+			xlog(L_ERROR, "The supplied source address \"%s\" "
+				"is invalid", hostname);
+		else
+			/* Shouldn't ever happen, but just in case... */
+			xlog(L_ERROR, "EAI_NONAME for a NULL hostname?");
+		break;
+	case EAI_SYSTEM:
+		xlog(L_ERROR, "While determining bind address: %m");
+		break;
+	default:
+		xlog(L_ERROR, "While determining bind address: %s",
+			gai_strerror(error));
+	}
+
+	return NULL;
+}
+
+static int
+statd_socket(const struct addrinfo *gai_results)
+{
+	int sock;
+
+	sock = socket(gai_results->ai_family, gai_results->ai_socktype, 0);
+	if (sock < 0) {
+		xlog(L_ERROR, "Failed to create RPC socket: %m");
+		return -1;
+	}
+
+	fcntl(sock, F_SETFL, O_NONBLOCK);
+	if (gai_results->ai_family == AF_INET6) {
+		const int zero = 0;
+		/* We want replies from both IPv4 and IPv6 remotes, please */
+		setsockopt(sock, SOL_IPV6, IPV6_V6ONLY,
+				(char *)&zero, sizeof(zero));
+	}
+
+	return sock;
+}
+
+static int
+statd_bind(int sock, struct addrinfo *gai_results)
+{
+	struct sockaddr *sap = gai_results->ai_addr;
+	socklen_t salen = gai_results->ai_addrlen;
+
+	/* port was set by getaddrinfo(3) */
+	if (bind(sock, sap, salen) == -1) {
+		xlog(L_ERROR, "Failed to bind RPC socket: %m");
+		close(sock);
+		sock = -1;
+	}
+
+	return sock;
+}
+
+/*
+ * @bindaddr can be NULL; in this case, an appropriate ANYADDR is used.
+ * @srcport can be zero; in this case, an appropriate reserved port
+ * is used.
+ *
+ * Returns a bound socket file descriptor, or -1 if an error occurs.
+ */
+static int
+statd_create_socket(const char *bindaddr, const uint16_t srcport,
+			const int family, const int protocol)
+{
+	struct addrinfo *gai_results;
+	char *transport;
+	int sock;
+
+	switch (protocol) {
+	case IPPROTO_UDP:
+		transport = "datagram";
+		break;
+	case IPPROTO_TCP:
+		transport = "stream";
+		break;
+	default:
+		transport = "unknown";
+	}
+	xlog(D_CALL, "Creating %s socket with bindaddr '%s' and port %u",
+			transport, bindaddr, srcport);
+
+	gai_results = statd_verify_bindaddr(bindaddr, srcport, family, protocol);
+	if (gai_results == NULL)
+		return -1;
+
+	sock = statd_socket(gai_results);
+	if (sock < 0)
+		return -1;
+
+	sock = statd_bind(sock, gai_results);
+
+	freeaddrinfo(gai_results);
+	return sock;
+}
+
+/*
+ * @timeout is modified to contain the time remaining (i.e. time
+ * provided minus time elasped).
+ *
+ * Returns zero on success, or returns -1 on error.  errno is
+ * set to reflect the nature of the error.
+ */
+static int
+statd_connect_socket(const int sock, const struct sockaddr *sap,
+			const socklen_t salen, struct timeval *timeout)
+{
+	int save, result;
+	fd_set rset;
+
+	result = -1;
+
+	save = fcntl(sock, F_GETFL, 0);
+	if (save == -1) {
+		xlog(L_ERROR, "Failed to get socket flags: %m");
+		goto out;
+	}
+
+	if (fcntl(sock, F_SETFL, save | O_NONBLOCK) == -1) {
+		xlog(L_ERROR, "Failed to set socket flags: %m");
+		goto out;
+	}
+
+	if (connect(sock, sap, salen) == -1) {
+		switch (errno) {
+		case EINPROGRESS:
+			break;
+		case EINVAL:
+			xlog(L_ERROR, "Invalid bind address");
+			goto out_restore;
+		default:
+			xlog(L_ERROR, "Failed to connect socket: %m");
+			goto out_restore;
+		}
+	} else {
+		result = 0;
+		goto out_restore;
+	}
+
+	FD_ZERO(&rset);
+	FD_SET(sock, &rset);
+
+	result = select(sock + 1, NULL, &rset, NULL, timeout);
+	if (result <= 0) {
+		if (result == 0)
+			errno = ETIMEDOUT;
+		xlog(L_ERROR, "Failed to select: %m");
+		result = -1;
+		goto out_restore;
+	}
+
+	if (FD_ISSET(sock, &rset)) {
+		socklen_t len = (socklen_t)sizeof(result);
+
+		if (getsockopt(sock, SOL_SOCKET, SO_ERROR, &result, &len) == -1) {
+			xlog(L_ERROR, "Failed to get socket options: %m");
+			result = -1;
+			goto out_restore;
+		}
+
+		if (result != 0) {
+			xlog(L_ERROR, "Invalid socket options: %s",
+					strerror(result));
+			errno = result;
+			result = -1;
+		}
+	}
+
+out_restore:
+	(void)fcntl(sock, F_SETFL, save);
+
+out:
+	return result;
+}
+
+/*
+ * clnt_create_timed(3) could do all this for us, but we have to
+ * allow admins to set the socket's bind address and source port.
+ *
+ * @bindaddr is supposedly necessary because Linux's statd can
+ * scrape the source address of incoming SM_NOTIFY requests to
+ * figure out if it knows about this host.
+ */
+static CLIENT *
+statd_create_clnt(struct sockaddr *sap, const socklen_t salen,
+		const char *bindaddr, const unsigned short srcport,
+		const unsigned short protocol, struct timeval *timeout)
+{
+	CLIENT *clnt = NULL;
+	struct netbuf nbuf = {
+		.maxlen	= salen,
+		.len	= salen,
+		.buf	= sap,
+	};
+	rpcprot_t program;
+	uint16_t port;
+	int sock;
+
+	/*
+	 * Chicken and egg... rpcb_getaddr(3t) could give us the
+	 * address and port of the remote, but we would need to pass
+	 * it an nconf.  To get an nconf, we need the transport
+	 * protocol and the address family.  But we don't know until
+	 * we have the remote's address what address family to use.
+	 *
+	 * Lame.
+	 */
+	program = nfs_getrpcbyname(SM_PROG, statd_pgmtbl);
+	port = nfs_getport(nbuf.buf, nbuf.len, program, SM_VERS, protocol);
+	if (port == 0) {
+		xlog(L_WARNING, "Failed to get server's port: %s",
+				clnt_sperrno(rpc_createerr.cf_stat));
+		return NULL;
+	}
+	nfs_set_port(sap, port);
+
+	/*
+	 * ...and we can't create our transport socket until we know
+	 * which address family we need to use to contact the remote.
+	 */
+	sock = statd_create_socket(bindaddr, srcport,
+				sap->sa_family, protocol);
+	if (sock == -1)
+		return NULL;
+
+	if (protocol == IPPROTO_TCP)
+		if (statd_connect_socket(sock, nbuf.buf, nbuf.len,
+							timeout) == -1) {
+			close(sock);
+			return NULL;
+		}
+
+	clnt = clnt_tli_create(sock, NULL, &nbuf, program, SM_VERS,
+					RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);
+	if (clnt == NULL) {
+		xlog(L_WARNING, "Failed to create RPC client: %s",
+				clnt_sperrno(rpc_createerr.cf_stat));
+		return NULL;
+	}
+
+	CLNT_CONTROL(clnt, CLSET_FD_CLOSE, NULL);
+	return clnt;
+}
+
+static unsigned int
+statd_sm_notify_call(struct sockaddr *sap, const socklen_t salen,
+		const char *bindaddr, const unsigned short srcport,
+		const unsigned short protocol,
+		const char *my_name, const int my_state)
+{
+	struct timeval timeout = { SMN_TIMEOUT, 0 };
+	static char hostbuf[NI_MAXHOST];
+	struct stat_chge new_status;
+	enum clnt_stat status;
+	CLIENT *clnt;
+
+	getnameinfo(sap, salen, hostbuf, sizeof(hostbuf), NULL, 0, NI_NUMERICHOST);
+	xlog(D_CALL, "Attempting to send notification to %s", hostbuf);
+
+	nfs_clear_rpc_createerr();
+	clnt = statd_create_clnt(sap, salen, bindaddr, srcport,
+						protocol, &timeout);
+	if (clnt == NULL)
+		return 0;
+
+	new_status.state = my_state;
+	new_status.mon_name = strdup(my_name);
+	status = clnt_call(clnt, SM_NOTIFY,
+				(xdrproc_t)xdr_stat_chge, (caddr_t)&new_status,
+				(xdrproc_t)xdr_void, NULL, timeout);
+	free(new_status.mon_name);
+	clnt_destroy(clnt);
+
+	if (status != RPC_SUCCESS) {
+		xlog(D_CALL, "Notification RPC failed: %s", clnt_sperrno(status));
+		return 0;
+	}
+
+	xlog(D_CALL, "Notification RPC succeeded");
+	return 1;
+}
+
+/*
+ * Attempt to send to each of this host's known IP addresses.
+ * This is a weak attempt to send from each interface and/or
+ * protocol family on the local host.
+ *
+ * We might want to beef this up by looking at what network
+ * interfaces exist on the system and trying to send from
+ * each of them.  Unfortunately in the world of DHCP and
+ * NetworkManager, we can't count on the local network
+ * configuration to be stable, especially at boot time when
+ * this function is typically invoked..
+ *
+ * If we get at least one through, consider it a success and
+ * return TRUE.
+ */
+static bool_t
+statd_notify_host(const char *hostname, const char *bindaddr,
+		const unsigned short srcport, const unsigned short protocol,
+		const char *my_name, const int my_state)
+{
+	struct addrinfo gai_hint = {
+#ifdef IPV6_SUPPORTED
+		.ai_family	= AF_UNSPEC,
+		.ai_flags	= AI_ADDRCONFIG,
+#else	/* !IPV6_SUPPORTED */
+		.ai_family	= AF_INET,
+#endif	/* !IPV6_SUPPORTED */
+	};
+	struct addrinfo	*gai_results, *ai;
+	char canon_name[NI_MAXHOST];
+	unsigned int count;
+
+	gai_hint.ai_protocol = protocol;
+	gai_results = statd_get_address_list(canon_name, &gai_hint);
+	if (gai_results == NULL)
+		return FALSE;
+
+	count = 0;
+	ai = gai_results;
+	while (ai != NULL) {
+		count += statd_sm_notify_call(gai_results->ai_addr,
+				gai_results->ai_addrlen, bindaddr, srcport,
+				protocol, my_name, my_state);
+		ai = ai->ai_next;
+	}
+	freeaddrinfo(gai_results);
+
+	if (count == 0) {
+		xlog(D_CALL, "Failed to notify Host %s", hostname);
+		return FALSE;
+	}
+
+	xlog(D_CALL, "Host %s notified successfully", hostname);
+	return TRUE;
+}
+
+/*
+ * Keep trying until we succeed or our timer expires
+ */
+static void
+statd_notification_child(const char *mon_name, const char *bindaddr,
+		const unsigned short srcport, const char *transport,
+		const char *my_name, const int my_state,
+		const time_t timeout)
+{
+	const struct sigaction statd_create_sigaction = {
+		.sa_handler	= SIG_IGN,
+	};
+	unsigned int sleep_time = SMN_TIMEOUT;
+	unsigned short protocol;
+
+	(void)setpriority(PRIO_PROCESS, 0, 19);
+
+	if (strcmp(transport, "tcp") == 0) {
+		/* Don't bother our parent if the other end
+		 * closes our TCP connection. */
+		(void)sigaction(SIGPIPE, &statd_create_sigaction, NULL);
+		protocol = IPPROTO_TCP;
+	} else if (strcmp(transport, "udp") == 0) {
+		protocol = IPPROTO_UDP;
+	} else {
+		xlog(L_ERROR, "Unknown transport protocol for notification");
+		return;
+	}
+
+	for (;;) {
+		if (statd_notify_host(mon_name, bindaddr, srcport,
+						protocol, my_name, my_state)) {
+			statd_delete_notified_host(mon_name, my_name);
+			break;
+		}
+
+		if (timeout != 0 && timeout < time(NULL)) {
+			xlog(L_WARNING, "Could not notify %s; giving up",
+				mon_name);
+			break;
+		}
+
+		(void)sleep(sleep_time);
+
+		sleep_time <<= 2;
+		if (sleep_time > 60)
+			sleep_time = 60;
+	}
+}
+
+/*
+ * Hosts that can't be contacted now shouldn't block notification
+ * of active hosts that may be farther down the notify list.  So
+ * fork off all notifications.
+ */
+static void
+statd_fork_and_notify(const char *mon_name, const char *bindaddr,
+		const unsigned short srcport, const char *transport,
+		const char *my_name, const int my_state,
+		const unsigned long max_retry_minutes)
+{
+	time_t timeout = 0;
+
+	if (max_retry_minutes != 0)
+		timeout = time(NULL) + max_retry_minutes * 60;
+
+	switch (fork()) {
+	case -1:
+		xlog(L_ERROR, "Failed to fork notification process: %m");
+		break;
+	case 0:
+		/* Child. */
+		statd_notification_child(mon_name, bindaddr, srcport,
+					transport, my_name, my_state, timeout);
+		_exit(EXIT_SUCCESS);
+	default:
+		/* Parent. */
+		usleep(100000);
+		break;
+	}
+}
+
+/*
+ * Returns TRUE if all listed notifications have been scheduled;
+ * otherwise FALSE is returned.
+ */
+static bool_t
+statd_iterate_notify_list(const char *bindaddr, const unsigned short srcport,
+		const unsigned long max_retry_minutes)
+{
+	int i, nrow, ncolumn, my_state;
+	char **resultp;
+	char *err_msg;
+	bool_t result;
+	sqlite3 *db;
+
+	result = FALSE;
+	my_state = statd_get_nsm_state();
+
+	db = statd_open_db(SQLITE_OPEN_READONLY);
+	if (db == NULL)
+		return result;
+
+	err_msg = NULL;
+	if (sqlite3_get_table(db, "SELECT mon_name,my_name,protocol FROM "
+			STATD_NOTIFY_TABLENAME ";",
+			&resultp, &nrow, &ncolumn, &err_msg) != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to get '" STATD_NOTIFY_TABLENAME
+				"' table: %s", err_msg);
+		sqlite3_free(err_msg);
+		goto out_close;
+	}
+
+	if (ncolumn == 0) {
+		xlog(D_GENERAL, "No hosts to notify");
+		result = TRUE;
+		goto out_free_table;
+	}
+	if (ncolumn != 3) {
+		xlog(L_ERROR, "Incorrect column count (%d) in SELECT result",
+				ncolumn);
+		goto out_free_table;
+	}
+
+	xlog(D_CALL, "Notification NSM state: %d", my_state);
+
+	for (i = ncolumn; i < (nrow + 1) * ncolumn ; i += ncolumn)
+		statd_fork_and_notify(resultp[i],
+				bindaddr, srcport, resultp[i + 2],
+				resultp[i + 1], my_state, max_retry_minutes);
+	result = TRUE;
+
+out_free_table:
+	sqlite3_free_table(resultp);
+
+out_close:
+	statd_close_db(db);
+	return result;
+}
+
+/**
+ * statd_notify - send SM_NOTIFY requests
+ * @bindaddr: C string containing DNS name or presentation address
+ *	of socket's source address
+ * @srcport: source port to use when sending reboot notifications
+ * @max_retry_minutes: minutes after which to stop attempting to contact peer
+ *
+ * Copy the on-disk monitored host list to a backup directory,
+ * update the local NSM state number, and fork off notification
+ * processes.
+ *
+ * Returns TRUE if notificaitions were started successfully,
+ * or FALSE if an error occurred.
+ */
+bool_t
+statd_notify(const char *bindaddr, const unsigned short srcport,
+		const unsigned long max_retry_minutes)
+{
+	const struct sigaction statd_sigchld_action = {
+		.sa_handler	= SIG_DFL,
+		.sa_flags	= SA_NOCLDSTOP | SA_NOCLDWAIT,
+	};
+
+	(void)sigaction(SIGCHLD, &statd_sigchld_action, NULL);
+
+	switch (statd_retire_monitor_list()) {
+	case 0:
+		return TRUE;
+	case 1:
+		return statd_iterate_notify_list(bindaddr, srcport,
+							max_retry_minutes);
+	default:
+		return FALSE;
+	}
+}
diff --git a/utils/new-statd/svc.c b/utils/new-statd/svc.c
new file mode 100644
index 0000000..fa9a517
--- /dev/null
+++ b/utils/new-statd/svc.c
@@ -0,0 +1,841 @@
+/*
+ * Copyright 2009 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * nfs-utils is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+/*
+ * NSM for Linux.
+ *
+ * Convert incoming NSM RPC requests into local function calls.
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <memory.h>
+#include <signal.h>
+#include <unistd.h>
+#include <netdb.h>
+
+#include <netinet/in.h>
+
+#include <sys/socket.h>
+#include <sys/resource.h>
+
+#include <rpc/rpc.h>
+#include <rpc/svc.h>
+
+#ifdef HAVE_TCP_WRAPPER
+#include "tcpwrapper.h"
+#endif
+
+#include "statd.h"
+#include "ha-callout.h"
+#include "rpcmisc.h"
+
+/*
+ * Show the priv in hexadecimal.  For debugging only.
+ */
+#define STATD_SIZEOF_HEXBYTE	sizeof("ff")
+#define STATD_PRIVBUF_LEN	(SM_PRIV_SIZE * STATD_SIZEOF_HEXBYTE)
+static const char *
+statd_show_priv(const char *priv)
+{
+	static char buf[STATD_PRIVBUF_LEN];
+	unsigned int i;
+	char *p;
+
+	memset(buf, 0, sizeof(buf));
+	p = &buf[0];
+	for (i = 0; i < SM_PRIV_SIZE; i++)
+		p += sprintf(p, "%02x", 0xff & priv[i]);
+
+	return (const char *)buf;
+}
+
+/*
+ * Simplistic method to generate a presentation format version
+ * of the RPC caller's address.  Used only for debugging messages.
+ */
+static void
+statd_caller(struct svc_req *rqstp, char *buf, const size_t buflen)
+{
+	const struct sockaddr *sap = (struct sockaddr *)
+					svc_getcaller(rqstp->rq_xprt);
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)sap;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		if (inet_ntop(AF_INET, &sin->sin_addr.s_addr, buf, buflen) == NULL)
+			goto out_unknown;
+		break;
+	case AF_INET6:
+		if (inet_ntop(AF_INET6, &sin6->sin6_addr, buf, buflen) == NULL)
+			goto out_unknown;
+		break;
+	}
+
+	return;
+
+out_unknown:
+	(void)snprintf(buf, buflen, "unknown address");
+}
+
+static void
+statd_send_null_reply(SVCXPRT *xprt, const char *procname)
+{
+	if (!svc_sendreply(xprt, (xdrproc_t)xdr_void, NULL)) {
+		xlog(L_WARNING, "Failed to send %s reply", procname);
+		svcerr_systemerr(xprt);
+	}
+}
+
+/**
+ * statd_svc_null_1 - service a NULL request
+ *
+ * Currently the kernel NLM implementation does not send us
+ * this request, so this procedure is not implemented.
+ */
+static void
+statd_svc_null_1(struct svc_req *rqstp __attribute((unused)), SVCXPRT *xprt)
+{
+	if (opt_debug) {
+		char buf[INET6_ADDRSTRLEN];
+
+		statd_caller(rqstp, buf, sizeof(buf));
+		xlog(D_CALL, "Received NULLPROC request from %s", buf);
+	}
+
+	statd_send_null_reply(xprt, "NULLPROC");
+}
+
+/**
+ * statd_svc_stat_1 - service an SM_STAT request
+ *
+ * Returns stat_succ if the host can be monitored, otherwise stat_fail
+ * is returned.  Our current local NSM state is always returned.
+ */
+static void
+statd_svc_stat_1(struct svc_req *rqstp __attribute((unused)), SVCXPRT *xprt)
+{
+	struct addrinfo *gai_results;
+	struct sm_stat_res result;
+	struct sm_name arg;
+
+	if (opt_debug) {
+		char buf[INET6_ADDRSTRLEN];
+
+		statd_caller(rqstp, buf, sizeof(buf));
+		xlog(D_CALL, "Received SM_STAT request from %s for %s",
+				buf, arg.mon_name);
+	}
+
+	memset(&arg, 0, sizeof(arg));
+	if (!svc_getargs(xprt, (xdrproc_t)xdr_sm_name, (caddr_t)&arg)) {
+		xlog(L_WARNING, "Failed to decode SM_STAT arguments");
+		svcerr_decode(xprt);
+		return;
+	}
+
+	result.state = statd_get_nsm_state();
+	result.res_stat = stat_succ;
+	gai_results = statd_forward_lookup(arg.mon_name, IPPROTO_UDP);
+	if (gai_results == NULL) {
+		result.res_stat = stat_fail;
+		xlog(D_CALL, "SM_STAT fail for '%s'", arg.mon_name);
+	} else {
+		freeaddrinfo(gai_results);
+		xlog(D_CALL, "SM_STAT success for '%s', state=%d",
+				arg.mon_name, result.state);
+	}
+
+	if (!svc_sendreply(xprt, (xdrproc_t)xdr_sm_stat_res, &result)) {
+		xlog(L_WARNING, "Failed to send SM_STAT reply");
+		svcerr_systemerr(xprt);
+	}
+
+	if (!svc_freeargs(xprt, (xdrproc_t)xdr_mon, (caddr_t)&arg))
+		xlog(L_WARNING, "Failed to free SM_STAT arguments");
+}
+
+/*
+ * Insert a row for the corresponding host.  Returns 1 if the
+ * row was inserted, -1 if a row for this host already exists,
+ * or zero if an error occurs.
+ */
+static int
+statd_insert_row(sqlite3 *db, const struct mon *monp,
+		const char *protocol)
+{
+	sqlite3_stmt *stmt;
+	int result;
+	bool_t rc;
+	char *sql;
+
+	result = 0;
+
+	sql = sqlite3_mprintf("INSERT INTO " STATD_MONITOR_TABLENAME
+				" (priv,mon_name,my_name,"
+					"program,version,procedure,"
+					"protocol,state)"
+				" VALUES(?,'%q','%q',%d,%d,%d,'%q',0);",
+				monp->mon_id.mon_name,
+				monp->mon_id.my_id.my_name,
+				monp->mon_id.my_id.my_prog,
+				monp->mon_id.my_id.my_vers,
+				monp->mon_id.my_id.my_proc,
+				protocol);
+	if (sql == NULL) {
+		xlog(L_ERROR, "Failed to generate INSERT INTO statement");
+		return result;
+	}
+
+	rc = statd_prepare_stmt(db, &stmt, sql);
+	sqlite3_free(sql);
+	if (!rc)
+		return result;
+
+	if (sqlite3_bind_blob(stmt, 1, monp->priv, sizeof(monp->priv),
+					SQLITE_STATIC) != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to bind priv: %s",
+				sqlite3_errmsg(db));
+		goto out_finalize;
+	}
+
+	switch (sqlite3_step(stmt)) {
+	case SQLITE_DONE:
+		result = 1;
+		xlog(D_GENERAL, "Inserted callback record for %s/%s "
+				"(%u, %u, %u) priv: %s",
+				monp->mon_id.mon_name,
+				monp->mon_id.my_id.my_name,
+				monp->mon_id.my_id.my_prog,
+				monp->mon_id.my_id.my_vers,
+				monp->mon_id.my_id.my_proc,
+				statd_show_priv(monp->priv));
+		break;
+	case SQLITE_CONSTRAINT:
+		xlog(D_GENERAL, "Duplicate record for mon_name '%s' "
+				"found in the monitor list",
+					monp->mon_id.mon_name);
+		result = -1;
+		break;
+	default:
+		xlog(L_ERROR, "Failed to insert record for mon_name '%s' "
+				"into the monitor list",
+					monp->mon_id.mon_name);
+		break;
+	}
+
+out_finalize:
+	statd_finalize_stmt(stmt);
+	return result;
+}
+
+static int
+statd_insert_monitored_host(const struct mon *monp, const char *protocol)
+{
+	sqlite3 *db;
+	int result;
+
+	result = 0;
+
+	db = statd_open_db(SQLITE_OPEN_READWRITE);
+	if (db == NULL)
+		return result;
+
+	result = statd_insert_row(db, monp, protocol);
+	if (result)
+		ha_callout("add-client", monp->mon_id.mon_name,
+				monp->mon_id.my_id.my_name, -1);
+
+	statd_close_db(db);
+	return result;
+}
+
+/**
+ * statd_svc_mon_1 - service an SM_MON request
+ *
+ * Returns stat_succ if the host is monitored, otherwise stat_fail
+ * is returned.  Our current local NSM state is always returned.
+ */
+static void
+statd_svc_mon_1(struct svc_req *rqstp, SVCXPRT *xprt)
+{
+	struct addrinfo *gai_results;
+	struct sm_stat_res result;
+	struct mon arg;
+
+	memset(&arg, 0, sizeof(arg));
+	if (!svc_getargs(xprt, (xdrproc_t)xdr_mon, (caddr_t)&arg)) {
+		xlog(L_WARNING, "Failed to decode SM_MON arguments");
+		svcerr_decode(xprt);
+		return;
+	}
+
+	if (opt_debug) {
+		char buf[INET6_ADDRSTRLEN];
+
+		statd_caller(rqstp, buf, sizeof(buf));
+		xlog(D_CALL, "Received SM_MON request for %s from %s",
+				arg.mon_id.mon_name, buf);
+	}
+
+	/*
+	 * Reject requests from non-loopback addresses in order
+	 * to prevent attack described in CERT CA-99.05.
+	 */
+	if (!statd_localhost_caller(rqstp)) {
+		svcerr_auth(xprt, AUTH_FAILED);
+		return;
+	}
+
+	result.state = statd_get_nsm_state();
+	result.res_stat = stat_fail;
+
+	/*
+	 * Check that we can send the SM_NOTIFY later: ensure
+	 * that the mon_name can be resolved.
+	 *
+	 * XXX: Eventually we want to determine the transport
+	 *      protocol of the remote peer and use that instead.
+	 */
+	gai_results = statd_forward_lookup(arg.mon_id.mon_name, IPPROTO_UDP);
+	if (gai_results != NULL) {
+		if (statd_insert_monitored_host(&arg, "udp"))
+			result.res_stat = stat_succ;
+		freeaddrinfo(gai_results);
+	}
+
+	if (result.res_stat == stat_fail)
+		xlog(D_CALL, "Failed to monitor %s on behalf of %s",
+				arg.mon_id.mon_name, arg.mon_id.my_id.my_name);
+	else
+		xlog(D_CALL, "SM_MON success, state=%d", result.state);
+
+	if (!svc_sendreply(xprt, (xdrproc_t)xdr_sm_stat_res, &result)) {
+		xlog(L_WARNING, "Failed to send SM_MON reply");
+		svcerr_systemerr(xprt);
+	}
+
+	if (!svc_freeargs(xprt, (xdrproc_t)xdr_mon, (caddr_t)&arg))
+		xlog(L_WARNING, "Failed to free SM_MON arguments");
+}
+
+/*
+ * Delete the row for the corresponding host.  Returns TRUE if a row
+ * was deleted, otherwise FALSE if an error occurs or no row was found.
+ */
+static bool_t
+statd_delete_row(sqlite3 *db, const struct mon_id *mon_idp)
+{
+	char *err_msg;
+	bool_t result;
+	char *sql;
+
+	result = FALSE;
+
+	sql = sqlite3_mprintf("DELETE FROM " STATD_MONITOR_TABLENAME
+				" WHERE mon_name='%q' and my_name='%q' and"
+				" program=%d and version=%d and procedure=%d;",
+				mon_idp->mon_name, mon_idp->my_id.my_name,
+				mon_idp->my_id.my_prog,
+				mon_idp->my_id.my_vers,
+				mon_idp->my_id.my_proc);
+	if (sql == NULL) {
+		xlog(L_ERROR, "Failed to generate DELETE FROM statement");
+		return result;
+	}
+
+	err_msg = NULL;
+	if (sqlite3_exec(db, sql, NULL, 0, &err_msg) != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to delete mon_name '%s': %s",
+				mon_idp->mon_name, err_msg);
+		xlog(L_ERROR, "SQL: %s", sql);
+		sqlite3_free(err_msg);
+		goto out_free;
+	}
+
+	if (sqlite3_changes(db) == 0) {
+		xlog(D_GENERAL, "No record for mon_name '%s' was found",
+				mon_idp->mon_name);
+		goto out_free;
+	}
+
+	result = TRUE;
+	xlog(D_GENERAL, "Record for mon_name '%s' deleted",
+			mon_idp->mon_name);
+
+out_free:
+	sqlite3_free(sql);
+	return result;
+}
+
+static void
+statd_delete_monitored_host(const struct mon_id *mon_idp)
+{
+	sqlite3 *db;
+
+	db = statd_open_db(SQLITE_OPEN_READWRITE);
+	if (db == NULL)
+		return;
+
+	if (statd_delete_row(db, mon_idp))
+		ha_callout("del-client", mon_idp->mon_name,
+				mon_idp->my_id.my_name, -1);
+
+	statd_close_db(db);
+}
+
+/**
+ * statd_svc_unmon_1 - service an SM_UNMON request
+ *
+ * Our current local NSM state is always returned.
+ */
+static void
+statd_svc_unmon_1(struct svc_req *rqstp, SVCXPRT *xprt)
+{
+	struct mon_id arg;
+	struct sm_stat result;
+
+	memset(&arg, 0, sizeof(arg));
+	if (!svc_getargs(xprt, (xdrproc_t)xdr_mon_id, (caddr_t)&arg)) {
+		xlog(L_WARNING, "Failed to decode SM_UNMON arguments");
+		svcerr_decode(xprt);
+		return;
+	}
+
+	if (opt_debug) {
+		char buf[INET6_ADDRSTRLEN];
+
+		statd_caller(rqstp, buf, sizeof(buf));
+		xlog(D_CALL, "Received SM_UNMON request for %s from %s",
+				arg.mon_name, buf);
+	}
+
+	/*
+	 * Reject requests from non-loopback addresses in order
+	 * to prevent attack described in CERT CA-99.05.
+	 */
+	if (!statd_localhost_caller(rqstp)) {
+		svcerr_auth(xprt, AUTH_FAILED);
+		return;
+	}
+
+	result.state = statd_get_nsm_state();
+	xlog(D_CALL, "SM_UNMON reply, state=%d", result.state);
+
+	if (!svc_sendreply(xprt, (xdrproc_t)xdr_sm_stat, &result)) {
+		xlog(L_WARNING, "Failed to send SM_UNMON reply");
+		svcerr_systemerr(xprt);
+	}
+
+	statd_delete_monitored_host(&arg);
+
+	if (!svc_freeargs(xprt, (xdrproc_t)xdr_mon_id, (caddr_t)&arg))
+		xlog(L_WARNING, "Failed to free SM_UNMON arguments");
+}
+
+static void
+statd_delete_monitored_hosts(const struct my_id *my_idp)
+{
+	int i, rc, nrow, ncolumn;
+	char **resultp;
+	char *err_msg;
+	sqlite3 *db;
+	char *sql;
+
+	db = statd_open_db(SQLITE_OPEN_READWRITE);
+	if (db == NULL)
+		return;
+
+	sql = sqlite3_mprintf("SELECT mon_name,my_name,program,version,procedure"
+				" FROM " STATD_MONITOR_TABLENAME
+				" WHERE my_name='%q' and"
+				" program=%d and version=%d and procedure=%d;",
+				my_idp->my_name, my_idp->my_prog,
+				my_idp->my_vers, my_idp->my_proc);
+	if (sql == NULL) {
+		xlog(L_ERROR, "Failed to generate SQL command in %s", __func__);
+		goto out_close;
+	}
+
+	err_msg = NULL;
+	rc = sqlite3_get_table(db, sql, &resultp, &nrow, &ncolumn, &err_msg);
+	sqlite3_free(sql);
+	if (rc != SQLITE_OK) {
+		xlog(L_ERROR, "Failed to get " STATD_MONITOR_TABLENAME
+				" table: %s", err_msg);
+		sqlite3_free(err_msg);
+		goto out_close;
+	}
+
+	if (ncolumn == 0) {
+		xlog(D_GENERAL, "No host records found");
+		goto out_free_table;
+	}
+	if (ncolumn != 5) {
+		xlog(L_ERROR, "Incorrect column count %d in SELECT result",
+				ncolumn);
+		goto out_free_table;
+	}
+
+	for (i = ncolumn; i < (nrow + 1) * ncolumn ; i += ncolumn) {
+		struct mon_id mon_id;
+
+		mon_id.mon_name = resultp[i];
+		mon_id.my_id.my_name = resultp[i + 1];
+		mon_id.my_id.my_prog = atoi(resultp[i + 2]);
+		mon_id.my_id.my_vers = atoi(resultp[i + 3]);
+		mon_id.my_id.my_proc = atoi(resultp[i + 4]);
+
+		if (statd_delete_row(db, &mon_id))
+			ha_callout("del-client", mon_id.mon_name,
+					mon_id.my_id.my_name, -1);
+	}
+
+out_free_table:
+	sqlite3_free_table(resultp);
+
+out_close:
+	statd_close_db(db);
+}
+
+/**
+ * statd_svc_unmon_all_1 - service an SM_UNMON_ALL request
+ *
+ * Our current local NSM state is always returned.
+ */
+static void
+statd_svc_unmon_all_1(struct svc_req *rqstp, SVCXPRT *xprt)
+{
+	struct my_id arg;
+	struct sm_stat result;
+
+	/*
+	 * Reject requests from non-loopback addresses in order
+	 * to prevent attack described in CERT CA-99.05.
+	 */
+	if (!statd_localhost_caller(rqstp)) {
+		svcerr_auth(xprt, AUTH_FAILED);
+		return;
+	}
+
+	memset(&arg, 0, sizeof(arg));
+	if (!svc_getargs(xprt, (xdrproc_t)xdr_my_id, (caddr_t)&arg)) {
+		xlog(L_WARNING, "Failed to decode SM_UNMON_ALL arguments");
+		svcerr_decode(xprt);
+		return;
+	}
+
+	if (opt_debug) {
+		char buf[INET6_ADDRSTRLEN];
+
+		statd_caller(rqstp, buf, sizeof(buf));
+		xlog(D_CALL, "Received SM_UNMON_ALL request for %s from %s",
+				arg.my_name, buf);
+	}
+
+	result.state = statd_get_nsm_state();
+	xlog(D_CALL, "SM_UNMON_ALL reply, state=%d", result.state);
+
+	if (!svc_sendreply(xprt, (xdrproc_t)xdr_sm_stat, &result)) {
+		xlog(L_WARNING, "Failed to send SM_UNMON_ALL reply");
+		svcerr_systemerr(xprt);
+	}
+
+	statd_delete_monitored_hosts(&arg);
+
+	if (!svc_freeargs(xprt, (xdrproc_t)xdr_my_id, (caddr_t)&arg))
+		xlog(L_WARNING, "Failed to free SM_UNMON_ALL arguments");
+}
+
+/**
+ * statd_svc_simu_crash_1 - service an SM_SIMU_CRASH request
+ *
+ */
+static void
+statd_svc_simu_crash_1(struct svc_req *rqstp, SVCXPRT *xprt)
+{
+	if (opt_debug) {
+		char buf[INET6_ADDRSTRLEN];
+
+		statd_caller(rqstp, buf, sizeof(buf));
+		xlog(D_CALL, "Received SM_SIMU_CRASH request from %s", buf);
+	}
+
+	/*
+	 * Reject requests from non-loopback addresses in order
+	 * to prevent attack described in CERT CA-99.05.
+	 */
+	if (!statd_localhost_caller(rqstp)) {
+		svcerr_auth(xprt, AUTH_FAILED);
+		return;
+	}
+
+	statd_send_null_reply(xprt, "SM_SIMU_CRASH");
+
+	/*
+	 * This call may block temporarily while the monitor list
+	 * is retired.  Notifications will then proceed in a
+	 * separate process.
+	 */
+	(void)statd_notify(opt_name, opt_notify_port, SMN_MAX_RETRY);
+}
+
+/**
+ * statd_svc_notify_1 - service an SM_NOTIFY request
+ *
+ */
+static void
+statd_svc_notify_1(struct svc_req *rqstp, SVCXPRT *xprt)
+{
+	const struct sockaddr *sap = (struct sockaddr *)
+					svc_getcaller(rqstp->rq_xprt);
+	struct stat_chge arg;
+
+	memset(&arg, 0, sizeof(arg));
+	if (!svc_getargs(xprt, (xdrproc_t)xdr_stat_chge, (caddr_t)&arg)) {
+		xlog(L_WARNING, "Failed to decode SM_NOTIFY arguments");
+		svcerr_decode(xprt);
+		return;
+	}
+
+	if (opt_debug) {
+		char buf[INET6_ADDRSTRLEN];
+
+		statd_caller(rqstp, buf, sizeof(buf));
+		xlog(D_CALL, "Received SM_NOTIFY request for %s "
+						"(new state %d) from %s",
+				arg.mon_name, arg.state, buf);
+	}
+
+	statd_send_null_reply(xprt, "SM_NOTIFY");
+
+	statd_queue_nlm_callback(arg.mon_name, arg.state, sap);
+
+	if (!svc_freeargs(xprt, (xdrproc_t)xdr_stat_chge, (caddr_t)&arg))
+		xlog(L_WARNING, "Failed to free SM_NOTIFY arguments");
+}
+
+/**
+ * statd_dispatch_1 - server-side entry point for RPC procedure calls
+ * @rqstp: information about the incoming request
+ * @xprt: the transport used to receive this request
+ *
+ * The NSM call is executed if allowed by TCP wrappers.
+ */
+static void
+statd_dispatch_1(struct svc_req *rqstp, SVCXPRT *xprt)
+{
+#ifdef HAVE_TCP_WRAPPER
+	struct sockaddr_in *sin = nfs_getrpccaller_in(xprt);
+
+	/*
+	 * XXX: Update this when tcp_wrappers supports AF_INET6
+	 */
+	if (sin->sin_family == AF_INET &&
+	    !check_default("statd", sin, rqstp->rq_proc, statd_nsm_program)) {
+		svcerr_auth(xprt, AUTH_FAILED);
+		return;
+	}
+#endif	/* HAVE_TCP_WRAPPER */
+
+	switch (rqstp->rq_proc) {
+	case NULLPROC:
+		statd_svc_null_1(rqstp, xprt);
+		break;
+	case SM_STAT:
+		statd_svc_stat_1(rqstp, xprt);
+		break;
+	case SM_MON:
+		statd_svc_mon_1(rqstp, xprt);
+		break;
+	case SM_UNMON:
+		statd_svc_unmon_1(rqstp, xprt);
+		break;
+	case SM_UNMON_ALL:
+		statd_svc_unmon_all_1(rqstp, xprt);
+		break;
+	case SM_SIMU_CRASH:
+		statd_svc_simu_crash_1(rqstp, xprt);
+		break;
+	case SM_NOTIFY:
+		statd_svc_notify_1(rqstp, xprt);
+		break;
+	default:
+		xlog(L_WARNING, "Unrecognized RPC procedure number %d",
+				rqstp->rq_proc);
+		svcerr_noproc(xprt);
+	}
+}
+
+void
+statd_unregister(void)
+{
+	svc_unreg(statd_nsm_program, SM_VERS);
+}
+
+/*
+ * Set up an appropriate bind address, given @port and @nconf.
+ *
+ * Returns getaddrinfo(3) results if successful.  Caller must
+ * invoke freeaddrinfo(3) on these results.
+ *
+ * Otherwise NULL is returned if an error occurs.
+ */
+static struct addrinfo *
+statd_svc_create_bindaddr(struct netconfig *nconf, const uint16_t port)
+{
+	struct addrinfo gai_hint = {
+		.ai_flags	= AI_PASSIVE | AI_NUMERICSERV,
+	};
+	struct addrinfo *gai_results;
+	char buf[8];
+	int error;
+
+	if (strcmp(nconf->nc_protofmly, NC_INET) == 0)
+		gai_hint.ai_family = AF_INET;
+#ifdef IPV6_SUPPORTED
+	else if (strcmp(nconf->nc_protofmly, NC_INET6) == 0)
+		gai_hint.ai_family = AF_INET6;
+#endif	/* IPV6_SUPPORTED */
+	else {
+		xlog(L_ERROR, "Unrecognized bind address family: %s",
+			nconf->nc_protofmly);
+		return NULL;
+	}
+
+	if (strcmp(nconf->nc_proto, NC_UDP) == 0)
+		gai_hint.ai_protocol = IPPROTO_UDP;
+	else if (strcmp(nconf->nc_proto, NC_TCP) == 0)
+		gai_hint.ai_protocol = IPPROTO_TCP;
+	else {
+		xlog(L_ERROR, "Unrecognized bind address protocol: %s",
+			nconf->nc_proto);
+		return NULL;
+	}
+
+	(void)snprintf(buf, sizeof(buf), "%u", port);
+	error = getaddrinfo(NULL, buf, &gai_hint, &gai_results);
+	switch (error) {
+	case 0:
+		return gai_results;
+	case EAI_SYSTEM:
+		xlog(L_ERROR, "Failed to construct bind address: %m");
+		break;
+	default:
+		xlog(L_ERROR, "Failed to construct bind address: %s",
+			gai_strerror(error));
+		break;
+	}
+
+	return NULL;
+}
+
+static int
+statd_svc_create_nconf(const rpcprog_t program, const rpcvers_t version,
+		const uint16_t port, struct netconfig *nconf)
+{
+	struct addrinfo *gai_results;
+	struct t_bind bindaddr;
+	SVCXPRT	*xprt;
+
+	gai_results = statd_svc_create_bindaddr(nconf, port);
+	if (gai_results == NULL)
+		return 0;
+
+	bindaddr.addr.buf = gai_results->ai_addr;
+	bindaddr.qlen = SOMAXCONN;
+
+	xprt = svc_tli_create(RPC_ANYFD, nconf, &bindaddr, 0, 0);
+	freeaddrinfo(gai_results);
+	if (xprt == NULL) {
+		xlog(L_ERROR, "Failed to create NSM xprt");
+		return 0;
+	}
+
+	if (!svc_reg(xprt, program, version, statd_dispatch_1, nconf)) {
+		/* svc_reg(3) destroys @xprt in this case */
+		xlog(L_ERROR, "Failed to register (statd, %u, %s).",
+				version, nconf->nc_proto);
+		return 0;
+	}
+
+	return 1;
+}
+
+/**
+ * statd_svc_create - start up NSM listeners
+ * @program: RPC program number to register
+ * @version: RPC version number to register
+ * @port: if not zero, transport listens on this port
+ *
+ * Sets up network transports for receiving NSM RPC requests, and starts
+ * the RPC dispatcher.  Normally does not return.
+ */
+void
+statd_svc_create(const rpcprog_t program, const rpcvers_t version,
+		const uint16_t port)
+{
+	const struct sigaction statd_create_sigaction = {
+		.sa_handler	= SIG_IGN,
+	};
+	unsigned int visible, up;
+	struct netconfig *nconf;
+	void *handlep;
+
+	/*
+	 * Ignore SIGPIPE to avoid exiting sideways when peers
+	 * close their TCP connection while we're trying to reply
+	 * to them.
+	 */
+	(void)sigaction(SIGPIPE, &statd_create_sigaction, NULL);
+
+	handlep = setnetconfig();
+	if (handlep == NULL) {
+		xlog(L_ERROR, "Failed to access local netconfig database: %s",
+			nc_sperror());
+		return;
+	}
+
+	visible = 0;
+	up = 0;
+	while ((nconf = getnetconfig(handlep)) != NULL) {
+		if (!(nconf->nc_flag & NC_VISIBLE))
+			continue;
+		visible++;
+		up += statd_svc_create_nconf(program, version, port, nconf);
+	}
+
+	if (visible == 0)
+		xlog(L_ERROR, "Failed to find any visible netconfig entries");
+
+	if (endnetconfig(handlep) == -1)
+		xlog(L_ERROR, "Failed to close local netconfig database: %s",
+			nc_sperror());
+
+	if (up > 0) {
+		atexit(statd_unregister);
+		svc_run();
+	}
+}

