From: mike@waychison.com
Subject: [PATCH/RFC 1/2] rpcproxyd
Date: Mon, 7 Mar 2005 15:53:39 -0500 (EST)
Message-ID: <37093.66.11.176.22.1110228819.squirrel@webmail1.hrnoc.net>
References: <37086.66.11.176.22.1110228763.squirrel@webmail1.hrnoc.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;boundary="----=_20050307155339_78816"
Cc: mike@waychison.com
In-Reply-To: <37086.66.11.176.22.1110228763.squirrel@webmail1.hrnoc.net>
To: "linux-nfs" <nfs@lists.sourceforge.net>,
        "autofs mailing list" <autofs@linux.kernel.org>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Sender: autofs-bounces@linux.kernel.org
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

------=_20050307155339_78816
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 8bit


------=_20050307155339_78816
Content-Type: text/x-patch; name="rpcproxyd.patch"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="rpcproxyd.patch"

This patch implements 'rpcproxyd' and associated 'clntproxy_create()' interface.

Index: util-linux-2.12p/lib/Makefile
===================================================================
--- util-linux-2.12p.orig/lib/Makefile	2005-03-07 15:21:28.804710768 -0500
+++ util-linux-2.12p/lib/Makefile	2005-03-07 15:22:00.506891304 -0500
@@ -1,7 +1,9 @@
 include ../make_include
 include ../MCONFIG
 
-all: err.o my_reboot.o setproctitle.o env.o carefulputc.o xstrncpy.o md5.o
+all: err.o my_reboot.o setproctitle.o env.o carefulputc.o xstrncpy.o md5.o clnt_proxy.o
+
+clnt_proxy.o: clnt_proxy.c clnt_proxy.h
 
 err.o: err.c
 
Index: util-linux-2.12p/lib/clnt_proxy.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ util-linux-2.12p/lib/clnt_proxy.h	2005-03-07 15:22:00.506891304 -0500
@@ -0,0 +1,14 @@
+#ifndef PROXYCLIENT_H
+#define PROXYCLIENT_H
+
+#include <rpc/rpc.h>
+
+#define SOCKET_PATH ( RPCPROXYDIR "/socket" )
+
+#ifndef UNIX_PATH_MAX
+#define UNIX_PATH_MAX 108
+#endif
+
+CLIENT *clntproxy_create(unsigned long domain, unsigned long type, struct sockaddr *addr, unsigned long addrlen, unsigned long prog, unsigned long vers);
+
+#endif
Index: util-linux-2.12p/sys-utils/rpcproxyd.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ util-linux-2.12p/sys-utils/rpcproxyd.c	2005-03-07 15:22:18.297186768 -0500
@@ -0,0 +1,1599 @@
+/*
+ * rpcproxyd -- Daemon that proxies tcp / udp rpc requests.
+ *
+ * This daemon is the proxy behind the clnt_proxy interface.  It takes care of
+ * connection sharing / caching.  This allows callers to share transports when
+ * calling rpc services that require the caller to be coming from a reserved
+ * port. This is a good thing because it limits the amount of reserved ports
+ * required when talking to a lot of services simultaneously.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the
+ * Free Software Foundation; either version 2, or (at your option) any
+ * later version.
+
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 675 Mass Ave, Cambridge, MA 02139, USA.
+ *
+ * Copyright 2005 - Mike Waychison <mike@waychison.com>
+ */
+#include <sys/socket.h>
+#include <sys/select.h>
+#include <sys/un.h>
+#include <sys/time.h>
+#include <netinet/in.h>
+#include <time.h>
+#include <signal.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <string.h>
+#include <stdarg.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <errno.h>
+#include <clnt_proxy.h>
+#include "list.h"
+
+#define CONN_TIMEOUT   30	/* in seconds */
+#define RETRANS_TIMEOUT 2	/* in seconds */
+#define RETRANS_TIMES   3
+#define BUFFER_SIZE (64 * 1024)
+
+/*
+ * TODO:
+ *   - Audit for ipv6 functionality (should be good).
+ *   - Verify incoming udp packets.
+ *   - Randomize the xids?
+ */
+
+struct packet;
+struct xid_map {
+	struct list_head list;
+	uint32_t from_client;
+	uint32_t to_server;
+	struct packet *retrans;
+};
+
+enum server_state {
+	SS_INPROGRESS,
+	SS_OK,
+	SS_CLOSED,
+};
+struct server {
+	struct list_head list;
+	enum server_state state;
+	unsigned long domain;
+	unsigned long type;
+	void *addr;
+	unsigned long addr_len;
+	int socketfd;
+	int refcount;		/* okay if not atomic, we aren't threaded */
+	struct timeval timeout; /* timeout time if refcount == 0 */
+	struct list_head queue_head;
+	char buffer[BUFFER_SIZE];
+	int bufferpos;
+};
+static LIST_HEAD(servers);
+
+enum client_state {
+	CS_WAITING_CREDS,
+	CS_WAITING_FOR_CONNECT,
+	CS_PROCESSING,
+};
+struct client {
+	struct list_head list;
+	int fd;
+	enum client_state state;
+	unsigned long domain;
+	unsigned long type;
+	void *addr;	/* struct sockaddr * */
+	unsigned long addr_len;
+	struct server *conn;
+	struct list_head queue_head;
+	struct list_head xids;
+	int sent_ack;
+	int bufferpos;
+	char buffer[BUFFER_SIZE];
+};
+static LIST_HEAD(clients);
+
+struct packet {
+	unsigned long len;
+	struct list_head queue;
+	unsigned long pos;
+#define SOCKADDR_MAX_SIZE 128	/* Is this big enough? */
+	char addr[SOCKADDR_MAX_SIZE];
+	int addrlen;
+	struct timeval retrans_time;
+	int retrans_times;
+	int refcount;
+	char buf[0];
+};
+
+static int sockfd = -1;
+static const char *called_name;
+
+/* options */
+static int enable_debug = 0;
+
+static void debug(char *fmt, ...)
+{
+	va_list args;
+	va_start(args, fmt);
+	if (enable_debug)
+		vfprintf(stdout, fmt, args);
+	va_end(args);
+}
+
+static void die(char *fmt, ...)
+{
+	va_list args;
+	va_start(args, fmt);
+	vfprintf(stderr, fmt, args);
+	va_end(args);
+	if (sockfd != -1) {
+		unlink(SOCKET_PATH);
+	}
+	exit(-1);
+}
+
+static void usage(void)
+{
+	printf("Usage: %s [-d | -h]\n"
+	       "       -d      Turn on debug output\n"
+	       "       -h      Print this message\n",
+	       called_name);
+}
+
+static void parse_args(int argc, const char **argv)
+{
+	if (argc > 2) {
+		printf("Unrecognized arguments\n");
+		usage();
+		exit(-1);
+	} else if (argc == 2) {
+		if (!strcmp(argv[1], "-d"))
+			enable_debug = 1;
+		else if (!strcmp(argv[1], "-h")) {
+			usage();
+			exit(0);
+		} else {
+			printf("Unrecognized arguments\n");
+			usage();
+			exit(-1);
+		}
+	}
+}
+
+static void sanity_check(void)
+{
+	if (getuid() != 0)
+		die("Must be run as root\n");
+}
+
+static void sig_term(int foo)
+{
+	if (sockfd != -1)
+		unlink(SOCKET_PATH);
+	exit(-1);
+}
+
+static void setup_signals(void)
+{
+	signal(SIGTERM, sig_term);
+	signal(SIGINT, sig_term);
+	signal(SIGHUP, sig_term);
+}
+
+static void close_fds(void)
+{
+	int i;
+	int max;
+
+	max = sysconf(_SC_OPEN_MAX);
+
+	for (i = enable_debug ? 3 : 0; i < max; i++)
+		close(i);
+
+	if (!enable_debug) {
+		freopen("/dev/null", "r", stdin);
+		freopen("/dev/null", "w", stdout);
+		freopen("/dev/null", "w", stdout);
+	}
+}
+
+static void double_fork(void)
+{
+	if (enable_debug)
+		return;
+	if (!fork() && !fork()) {
+		/* continue */
+		return;
+	}
+	exit(0);
+}
+
+static void setup_listener(void)
+{
+	struct sockaddr_un addr;
+	int fd;
+	int ret;
+	int val;
+
+	fd = socket(AF_UNIX, SOCK_STREAM, 0);
+	if (fd == -1)
+		die("Couldn't create socket: %s", strerror(errno));
+
+	memset(&addr, 0, sizeof(addr));
+	addr.sun_family = AF_UNIX;
+	
+	if (strlen(SOCKET_PATH) + 1 > UNIX_PATH_MAX)
+		die("socket path too long!");
+	strcpy(addr.sun_path, SOCKET_PATH);
+
+	ret = bind(fd, (struct sockaddr *)&addr, sizeof(addr));
+	if (ret == -1) {
+		/* check to see if the socket is alive */
+		ret = connect(fd, (struct sockaddr *)&addr, sizeof(addr));
+		if (ret == -1 && errno == ECONNREFUSED) {
+			/* we got an error, unlink and retry */
+			debug("connect returned: %s\n", strerror(errno));
+			unlink(SOCKET_PATH);
+			ret = bind(fd, (struct sockaddr *)&addr, sizeof(addr));
+			if (ret == -1)
+				die("Couldn't bind to %s", SOCKET_PATH);
+		} else if (ret) {
+			die("Failed checking to see if socket was active: %s\n",
+					strerror(errno));
+		} else {
+			/* we successfully connected, someone else is running */
+			debug("looks like another rpcproxyd is running\n");
+			close(fd);
+			die("Couldn't bind to %s\n", SOCKET_PATH);
+		}
+	}
+
+	if (listen(fd, 20))
+		die("Couldn't set listen mode on socket: %s\n", strerror(errno));
+
+	if (fcntl(fd, F_SETFL, O_NONBLOCK) != 0)
+		die("Couldn't set O_NONBLOCK on listening socket: %s\n", strerror(errno));
+
+	val = 1;
+	if (setsockopt(fd, SOL_SOCKET, SO_PASSCRED, &val, sizeof(val)))
+		die("Couldn't set SO_PASSCRED on listening socket: %s\n", strerror(errno));
+
+	sockfd = fd;
+}
+
+/* Returns true if server is UDP */
+static int is_conn_udp(struct server *conn)
+{
+	return (conn->type == SOCK_DGRAM
+	     && (conn->domain == AF_INET || conn->domain == AF_INET6));
+}
+
+/* Returns true if client is UDP */
+static int is_client_udp(struct client *client)
+{
+	return (client->type == SOCK_DGRAM
+	     && (client->domain == AF_INET || client->domain == AF_INET6));
+}
+
+/* send an 'accept' to the client */
+static void ack_client(struct client *client)
+{
+	uint32_t val[2] = {0, 0};
+	debug("Acking client\n");
+	if (!client->sent_ack++)
+		send(client->fd, val, sizeof(val), MSG_NOSIGNAL);
+}
+
+/* send a 'fail' to the client */
+static void nack_client(struct client *client, uint32_t rpc_err, uint32_t set_errno)
+{
+	uint32_t val[2];
+	val[0] = htonl(rpc_err);
+	val[1] = htonl(set_errno);
+	debug("Nacking client\n");
+	if (!client->sent_ack++)
+		send(client->fd, val, sizeof(val), MSG_NOSIGNAL);
+}
+
+/* Counter for unique xids */
+static uint32_t xid_counter = 0;
+
+static struct packet *get_packet(struct packet *);
+static void release_packet(struct packet *);
+
+/* Returns a new xid to use.  0 means we hit ENOMEM. */
+/* NOTE: we don't handle re-used xids still in flight */
+/* Set retrans to the packet itself *iff* you want it to retransmit */
+static uint32_t new_xid(struct client *client, struct packet *retrans, uint32_t orig)
+{
+	struct xid_map *map;
+
+	map = malloc(sizeof(*map));
+	if (!map)
+		return 0;
+	INIT_LIST_HEAD(&map->list);
+	map->from_client = orig;
+	map->to_server   = xid_counter++;
+	map->retrans     = get_packet(retrans);
+	if (retrans) {
+		gettimeofday(&retrans->retrans_time, NULL);
+		retrans->retrans_time.tv_sec += RETRANS_TIMEOUT;
+		retrans->retrans_times = RETRANS_TIMES;
+	}
+	if (!map->to_server)
+		map->to_server = xid_counter++;
+	list_add_tail(&map->list, &client->xids);
+	return map->to_server;
+}
+
+/*
+ * Finds a xid mapping.
+ * Returns the client and the original xid.
+ * Also clears out the xid map.
+ * NULL means the xid from the server was bogus.
+ */
+static struct client *find_xid(uint32_t from_server, uint32_t *orig)
+{
+	struct client *client;
+	struct xid_map *map, *_map;
+	list_for_each_entry(client, &clients, list) {
+		list_for_each_entry_safe(map, _map, &client->xids, list) {
+			if (map->to_server != from_server)
+				continue;
+			/* found it */
+			list_del_init(&map->list);
+			*orig = map->from_client;
+			if (map->retrans)
+				release_packet(map->retrans);
+			free(map);
+			return client;
+		}
+	}
+	return NULL;
+}
+
+static void add_client(int fd)
+{
+	struct client *client;
+
+	debug("Adding local client\n");
+
+	client = malloc(sizeof(*client));
+	if (!client)
+		die("malloc");
+	INIT_LIST_HEAD(&client->list);
+	INIT_LIST_HEAD(&client->queue_head);
+	INIT_LIST_HEAD(&client->xids);
+	list_add_tail(&client->list, &clients);
+	client->fd = fd;
+	client->state = CS_WAITING_CREDS;
+	client->addr = NULL;
+	client->conn = NULL;
+	client->bufferpos = 0;
+	client->sent_ack = 0;
+}
+
+static void release_server(struct server *conn);
+static void free_client(struct client *todelete)
+{
+	struct xid_map *xid, *_xid;
+	/* we send a fail if the client is still waiting for a connect */
+	if (todelete->fd > -1 && todelete->state == CS_WAITING_FOR_CONNECT)
+		nack_client(todelete, 0, 0);
+
+	/* walk through and kill off all remaining xids */
+	list_for_each_entry_safe(xid, _xid, &todelete->xids, list) {
+		struct packet *packet;
+
+		/*
+		 * The xid had a restransmission packet, make sure we destroy
+		 * it. If it was queued, then he have to release it from the
+		 * queue as well.
+		 */
+		packet = xid->retrans;
+		if (packet) {
+			if (!list_empty(&packet->queue)) {
+				list_del_init(&packet->queue);
+				release_packet(packet);
+			}
+			release_packet(packet);
+		}
+	}
+
+	list_del(&todelete->list);
+	close(todelete->fd);
+	if (todelete->conn)
+		release_server(todelete->conn);
+	if (todelete->addr)
+		free(todelete->addr);
+	free(todelete);
+}
+
+static struct server *make_server(struct client *client, int socketfd, enum server_state state)
+{
+	struct server *conn;
+
+	debug("Making a new server\n");
+
+	conn = malloc(sizeof(*conn));
+	if (!conn)
+		return NULL;
+	conn->addr = malloc(client->addr_len);
+	if (!conn->addr) {
+		free(conn);
+		return NULL;
+	}
+
+	INIT_LIST_HEAD(&conn->list);
+	INIT_LIST_HEAD(&conn->queue_head);
+	list_add_tail(&conn->list, &servers);
+	memcpy(conn->addr, client->addr, client->addr_len);
+	conn->state    = state;
+	conn->domain   = client->domain;
+	conn->type     = client->type;
+	conn->addr_len = client->addr_len;
+	conn->socketfd = socketfd;
+	memset(conn->buffer, 0, BUFFER_SIZE);
+	conn->bufferpos = 0;
+	conn->refcount = 1;
+
+	return conn;
+}
+
+static void release_packet(struct packet *packet);
+static void close_server(struct server *conn, uint32_t rpc_err, uint32_t set_errno)
+{
+	struct client *client, *_client;
+	struct packet *packet, *_packet;
+
+	debug("Closing connection to server\n");
+
+	/* close all clients */
+	conn->state = SS_CLOSED;
+	list_del_init(&conn->list);
+	list_for_each_entry_safe(client, _client, &clients, list) {
+		if (client->conn != conn)
+			continue;
+		nack_client(client, rpc_err, set_errno);
+		free_client(client);
+	}
+
+	/* destroy all associated packets */
+	list_for_each_entry_safe(packet, _packet, &conn->queue_head, queue) {
+		release_packet(packet);
+	}
+
+	close(conn->socketfd);
+	conn->socketfd = -1;
+}
+
+static void free_server(struct server *conn)
+{
+	conn->socketfd = -1;
+	free(conn);
+}
+
+/* drop a reference on the server */
+static void release_server(struct server *conn)
+{
+	conn->refcount--;
+	if (!conn->refcount) {
+		/* set the timeout */
+		gettimeofday(&conn->timeout, NULL);
+		conn->timeout.tv_sec += CONN_TIMEOUT;
+	}
+}
+
+static void release_server_no_timeout(struct server *conn)
+{
+	conn->refcount--;
+}
+
+/*
+ * Returns:
+ *  1 - Found.
+ *  0 - Not found.
+ */
+static int have_existing_server(struct client *client)
+{
+	struct server *conn;
+	int found = 0;
+
+	list_for_each_entry(conn, &servers, list) {
+
+		if (conn->state != SS_OK
+		 && conn->state != SS_INPROGRESS)
+			continue;
+
+		/* TODO: Why doesn't this work? */
+//		/*
+//		 * UDP is special, as we can reuse a single socket for
+//		 * all communication.
+//		 */
+//		if (is_client_udp(client)
+//		 && is_conn_udp(conn)
+//		 && client->domain == conn->domain) {
+//			/* reuse existing udp port */
+//			found = 1;
+//			debug("Found an existing UDP port\n");
+//			break;
+//		}
+
+		if (conn->domain   == client->domain
+		 && conn->type     == client->type
+		 && conn->addr_len == client->addr_len
+		 && !memcmp(conn->addr, client->addr, conn->addr_len)) {
+			/* found a match */
+			found = 1;
+			debug("Found an existing connect\n");
+			break;
+		}
+	}
+	if (!found)
+		return 0;
+	conn->refcount++;
+	client->conn = conn;
+	if (conn->state == SS_OK)
+		client->state = CS_PROCESSING;
+	else if (conn->state == SS_INPROGRESS)
+		client->state = CS_WAITING_FOR_CONNECT;
+	else 
+		fprintf(stderr, "Bug, unknown server state\n");
+
+	/* have to set the accepted response */
+	ack_client(client);
+	return 1;
+}
+
+static struct server *get_server_to_remote_connect(int fd, struct client *client)
+{
+	struct server *conn;
+
+	/* We don't connect to anything with udp */
+	if (is_client_udp(client)) {
+		/* no connect */
+		conn = make_server(client, fd, SS_OK);
+		if (!conn) {
+			nack_client(client, RPC_SYSTEMERROR, ECONNREFUSED);
+			return NULL;
+		}
+		client->state = CS_PROCESSING;
+		ack_client(client);
+		return conn;
+	}
+
+	if (connect(fd, client->addr, client->addr_len)) {
+		if (errno == EINPROGRESS) {
+			debug("Outbound server is in progress\n");
+			/* we'll finish the connect later */
+			conn = make_server(client, fd, SS_INPROGRESS);
+			if (!conn) {
+				nack_client(client, RPC_SYSTEMERROR, ENOMEM);
+				return NULL;
+			}
+			client->state = CS_WAITING_FOR_CONNECT;
+		} else { /*
+			  * TODO: do we need to handle ECONNREFUSED
+			  * differently here?
+			  */
+			debug("Failed to connect to outbound\n");
+			nack_client(client, RPC_SYSTEMERROR, errno);
+			return NULL;
+		}
+	} else {
+		debug("Outbound conenction was instantaneous\n");
+		/* we already finished the connect */
+		conn = make_server(client, fd, SS_OK);
+		if (!conn) {
+			nack_client(client, RPC_SYSTEMERROR, errno);
+			return NULL;
+		}
+		client->state = CS_PROCESSING;
+		ack_client(client);
+	}
+	return conn;
+}
+
+static int get_server_to_remote(struct client *client)
+{
+	struct server *conn;
+	int newfd;
+
+	debug("Trying to connect to remote host\n");
+
+	if (have_existing_server(client))
+		return 0;
+
+	/* create a new socket with appropriate type.. and then pitch it
+	 * off to the queue if EINPROGRESS */
+	newfd = socket(client->domain, client->type, 0);
+	if (newfd == -1) {
+		debug("couldn't allocate a new socket\n");
+		return -1;
+	}
+
+	if (bindresvport(newfd, NULL)) {
+		debug("couldn't bind to reserved port\n");
+		close(newfd);
+		return -1;
+	}
+
+	/*
+	 * Be sure to mark the socket O_NONBLOCK so that we can use
+	 * EINPROGRESS (asynchronous connect)
+	 */
+	if (fcntl(newfd, F_SETFL, O_NONBLOCK)) {
+		debug("Couldn't set O_NONBLOCK on outbound socket\n");
+		close(newfd);
+		return -1;
+	}
+
+	conn = get_server_to_remote_connect(newfd, client);
+
+	if (!conn) {
+		close(newfd);
+		return -1;
+	}
+	client->conn = conn;
+	return 0;
+}
+
+static struct packet *create_packet(char *buf, unsigned long len, int is_stream, void *addr, int addrlen)
+{
+	struct packet *packet;
+
+	packet = malloc(sizeof(*packet) + len + (is_stream ? 4 : 0));
+	if (!packet)
+		return NULL;
+	debug("Created a packet of %d bytes\n", len);
+	packet->len = len + (is_stream ? 4 : 0);
+	INIT_LIST_HEAD(&packet->queue);
+	packet->pos = 0;
+	packet->refcount = 1;
+	if (is_stream) {
+		/* have to set the last fragment bit */
+		uint32_t flipped = htonl(len | 0x80000000);
+		memcpy(packet->buf, &flipped, 4);
+	}
+	memcpy(&packet->buf[(is_stream ? 4 : 0)], buf, len);
+	if (addr) {
+		if (addrlen > SOCKADDR_MAX_SIZE) {
+			debug("bogus address length\n");
+			free(packet);
+			return NULL;
+		}
+		memcpy(packet->addr, addr, addrlen);
+		packet->addrlen = addrlen;
+	}
+	return packet;
+}
+
+static void free_packet(struct packet *packet)
+{
+	debug("Freeing packet\n");
+	list_del(&packet->queue);
+	free(packet);
+}
+
+static void release_packet(struct packet *packet)
+{
+	packet->refcount--;
+	if (!packet->refcount)
+		free_packet(packet);
+}
+
+static struct packet *get_packet(struct packet *packet)
+{
+	if (packet)
+		packet->refcount++;
+	return packet;
+}
+
+/*
+ * Returns  0 if there may be another packet in the buffer.
+ * Returns -1 if there is no more packets to process.
+ * Returns -2 if the client was destroyed.
+ */
+static int process_single_packet_from_client(struct client *client)
+{
+	unsigned long fragment_header;
+	struct packet *packet;
+
+	/* see if we have the packet marker */
+	if (client->bufferpos < 4) {
+		/* nope, not enough data.. */
+		return -1;
+	}
+
+	/* check to see if this is a fragmented rpc packet */
+	if (!(client->buffer[0] & 0x80)) {
+		debug("Cannot handle fragmented rpc packets in stream from client, killing client\n");
+		free_client(client);
+		return -1;
+	}
+	client->buffer[0] &= 0x7f;
+
+	memcpy(&fragment_header, client->buffer, 4);
+
+	fragment_header = ntohl(fragment_header);
+	debug("Found RPC packet of length %d\n", fragment_header);
+
+	/* sanity check to ensure we don't have a bogus fragment header */
+	if (fragment_header > BUFFER_SIZE - 4) {
+		debug("Fragment header reported a huge number, killing client\n");
+		free_client(client);
+		return -1;
+	}
+
+	/* check to see if we have the whole packet */
+	if (client->bufferpos >= 4 + fragment_header) {
+		packet = create_packet(&client->buffer[4], fragment_header, client->type == SOCK_STREAM, client->conn->addr, client->conn->addr_len);
+		memmove(client->buffer,
+		        &client->buffer[4+fragment_header],
+			client->bufferpos - (4 + fragment_header));
+		client->bufferpos -= (4 + fragment_header);
+		if (packet) {
+			uint32_t recvxid, sendxid;
+
+			if (packet->len < 4) {
+				debug("packet was way too short, dropping\n");
+				release_packet(packet);
+				/* we may have another good packet, continue */
+				return 0;
+			}
+
+			/* Fix up the xid */
+			memcpy(&recvxid, &packet->buf[client->type == SOCK_STREAM ? 4 : 0], 4);
+			sendxid = new_xid(
+				client,
+				 (client->type == SOCK_DGRAM ? packet : NULL),
+				 recvxid
+				 );
+			debug("Client's xid(%08x) became xid(%08x)\n", recvxid, sendxid);
+			if (!sendxid) {
+				debug("failed to create new xid, dropping\n");
+				release_packet(packet);
+				return 0;
+			}
+			sendxid = htonl(sendxid);
+			memcpy(&packet->buf[client->type == SOCK_STREAM ? 4 : 0], &sendxid, 4);
+
+			debug("Queueing packet to server\n");
+			list_add_tail(&packet->queue, &client->conn->queue_head);
+		} else {
+			debug("Couldn't create packet, dropping\n");
+		}
+		return 0;
+	}
+	return -1;
+}
+
+/* Returns -1 if we hit EAGAIN or client died */
+static int __client_process(struct client *client)
+{
+	int bytes_read;
+	int ret = 0;
+
+	debug("__client_process\n");
+	bytes_read = recv(client->fd, &client->buffer[client->bufferpos],
+			  BUFFER_SIZE - client->bufferpos, 0);
+	debug("recv on client return %d\n", bytes_read);
+	if (bytes_read == 0) {
+		/* Connection closed */
+		debug("Closing local connection\n");
+		free_client(client);
+		return -1;
+	}
+
+	if (bytes_read == -1) {
+		if (errno == EAGAIN) {
+			/* no more data to receive, nothing to see here */
+			debug("got EAGAIN reading from %x\n", 1 << client->fd);
+			return -1;
+		}
+		debug("Error receiving from local client, killing: %s\n", strerror(errno));
+		free_client(client);
+		return -1;
+	}
+
+	/* we have data */
+	debug("Got %d bytes from client\n", bytes_read);
+	client->bufferpos += bytes_read;
+
+	/* process all complete packets */
+	while (!ret) {
+		ret = process_single_packet_from_client(client);
+	}
+
+	/* Stop processing if we have killed the client */
+	return (ret == -2) ? -1 : 0;
+}
+
+/* Returns -1 if the client died */
+static int client_process(struct client *client)
+{
+	int ret;
+	/*
+	 * We keep processing reads until either the client dies or we hit 
+	 * an EAGAIN.
+	 */
+	while ((ret = __client_process(client)) == 0) /* spin */;
+	return ret;
+}
+
+/* Returns -1 if the client died */
+static int client_get_creds(struct client *client)
+{
+	struct msghdr msg = {0};
+	struct cmsghdr *cmsg;
+	struct iovec iovec;
+	char buf1[4096];
+	char buf2[4096];
+	int pos;
+	int ret;
+
+	debug("Received creds header from local client\n");
+	
+	iovec.iov_base = buf1;
+	iovec.iov_len = 4096;
+
+	msg.msg_iov = &iovec;
+	msg.msg_iovlen = 1;
+	msg.msg_control = buf2;
+	msg.msg_controllen = 4096;
+
+	ret = recvmsg(client->fd, &msg, 0);
+	if (ret == -1) {
+		if (errno == EAGAIN) {
+			/* try again later */
+			return 0;
+		}
+		debug("Got error while trying to recvmsg creds: %s\n", strerror(errno));
+		nack_client(client, RPC_AUTHERROR, 0);
+		free_client(client);
+		return -1;
+	}
+	/* check creds and store info */
+	cmsg = CMSG_FIRSTHDR(&msg);
+	if (!cmsg) {
+		debug("Missing ancilliary data\n");
+		nack_client(client, RPC_CANTDECODEARGS, 0);
+		free_client(client);
+		return -1;
+	}
+	if (cmsg->cmsg_level == SOL_SOCKET && cmsg->cmsg_type == SCM_CREDENTIALS) {
+		struct ucred *ucred = (struct ucred *)CMSG_DATA(cmsg);
+		if (ucred->uid != 0) {
+			debug("Killing off rogue client\n");
+			nack_client(client, RPC_AUTHERROR, 0);
+			free_client(client);
+			return -1;
+		}
+	} else {
+		debug("Unknown ancilliary data found\n");
+		nack_client(client, RPC_AUTHERROR, 0);
+		free_client(client);
+		return -1;
+	}
+
+	/* now copy out the server info */
+	pos = 0;
+
+	if (iovec.iov_len < pos + sizeof(client->addr_len)) goto not_enough;
+	memcpy(&client->addr_len, &buf1[pos], sizeof(client->addr_len));
+	pos += sizeof(client->addr_len);
+
+	if (iovec.iov_len < pos + client->addr_len) goto not_enough;
+	if (client->addr_len > 4096) {
+		debug("Client sent a really big address, killing it\n");
+		nack_client(client, RPC_UNKNOWNADDR, 0);
+		free_client(client);
+		return -1;
+	}
+	client->addr = malloc(client->addr_len);
+	if (!client->addr) {
+		debug("malloc failure\n");
+		nack_client(client, RPC_SYSTEMERROR, ENOMEM);
+		free_client(client);
+		return -1;
+	}
+	memcpy(client->addr, &buf1[pos], client->addr_len);
+	pos += client->addr_len;
+
+	if (iovec.iov_len < pos + sizeof(client->domain)) goto not_enough;
+	memcpy(&client->domain, &buf1[pos], sizeof(client->domain));
+	pos += sizeof(client->domain);
+
+	if (iovec.iov_len < pos + sizeof(client->type)) goto not_enough;
+	memcpy(&client->type, &buf1[pos], sizeof(client->type));
+	pos += sizeof(client->type);
+
+	/* looks good I guess, move on to starting a connect */
+	if (get_server_to_remote(client)) {
+		debug("Couldn't start bringing up a server, killing client\n");
+		nack_client(client, RPC_UNKNOWNADDR, 0);
+		free_client(client);
+		return -1;
+	}
+
+	/* We have to read as much as we can here to reset the poll status */
+	return 0;
+not_enough:
+	debug("Didn't receive enough data on negotiation\n");
+	nack_client(client, RPC_FAILED, 0);
+	free_client(client);
+	return -1;
+}
+
+/* Returns -1 if the client died */
+static int handle_client_read(struct client *client)
+{
+	switch (client->state) {
+		case CS_WAITING_CREDS:
+			return client_get_creds(client);
+			break;
+		case CS_PROCESSING:
+			return client_process(client);
+			break;
+		case CS_WAITING_FOR_CONNECT:
+			debug("Should *never* get here\n");
+			free_client(client);
+			break;
+	}
+	return -1;
+}
+
+static void handle_pending_outbound_server(struct server *conn)
+{
+	int ret, ret_len;
+	struct client *client, *_client;
+
+	debug("Handling completed pending outbound server\n");
+
+	/* Get the return value */
+	ret_len = sizeof(ret);
+	if (getsockopt(conn->socketfd, SOL_SOCKET, SO_ERROR, &ret, &ret_len)) {
+		/* Hmm.. that failed */
+		debug("Error while checking in progress state of outbound server: %s\n", strerror(errno));
+		close_server(conn, RPC_SYSTEMERROR, errno);
+		return;
+	}
+
+	/* Now inspect the return value */
+	if (ret) {
+		debug("Couldn't make outbound server: %s\n", strerror(ret));
+		close_server(conn, RPC_SYSTEMERROR, ret);
+		return;
+	}
+
+	/* Looks good, mark the server up */
+	conn->state = SS_OK;
+
+	/* Update the state of all clients waiting on this server */
+	list_for_each_entry_safe(client, _client, &clients, list) {
+		if (client->conn != conn)
+			continue;
+
+		if (client->state != CS_WAITING_FOR_CONNECT) {
+			debug("Whoa, client state was wrong! Killing\n");
+			free_client(client);
+			continue;
+		}
+
+		client->state = CS_PROCESSING;
+		ack_client(client);
+		/* we start processing data */
+		client_process(client);
+	}
+}
+
+/*
+ * Returns  0 if there may be another packet in the buffer.
+ * Returns -1 if there is no more packets to process.
+ * Returns -2 if the client was destroyed.
+ *
+ * last_received is the number of bytes we got on the last read, required 
+ * for datagram services.
+ */
+static int process_single_packet_from_server(struct server *conn, unsigned long last_received)
+{
+	struct packet *packet;
+	char *buf; /* the buffer to read from socket */
+	unsigned long len;
+
+	if (is_conn_udp(conn)) {
+		/* udp doesn't have a fragment header */
+		len = last_received;
+		buf = conn->buffer;
+
+		/* we know we have the whole packet */
+	} else {
+		/* have to read in the fragment header */
+
+		/* see if we have the packet marker */
+		if (conn->bufferpos < 4) {
+			/* nope, not enough data.. */
+			return -1;
+		}
+
+		/* check to see if this is a fragmented rpc packet */
+		if (!(conn->buffer[0] & 0x80)) {
+			debug("Cannot handle fragmented rpc packets in stream from server, killing client\n");
+			close_server(conn, RPC_CANTRECV, 0);
+			return -1;
+		}
+		conn->buffer[0] &= 0x7f;
+
+		memcpy(&len, conn->buffer, 4);
+
+		len = ntohl(len);
+		buf = &conn->buffer[4];
+
+		/*
+		 * sanity check to ensure we don't have a bogusly long
+		 * fragment header.
+		 */
+		if (len > BUFFER_SIZE - 4) {
+			debug("Fragment header reported a huge number, closing server\n");
+			close_server(conn, RPC_CANTRECV, EOVERFLOW);
+			return -1;
+		}
+
+		/* check to see if we have the whole packet */
+		if (conn->bufferpos < 4 + len) {
+			/* gotta keep reading */
+			return -1;
+		}
+	}
+
+	debug("Found RPC packet of length %d\n", len);
+
+	/* Packets sent to the client are always stream */
+	packet = create_packet(buf, len, 1, NULL, 0);
+
+	/*
+	 * Shift the remaining data in the buffer, which we only care about
+	 * for non-udp.
+	 */
+	if (!is_conn_udp(conn)) {
+		/* only done in streams */
+		memmove(conn->buffer,
+		        &conn->buffer[4+len],
+			conn->bufferpos - (4 + len));
+		/* roll back another 4 bytes for the fragment header */
+		conn->bufferpos -= 4;
+	}
+	conn->bufferpos -= len;
+
+	if (packet) {
+		struct client *client;
+		uint32_t recvxid, sendxid = -1;
+
+		if (packet->len < 16) {
+			debug("packet was way too short, dropping\n");
+			release_packet(packet);
+			/* we may have another good packet, continue */
+			return 0;
+		}
+
+		/*
+		 * The XID is located at:
+		 *  +4 for the fragment header
+		 */
+		memcpy(&recvxid, &packet->buf[4], 4);
+		recvxid = ntohl(recvxid);
+		client = find_xid(recvxid, &sendxid);
+		debug("Server's response xid(%08x) matched to be xid(%08x)\n", recvxid, sendxid);
+		if (!client) {
+			debug("Received bogus xid(%08x) from server, dropping\n", recvxid);
+			release_packet(packet);
+			return 0;
+		}
+		debug("Queueing packet to client\n");
+		memcpy(&packet->buf[4], &sendxid, 4);
+		list_add_tail(&packet->queue, &client->queue_head);
+	} else {
+		debug("Couldn't create packet, dropping\n");
+	}
+	return 0;
+}
+
+/* Returns -1 if we hit EAGAIN or client died */
+static int __handle_outbound_server_read(struct server *conn)
+{
+	int bytes_read;
+	int ret = 0;
+
+	debug("__handle_outbound_server_read\n");
+	bytes_read = recv(conn->socketfd, &conn->buffer[conn->bufferpos],
+			  BUFFER_SIZE - conn->bufferpos, is_conn_udp(conn) ? MSG_TRUNC : 0);
+	if (bytes_read == 0) {
+		/* Connection closed */
+		debug("Closing connection to server\n");
+		close_server(conn, 0, 0);
+		return -1;
+	}
+
+	if (bytes_read == -1) {
+		if (errno == EAGAIN) {
+			/* no more data to receive, nothing to see here */
+			debug("got EAGAIN reading from (server) %x\n", 1 << conn->socketfd);
+			return -1;
+		}
+		debug("Error receiving from server, closing: %s\n", strerror(errno));
+		close_server(conn, RPC_SYSTEMERROR, errno);
+		return -1;
+	}
+
+	/*
+	 * bytes_read is the actual length of the packet, we need
+	 * to make sure we got the whole thing.
+	 */
+	if (bytes_read > BUFFER_SIZE - conn->bufferpos) {
+		debug("packet was larger than buffer, dropping\n");
+		/* try again for next packet */
+		return 0;
+	}
+
+	/* we have data */
+	debug("Got %d bytes from server\n", bytes_read);
+	conn->bufferpos += bytes_read;
+
+	/* process all complete packets */
+	while (!ret) {
+		ret = process_single_packet_from_server(conn, bytes_read);
+		/* we can only get one packet with udp per recv */
+		if (is_conn_udp(conn))
+			break;
+	}
+
+	/* Stop processing if we have killed the client */
+	return (ret == -2) ? -1 : 0;
+}
+
+static void handle_outbound_server_read(struct server *conn)
+{
+	/*
+	 * We keep processing reads until either the server dies
+	 * or we hit an EAGAIN.
+	 */
+	while (!__handle_outbound_server_read(conn)) /* spin */;
+}
+
+static int handle_outbound_server_flush_one_packet(struct server *conn, struct packet *packet)
+{
+	int ret;
+
+	debug("Trying to flush data to server\n");
+	while (1) {
+		ret = sendto(conn->socketfd, &packet->buf[packet->pos], packet->len - packet->pos, MSG_NOSIGNAL, (struct sockaddr *)&packet->addr, packet->addrlen);
+		debug("sent %d bytes to server\n", ret);
+		if (ret == -1) {
+			if (errno == EAGAIN) {
+				/* oops, buffer full.. that's it for now */
+				return -1;
+			}
+			/* some other error? */
+			debug("Got error writing to external service: %s\n", strerror(errno));
+			close_server(conn, RPC_SYSTEMERROR, errno);
+			return -1;
+		} else if (ret == 0) {
+			/* socket closed on us */
+			close_server(conn, 0, 0);
+			return -1;
+		}
+
+		packet->pos += ret;
+
+		if (packet->pos == packet->len) {
+			/* done with this packet, dequeue and move on */
+			debug("Dequeueing packet -- done sending to server\n");
+			list_del_init(&packet->queue);
+			release_packet(packet);
+			return 0;
+		}
+	} /* keep trying to complete this packet until we get EAGAIN */
+}
+
+static void handle_outbound_server_flush(struct server *conn)
+{
+	struct packet *packet, *_packet;
+	debug("Able to flush data on server\n");
+	list_for_each_entry_safe(packet, _packet, &conn->queue_head, queue) {
+		if (handle_outbound_server_flush_one_packet(conn, packet))
+			break;
+	}
+}
+
+static int handle_client_flush_one_packet(struct client *client, struct packet *packet)
+{
+	int ret;
+
+	debug("Trying to flush data to client\n");
+	while (1) {
+		ret = send(client->fd, &packet->buf[packet->pos], packet->len - packet->pos, MSG_NOSIGNAL);
+		if (ret == -1) {
+			if (errno == EAGAIN) {
+				/* oops, buffer full.. that's it for now */
+				return -1;
+			}
+			/* some other error? */
+			debug("Got error writing back to client: %s\n", strerror(errno));
+			free_client(client);
+			return -1;
+		} else if (ret == 0) {
+			/* socket closed on us */
+			free_client(client);
+			return -1;
+		}
+
+		packet->pos += ret;
+
+		if (packet->pos == packet->len) {
+			/* done with this packet, move on */
+			release_packet(packet);
+			return 0;
+		}
+	} /* keep trying to complete this packet until we get EAGAIN */
+}
+
+static void handle_client_flush(struct client *client)
+{
+	struct packet *packet, *_packet;
+	debug("Able to flush data back to client\n");
+	list_for_each_entry_safe(packet, _packet, &client->queue_head, queue) {
+		if (handle_client_flush_one_packet(client, packet))
+			break;
+	}
+}
+
+static void set_fd(int fd, fd_set *set, int *max)
+{
+	FD_SET(fd, set);
+	if (*max < fd + 1)
+		*max = fd + 1;
+}
+
+static void fd_set_listener(fd_set *rset, fd_set *wset, int *max)
+{
+	set_fd(sockfd, rset, max);
+	debug("setting %x in rset (listen)\n", 1 << sockfd);
+}
+
+static void fd_set_all_clients(fd_set *rset, fd_set *wset, int *max)
+{
+	struct client *client;
+
+	list_for_each_entry(client, &clients, list) {
+		if (client->state != CS_PROCESSING && client->state != CS_WAITING_CREDS)
+			continue;
+		/* we always try to read from local clients */
+		set_fd(client->fd, rset, max);
+		debug("setting %x in rset (client)\n", 1 << client->fd);
+		/* but we only try to write when we can */
+		if (!list_empty(&client->queue_head)) {
+			debug("Going to wait on client for writing\n");
+			set_fd(client->fd, wset, max);
+		} else {
+			debug("Nothing to write to client\n");
+		}
+	}
+}
+
+static void fd_set_all_outbound_servers(fd_set *rset, fd_set *wset, int *max)
+{
+	struct server *conn;
+
+	list_for_each_entry(conn, &servers, list) {
+		switch (conn->state) {
+		case SS_OK:
+			/* there might always be data to read */
+			set_fd(conn->socketfd, rset, max);
+			debug("setting %x in rset (connection)\n", 1 << conn->socketfd);
+			/* but we only want to write when we can */
+			if (!list_empty(&conn->queue_head)) {
+				debug("setting wset for server, queue wasn't empty\n");
+				set_fd(conn->socketfd, wset, max);
+			}
+			break;
+		case SS_INPROGRESS:
+			set_fd(conn->socketfd, wset, max);
+			break;
+		case SS_CLOSED:
+			/* do nothing */
+			break;
+		}
+	}
+}
+
+static void check_listener(fd_set *rset, fd_set *wset)
+{
+	int newconnfd;
+	struct sockaddr_un addr;
+	socklen_t addr_len = sizeof(addr);
+	int ret;
+	int val;
+
+	if (!FD_ISSET(sockfd, rset))
+		return;
+	
+	/* accept a new local client */
+	newconnfd = accept(sockfd, (struct sockaddr *)&addr, &addr_len);
+	if (newconnfd == -1)
+		die("Got error while accepting: %s", strerror(errno));
+	debug("accepted on socket %x\n", 1 << newconnfd);
+	ret = fcntl(newconnfd, F_SETFL, O_NONBLOCK);
+	if (ret)
+		die("Couldn't set O_NONBLOCK on new local connection: %s", strerror(errno));
+	val = 1;
+	ret = setsockopt(newconnfd, SOL_SOCKET, SO_PASSCRED, &val, sizeof(val));
+	if (ret)
+		die("Couldn't set SO_PASSCRED on new local connection: %s", strerror(errno));
+	add_client(newconnfd);
+}
+
+static void check_all_clients(fd_set *rset, fd_set *wset)
+{
+	struct client *client, *_client;
+
+	list_for_each_entry_safe(client, _client, &clients, list) {
+		if (FD_ISSET(client->fd, rset))
+			if (handle_client_read(client))
+				continue;
+		if (FD_ISSET(client->fd, wset))
+			handle_client_flush(client);
+	}
+}
+
+static void check_all_outbound_servers(fd_set *rset, fd_set *wset)
+{
+	struct server *conn, *_conn;
+
+	list_for_each_entry_safe(conn, _conn, &servers, list) {
+		if (conn->socketfd < 0)
+			continue;
+		switch (conn->state) {
+		case SS_INPROGRESS:
+			if (FD_ISSET(conn->socketfd, wset))
+				handle_pending_outbound_server(conn);
+			break;
+		case SS_OK:
+			/*
+			 * Need to grab a reference to the server so
+			 * that it doesn't go away on us.
+			 * We don't want to reset the timeout however.
+			 */
+			conn->refcount++;
+			if (FD_ISSET(conn->socketfd, wset))
+				handle_outbound_server_flush(conn);
+			if (conn->socketfd >= 0 && FD_ISSET(conn->socketfd, rset))
+				handle_outbound_server_read(conn);
+			release_server_no_timeout(conn);
+			break;
+		case SS_CLOSED:
+			/* do nothing */
+			break;
+		}
+	}
+}
+
+static void check_retrans_packets(void)
+{
+	struct client *client;
+
+	/*
+	 * walk all client->xid->retrans and determine what needs to
+	 * be retransmitted.
+	 */
+	list_for_each_entry(client, &clients, list) {
+		struct xid_map *xid, *_xid;
+		list_for_each_entry_safe(xid, _xid, &client->xids, list) {
+			struct packet *packet = xid->retrans;
+			if (!packet)
+				continue;
+
+			/* make sure that it isn't already queued */
+			if (!list_empty(&packet->queue))
+				continue;
+
+			packet->retrans_times--;
+
+			/*
+			 * For UDP retransmission, we only send the packet off
+			 * a couple times.  We don't have to notify the client
+			 * of the timeout because it will timeout itself,
+			 * possibly closing it's connection, though that isn't
+			 * guaranteed.
+			 */
+			if (!packet->retrans_times) {
+				uint32_t orig;
+
+				debug("Dropping UDP packet, failed all retransmission retries\n");
+				/*
+				 * Just call the find_xid routine as it will
+				 * clean everything up.
+				 */
+				find_xid(xid->to_server, &orig);
+				continue;
+			}
+
+			debug("Scheduling a retransmission\n");
+
+			/*
+			 * Rewind and queue the packet off to the connection
+			 * again. We increase the refcount as it is now
+			 * referenced on the connection queue.
+			 */
+			packet->pos = 0;
+			gettimeofday(&packet->retrans_time, NULL);
+			packet->retrans_time.tv_sec += RETRANS_TIMEOUT;
+			packet->refcount++;
+			list_add_tail(&packet->queue, &client->conn->queue_head);
+		}
+	}
+}
+
+static struct timeval *find_next_timeout(void)
+{
+	static struct timeval tv;
+	struct server *conn;
+	struct timeval curtime;
+	struct client *client;
+
+	/* Start with a blank timeout */
+
+	memset(&tv, 0, sizeof(tv));
+
+	/*
+	 * We walk all current servers and decide if they should expire
+	 * any time soon. We do all math in absolute values first, and then
+	 * make the timeout relative.
+	 */
+	list_for_each_entry(conn, &servers, list) {
+		/* is this server actually valid? */
+		if (conn->state != SS_OK)
+			continue;
+
+		/* is somebody still using this server? */
+		if (conn->refcount)
+			continue;
+
+		/* is there no timeout yet? */
+		if (tv.tv_sec == 0 && tv.tv_usec == 0) {
+			tv = conn->timeout;
+			continue;
+		}
+
+		/* compare to see if this timeout is less than the set one */
+		if (conn->timeout.tv_sec < tv.tv_sec) {
+			tv = conn->timeout;
+		}
+	}
+
+	/* Now we walk all clients->xid and check their returns */
+	list_for_each_entry(client, &clients, list) {
+		struct xid_map *xid;
+		list_for_each_entry(xid, &client->xids, list) {
+			struct packet *packet = xid->retrans;
+			debug("Evaluating packet timeout\n");
+			if (!packet)
+				continue;
+			if (tv.tv_sec == 0 && tv.tv_usec == 0) {
+				debug("Setting timeout for retrans\n");
+				tv = packet->retrans_time;
+				continue;
+			}
+			if (packet->retrans_time.tv_sec < tv.tv_sec) {
+				debug("Setting timeout for retrans\n");
+				tv = packet->retrans_time;
+			}
+		}
+	}
+
+	/*
+	 * Now, if we have a timeout value, we have to knock it into a
+	 * relative time for the select.
+	 */
+	if (tv.tv_sec == 0 && tv.tv_usec == 0)
+		return NULL;
+
+	gettimeofday(&curtime, NULL);
+	tv.tv_sec  -= curtime.tv_sec;
+	tv.tv_usec = 0;
+	/*
+	 * Hack to ensure that there is a timeout if we should have expire
+	 * already.
+	 */
+	if (tv.tv_sec < 1) tv.tv_sec = 1;
+	debug("Set to timeout in %d seconds\n", tv.tv_sec);
+	return &tv;
+}
+
+static void release_timed_out_servers(void)
+{
+	struct server *conn, *_conn;
+	struct timeval curtime;
+
+	gettimeofday(&curtime, NULL);
+
+	list_for_each_entry_safe(conn, _conn, &servers, list) {
+		if (conn->refcount == 0
+		 && conn->state == SS_OK
+		 && curtime.tv_sec >= conn->timeout.tv_sec) {
+			debug("Timing out a cached server\n");
+			close_server(conn, 0, 0);
+			free_server(conn);
+		}
+	}
+}
+
+static void message_loop(void)
+{
+	while (1) {
+		fd_set read_set;
+		fd_set write_set;
+
+		struct timeval *timeout;
+		int max = 0;
+		int ret;
+
+		FD_ZERO(&read_set);
+		FD_ZERO(&write_set);
+
+		fd_set_listener(&read_set, &write_set, &max);
+		fd_set_all_clients(&read_set, &write_set, &max);
+		fd_set_all_outbound_servers(&read_set, &write_set, &max);
+
+		timeout = find_next_timeout();
+
+		printf("setting read: %x write: %x max: %d\n", (unsigned)read_set.__fds_bits[0], (unsigned)write_set.__fds_bits[0], max);
+		ret = select(max, &read_set, &write_set, NULL, timeout);
+		printf("got     read: %x write: %x\n", (unsigned)read_set.__fds_bits[0], (unsigned)write_set.__fds_bits[0]);
+		if (ret == -1) {
+			if (errno == EINTR)
+				continue;
+			die("Got some funky error on select: %s", strerror(errno));
+		}
+
+		release_timed_out_servers();
+		check_retrans_packets();
+
+		check_listener(&read_set, &write_set);
+		check_all_clients(&read_set, &write_set);
+		check_all_outbound_servers(&read_set, &write_set);
+	}
+}
+
+int main(int argc, const char **argv)
+{
+	called_name = argv[0];
+	parse_args(argc, argv);
+	debug("About to perform sanity checks\n");
+	sanity_check();
+	debug("About to close fds\n");
+	close_fds();
+	debug("About to setup signals\n");
+	setup_signals();
+	/*
+	 * we create the listener before we double fork so that we can
+	 * get a meaningful error back if there is already someone running.
+	 */
+	debug("About to setup listener socket\n");
+	setup_listener();
+	debug("About to double fork\n");
+	double_fork();
+	debug("About to enter message loop\n");
+	message_loop();
+	return 0;
+}
Index: util-linux-2.12p/lib/clnt_proxy.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ util-linux-2.12p/lib/clnt_proxy.c	2005-03-07 15:22:00.510890696 -0500
@@ -0,0 +1,831 @@
+/*
+ * Sun RPC is a product of Sun Microsystems, Inc. and is provided for
+ * unrestricted use provided that this legend is included on all tape
+ * media and as a part of the software program in whole or part.  Users
+ * may copy or modify Sun RPC without charge, but are not authorized
+ * to license or distribute it to anyone else except as part of a product or
+ * program developed by the user.
+ *
+ * SUN RPC IS PROVIDED AS IS WITH NO WARRANTIES OF ANY KIND INCLUDING THE
+ * WARRANTIES OF DESIGN, MERCHANTIBILITY AND FITNESS FOR A PARTICULAR
+ * PURPOSE, OR ARISING FROM A COURSE OF DEALING, USAGE OR TRADE PRACTICE.
+ *
+ * Sun RPC is provided with no support and without any obligation on the
+ * part of Sun Microsystems, Inc. to assist in its use, correction,
+ * modification or enhancement.
+ *
+ * SUN MICROSYSTEMS, INC. SHALL HAVE NO LIABILITY WITH RESPECT TO THE
+ * INFRINGEMENT OF COPYRIGHTS, TRADE SECRETS OR ANY PATENTS BY SUN RPC
+ * OR ANY PART THEREOF.
+ *
+ * In no event will Sun Microsystems, Inc. be liable for any lost revenue
+ * or profits or other special, indirect and consequential damages, even if
+ * Sun has been advised of the possibility of such damages.
+ *
+ * Sun Microsystems, Inc.
+ * 2550 Garcia Avenue
+ * Mountain View, California  94043
+ */
+
+/*
+ * clnt_unix.c, Implements a TCP/IP based, client side RPC.
+ *
+ * Copyright (C) 1984, Sun Microsystems, Inc.
+ * Copyright (C) 2005, Mike Waychison <mike@waychison.com>
+ *
+ * Clntproxy does not support 'batched calls'.
+ *
+ * Now go hang yourself.
+ */
+
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <sys/un.h>
+#include <sys/wait.h>
+#include <sys/uio.h>
+#include <sys/poll.h>
+#include <string.h>
+#include <unistd.h>
+#include <stdlib.h>
+#include <errno.h>
+
+#include <rpc/pmap_prot.h>
+
+#include "clnt_proxy.h"
+
+/*
+ * TODO:
+ *   - The errors are a little too generic and aren't mapped well
+ *   - Audit members of ct_data.
+ */
+
+#define MCALL_MSG_SIZE 24
+struct ct_data {
+	int ct_sock;
+	struct timeval ct_wait;
+	bool_t ct_waitset;		/* wait set by clnt_control? */
+	char ct_addr[128];
+	int ct_addrlen;
+	struct rpc_err ct_error;
+	char ct_mcall[MCALL_MSG_SIZE];	/* marshalled callmsg */
+	u_int ct_mpos;			/* pos after marshal */
+	XDR ct_xdrs;
+};
+
+static bool_t clntproxy_freeres(CLIENT *cl, xdrproc_t xdr_res, caddr_t res_ptr)
+{
+	struct ct_data *ct = (struct ct_data *)cl->cl_private;
+	XDR *xdrs = &ct->ct_xdrs;
+
+	xdrs->x_op = XDR_FREE;
+	return (*xdr_res)(xdrs, res_ptr);
+}
+
+static void clntproxy_destroy(CLIENT *h)
+{
+	struct ct_data *ct = (struct ct_data *) h->cl_private;
+
+	close(ct->ct_sock);
+	XDR_DESTROY(&ct->ct_xdrs);
+	mem_free((caddr_t) ct, sizeof(struct ct_data));
+	mem_free((caddr_t) h, sizeof(CLIENT));
+}
+
+static void clntproxy_geterr(CLIENT *h, struct rpc_err *errp)
+{
+	struct ct_data *ct = (struct ct_data *)h->cl_private;
+
+	*errp = ct->ct_error;
+}
+
+static void clntproxy_abort(void)
+{
+}
+
+static bool_t clntproxy_control(CLIENT *cl, int request, char *info)
+{
+	struct ct_data *ct = (struct ct_data *)cl->cl_private;
+
+	switch (request) {
+	case CLSET_TIMEOUT:
+		ct->ct_wait = *(struct timeval *)info;
+		break;
+	case CLGET_TIMEOUT:
+		*(struct timeval *)info = ct->ct_wait;
+		break;
+		/* TODO: 
+	case CLGET_SERVER_ADDR:
+		*(struct sockaddr_un *)info = ct->ct_addr;
+		break;
+		*/
+	case CLGET_FD:
+		*(int *)info = ct->ct_sock;
+		break;
+	case CLGET_XID:
+		/*
+		 * use the knowledge that xid is the
+		 * first element in the call structure *.
+		 * This will get the xid of the PREVIOUS call
+		 */
+		*(u_long *)info = ntohl(*(u_long *)ct->ct_mcall);
+		break;
+	case CLSET_XID:
+		/* This will set the xid of the NEXT call */
+		*(u_long *)ct->ct_mcall = htonl(*(u_long *)info - 1);
+		/* decrement by 1 as clntunix_call() increments once */
+	case CLGET_VERS:
+		/*
+		 * This RELIES on the information that, in the call body,
+		 * the version number field is the fifth field from the
+		 * begining of the RPC header. MUST be changed if the
+		 * call_struct is changed
+		 */
+		*(u_long *)info = ntohl(*(u_long *)(ct->ct_mcall + 4 * BYTES_PER_XDR_UNIT));
+		break;
+	case CLSET_VERS:
+		*(u_long *)(ct->ct_mcall + 4 * BYTES_PER_XDR_UNIT) = htonl(*(u_long *) info);
+		break;
+	case CLGET_PROG:
+		/*
+		 * This RELIES on the information that, in the call body,
+		 * the program number field is the	field from the
+		 * begining of the RPC header. MUST be changed if the
+		 * call_struct is changed
+		 */
+		*(u_long *)info = ntohl(*(u_long *)(ct->ct_mcall + 3 * BYTES_PER_XDR_UNIT));
+		break;
+	case CLSET_PROG:
+		*(u_long *)(ct->ct_mcall + 3 * BYTES_PER_XDR_UNIT) = htonl(*(u_long *)info);
+		break;
+	/* The following are only possible with TI-RPC */
+	case CLGET_RETRY_TIMEOUT:
+	case CLSET_RETRY_TIMEOUT:
+	case CLGET_SVC_ADDR:
+	case CLSET_SVC_ADDR:
+	case CLSET_PUSH_TIMOD:
+	case CLSET_POP_TIMOD:
+	case CLSET_FD_CLOSE:
+	case CLSET_FD_NCLOSE:
+	default:
+		return FALSE;
+	}
+	return TRUE;
+}
+
+static void accepted(enum accept_stat acpt_stat, struct rpc_err *error)
+{
+	switch (acpt_stat) {
+	case PROG_UNAVAIL:
+		error->re_status = RPC_PROGUNAVAIL;
+		return;
+	case PROG_MISMATCH:
+		error->re_status = RPC_PROGVERSMISMATCH;
+		return;
+	case PROC_UNAVAIL:
+		error->re_status = RPC_PROCUNAVAIL;
+		return;
+	case GARBAGE_ARGS:
+		error->re_status = RPC_CANTDECODEARGS;
+		return;
+	case SYSTEM_ERR:
+		error->re_status = RPC_SYSTEMERROR;
+		return;
+	case SUCCESS:
+		error->re_status = RPC_SUCCESS;
+		return;
+	}
+	/* something's wrong, but we don't know what ... */
+	error->re_status = RPC_FAILED;
+	error->re_lb.s1 = (long)MSG_ACCEPTED;
+	error->re_lb.s2 = (long)acpt_stat;
+}
+
+static void rejected(enum reject_stat rjct_stat, struct rpc_err *error)
+{
+	switch (rjct_stat) {
+	case RPC_VERSMISMATCH:
+		error->re_status = RPC_VERSMISMATCH;
+		return;
+	case AUTH_ERROR:
+		error->re_status = RPC_AUTHERROR;
+		return;
+	default:
+		/* something's wrong, but we don't know what ... */
+		error->re_status = RPC_FAILED;
+		error->re_lb.s1 = (long)MSG_DENIED;
+		error->re_lb.s2 = (long)rjct_stat;
+		return;
+	}
+}
+
+static void seterr_reply(struct rpc_msg *msg, struct rpc_err *error)
+{
+	/* optimized for normal, SUCCESSful case */
+	switch (msg->rm_reply.rp_stat) {
+	case MSG_ACCEPTED:
+		if (msg->acpted_rply.ar_stat == SUCCESS) {
+			error->re_status = RPC_SUCCESS;
+			return;
+		};
+		accepted(msg->acpted_rply.ar_stat, error);
+		break;
+	case MSG_DENIED:
+		rejected(msg->rjcted_rply.rj_stat, error);
+		break;
+	default:
+		error->re_status = RPC_FAILED;
+		error->re_lb.s1 = (long)(msg->rm_reply.rp_stat);
+		break;
+	}
+	switch (error->re_status) {
+	case RPC_VERSMISMATCH:
+		error->re_vers.low = msg->rjcted_rply.rj_vers.low;
+		error->re_vers.high = msg->rjcted_rply.rj_vers.high;
+		break;
+	case RPC_AUTHERROR:
+		error->re_why = msg->rjcted_rply.rj_why;
+		break;
+	case RPC_PROGVERSMISMATCH:
+		error->re_vers.low = msg->acpted_rply.ar_vers.low;
+		error->re_vers.high = msg->acpted_rply.ar_vers.high;
+		break;
+	default:
+		break;
+	}
+}
+
+static enum clnt_stat clntproxy_call(CLIENT *h, u_long proc, xdrproc_t xdr_args, caddr_t args_ptr, xdrproc_t xdr_results, caddr_t results_ptr, struct timeval timeout)
+{
+	struct ct_data *ct = (struct ct_data *)h->cl_private;
+	XDR *xdrs = &ct->ct_xdrs;
+	struct rpc_msg reply_msg;
+	u_long x_id;
+	u_int32_t *msg_x_id = (u_int32_t *)(ct->ct_mcall);	/* yuk */
+	int refreshes = 2;
+
+	if (!ct->ct_waitset) {
+		ct->ct_wait = timeout;
+	}
+
+call_again:
+	xdrs->x_op = XDR_ENCODE;
+	ct->ct_error.re_status = RPC_SUCCESS;
+	x_id = ntohl(--(*msg_x_id));
+	if ( (!XDR_PUTBYTES(xdrs, ct->ct_mcall, ct->ct_mpos))
+	  || (!XDR_PUTLONG (xdrs, (long *) &proc))
+	  || (!AUTH_MARSHALL (h->cl_auth, xdrs))
+	  || (!(*xdr_args) (xdrs, args_ptr))) {
+		if (ct->ct_error.re_status == RPC_SUCCESS)
+			ct->ct_error.re_status = RPC_CANTENCODEARGS;
+		xdrrec_endofrecord(xdrs, TRUE);
+		return ct->ct_error.re_status;
+	}
+
+	if (!xdrrec_endofrecord(xdrs, 1))
+		return ct->ct_error.re_status = RPC_CANTSEND;
+
+	/*
+	 * Keep receiving until we get a valid transaction id
+	 */
+	xdrs->x_op = XDR_DECODE;
+	while (1) {
+		reply_msg.acpted_rply.ar_verf = _null_auth;
+		reply_msg.acpted_rply.ar_results.where = NULL;
+		reply_msg.acpted_rply.ar_results.proc = (xdrproc_t)xdr_void;
+		if (!xdrrec_skiprecord(xdrs))
+			return ct->ct_error.re_status;
+		/* now decode and validate the response header */
+		if (!xdr_replymsg(xdrs, &reply_msg)) {
+			if (ct->ct_error.re_status == RPC_SUCCESS)
+				continue;
+			return ct->ct_error.re_status;
+		}
+		if (reply_msg.rm_xid == x_id)
+			break;
+		}
+
+	/*
+	 * process header
+	 */
+	seterr_reply (&reply_msg, &(ct->ct_error));
+	if (ct->ct_error.re_status == RPC_SUCCESS) {
+		if (!AUTH_VALIDATE(h->cl_auth, &reply_msg.acpted_rply.ar_verf)) {
+			ct->ct_error.re_status = RPC_AUTHERROR;
+			ct->ct_error.re_why = AUTH_INVALIDRESP;
+		} else if (!(*xdr_results) (xdrs, results_ptr)) {
+			if (ct->ct_error.re_status == RPC_SUCCESS)
+				ct->ct_error.re_status = RPC_CANTDECODERES;
+		}
+
+		/* free verifier ... */
+		if (reply_msg.acpted_rply.ar_verf.oa_base != NULL) {
+			xdrs->x_op = XDR_FREE;
+			xdr_opaque_auth(xdrs, &(reply_msg.acpted_rply.ar_verf));
+		}
+		/* end successful completion */
+	} else {
+		/* maybe our credentials need to be refreshed ... */
+		if (refreshes-- && AUTH_REFRESH(h->cl_auth))
+			goto call_again;
+		/* end of unsuccessful completion */
+	}
+	return ct->ct_error.re_status;
+}
+
+static struct clnt_ops proxy_ops = {
+	clntproxy_call,
+	clntproxy_abort,
+	clntproxy_geterr,
+	clntproxy_freeres,
+	clntproxy_destroy,
+	clntproxy_control,
+};
+
+static void make_proxy_addr(struct sockaddr_un *addr)
+{
+	memset(addr, 0, sizeof(*addr));
+	addr->sun_family = AF_UNIX;
+	strcpy(addr->sun_path, SOCKET_PATH);
+}
+
+static int try_to_connect_to_proxy(void)
+{
+	int fd;
+	int ret;
+	struct sockaddr_un listenaddr;
+	int tries = 1; /* tries left to restart proxy */
+
+	/* First try to connect to an existing proxy socket */
+	fd = socket(AF_UNIX, SOCK_STREAM, 0);
+	if (fd == -1)
+		return -1;
+
+	make_proxy_addr(&listenaddr);
+try_again:
+	ret = connect(fd, (struct sockaddr *)&listenaddr, sizeof(listenaddr));
+	if (ret && tries--) {
+		pid_t pid;
+
+		/* Failed to connect, start the proxy? */
+		if ((pid = fork()) == 0) {
+			/* child */
+			execl(SBINDIR "/rpcproxyd", SBINDIR "/rpcproxyd", NULL);
+			exit(-1);
+		} else if (pid > 1) {
+			/* parent */
+			int status;
+			waitpid(pid, &status, 0);
+			if (WIFEXITED(status) && WEXITSTATUS(status) == 0) {
+				/* looks good, lets try this again */
+				goto try_again;
+			}
+		}
+		/* failed to start up the proxy properly */
+		close(fd);
+		return -1;
+	} else if (ret) {
+		/* error on last try to start proxy */
+		close(fd);
+		return -1;
+	}
+	return fd;
+}
+
+static int send_info(int fd, unsigned long domain, unsigned long type, struct sockaddr *addr, unsigned long addr_len, unsigned long prog, unsigned long vers)
+{
+	struct msghdr msg = {0};
+	struct cmsghdr *cmsg;
+	struct ucred ucred;
+	char buf[CMSG_SPACE(sizeof(ucred))];
+	struct iovec iovec[4];
+	uint32_t val[2];
+	int ret;
+
+	/* Set up ucred info */
+	ucred.pid = getpid();
+	ucred.uid = getuid();
+	ucred.gid = getgid();
+
+	msg.msg_control = buf;
+	msg.msg_controllen = sizeof(buf);
+	cmsg = CMSG_FIRSTHDR(&msg);
+	cmsg->cmsg_level = SOL_SOCKET;
+	cmsg->cmsg_type = SCM_CREDENTIALS;
+	cmsg->cmsg_len = CMSG_LEN(sizeof(ucred));
+	memcpy(CMSG_DATA(cmsg), &ucred, sizeof(ucred));
+	msg.msg_controllen = cmsg->cmsg_len;
+
+	/* Set up iovec with data to pass */
+	iovec[0].iov_base = &addr_len;
+	iovec[0].iov_len = sizeof(addr_len);
+	iovec[1].iov_base = addr;
+	iovec[1].iov_len = addr_len;
+	iovec[2].iov_base = &domain;
+	iovec[2].iov_len = sizeof(domain);
+	iovec[3].iov_base = &type;
+	iovec[3].iov_len = sizeof(type);
+
+	msg.msg_iov = iovec;
+	msg.msg_iovlen = 4;
+
+	ret = sendmsg(fd, &msg, 0);
+	if (ret == -1) {
+		fprintf(stderr, "Couldn't send credentials to proxy: %s\n", strerror(errno));
+		get_rpc_createerr().cf_stat = RPC_CANTSEND;
+		return 1;
+	}
+
+	/* get the 'connected' message back */
+	recv(fd, val, sizeof(val), 0);
+	if (!val[0])
+		return 0;
+	rpc_createerr.cf_stat = ntohl(val[0]);
+	rpc_createerr.cf_error.re_errno = ntohl(val[1]);
+	return -1;
+}
+
+static int type_to_prot(int type)
+{
+	/* TODO: This looks pretty ipv4 tcp/udp centric */
+	if (type == SOCK_DGRAM)
+		return 0x11;
+	if (type == SOCK_STREAM)
+		return 0x06;
+	return 0xFF;
+}
+
+/* Tries to find the port to use using the PMAPPROC_GETPORT call */
+static unsigned long find_port_using_getport(int domain, int type, void *pmapaddr, int pmapaddr_len, int prog, int vers)
+{
+	CLIENT *client;
+	unsigned long port = 0;
+	struct timeval timeout = {10, 0};
+	struct pmap pmap;
+
+	client = clntproxy_create(domain, type, pmapaddr, pmapaddr_len , PMAPPROG, PMAPVERS);
+	if (!client) {
+		return 0;
+	}
+	
+	pmap.pm_prog = prog;
+	pmap.pm_vers = vers;
+	pmap.pm_prot = type_to_prot(type);
+
+	if (clnt_call(client, PMAPPROC_GETPORT,
+		(xdrproc_t) xdr_pmap, (caddr_t) &pmap,
+		(xdrproc_t) xdr_u_long, (caddr_t) &port,
+		timeout)) {
+		clnt_destroy(client);
+		return 0;
+	}
+	clnt_destroy(client);
+	return port;
+}
+
+/* Tries to find the port to use using the PMAPPROC_DUMP call */
+static unsigned long find_port_using_dump(int domain, int type, void *pmapaddr, int pmapaddr_len, int prog, int vers)
+{
+	int port = 0;
+	struct timeval timeout = {10, 0};
+	uint16_t best_guess_port = 0, best_guess_vers = 0;
+	CLIENT *client;
+	struct pmaplist *pmaplist_head = NULL, *pmaplist_cur;
+
+	/* contact the portmapper */
+	client = clntproxy_create(domain, type, pmapaddr, pmapaddr_len, PMAPPROG, PMAPVERS);
+	if (!client) {
+		return 0;
+	}
+
+	if (clnt_call(client, PMAPPROC_DUMP,
+		  (xdrproc_t) &xdr_void, NULL,
+		  (xdrproc_t) &xdr_pmaplist, (caddr_t) &pmaplist_head,
+		  timeout)) {
+		clnt_destroy(client);
+		return 0;
+	}
+
+	pmaplist_cur = pmaplist_head;
+	while (pmaplist_cur) {
+		if (pmaplist_cur->pml_map.pm_prog == prog
+		 && pmaplist_cur->pml_map.pm_vers == vers
+		 && pmaplist_cur->pml_map.pm_prot == type_to_prot(type)) {
+			/* Found exact match */
+			port = pmaplist_cur->pml_map.pm_port;
+			break;
+		}
+
+		/* try for a best guess */
+		if (pmaplist_cur->pml_map.pm_prog == prog
+		 && pmaplist_cur->pml_map.pm_prot == type_to_prot(type)
+		 && pmaplist_cur->pml_map.pm_vers > best_guess_vers) {
+			best_guess_vers = pmaplist_cur->pml_map.pm_vers;
+			best_guess_port = pmaplist_cur->pml_map.pm_port;
+		}
+
+		pmaplist_cur = pmaplist_cur->pml_next;
+	}
+	clnt_destroy(client);
+
+	/* do we have a best guess? */
+	if (!port && best_guess_port)
+		port = best_guess_port;
+	return port;
+}
+
+
+static int fix_up_port(int domain, int type, void *_addr, int prog, int vers)
+{
+	unsigned short port;
+	struct sockaddr_in  in_addr;
+	struct sockaddr_in6 in6_addr;
+	void *pmapaddr;
+	int pmapaddr_len;
+
+	if (domain == AF_INET) {
+		struct sockaddr_in *addr = _addr;
+		port = ntohs(addr->sin_port);
+		in_addr = *addr;
+		in_addr.sin_port = htons(111);
+		pmapaddr = &in_addr;
+		pmapaddr_len = sizeof(in_addr);
+	} else if (domain == AF_INET6) {
+		struct sockaddr_in6 *addr = _addr;
+		port = ntohs(addr->sin6_port);
+		in6_addr = *addr;
+		in6_addr.sin6_port = htons(111);
+		pmapaddr = &in6_addr;
+		pmapaddr_len = sizeof(in6_addr);
+	} else {
+		/* don't know how to fixup */
+		return -1;
+	}
+
+	if (port) {
+		/* looks good */
+		return 0;
+	}
+
+	port = find_port_using_dump(domain, type, pmapaddr, pmapaddr_len, prog, vers);
+	if (!port)
+		port = find_port_using_getport(domain, type, pmapaddr, pmapaddr_len, prog, vers);
+
+	if (!port)
+		return -1;
+
+	if (port) {
+		/* got a new port number, stuff it */
+		if (domain == AF_INET) {
+			struct sockaddr_in *addr = _addr;
+			addr->sin_port = htons(port);
+		} else if (domain == AF_INET6) {
+			struct sockaddr_in6 *addr = _addr;
+			addr->sin6_port = htons(port);
+		}
+	}
+	return 0;
+}
+
+static u_long xid_count = 0;
+static u_long create_xid(void) {
+	return xid_count++;
+}
+
+
+static int __msgread(int sock, void *data, size_t cnt) {
+	struct iovec iov;
+	struct msghdr msg;
+#ifdef SCM_CREDENTIALS
+	static char cm[CMSG_SPACE(sizeof(struct ucred))];
+#endif
+	int len;
+
+	iov.iov_base = data;
+	iov.iov_len = cnt;
+
+	msg.msg_iov = &iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+#ifdef SCM_CREDENTIALS
+	msg.msg_control = (caddr_t)&cm;
+	msg.msg_controllen = CMSG_SPACE(sizeof(struct ucred));
+#endif
+	msg.msg_flags = 0;
+
+#ifdef SO_PASSCRED
+	{
+		int on = 1;
+		if (setsockopt(sock, SOL_SOCKET, SO_PASSCRED, &on, sizeof (on)))
+			return -1;
+	}
+#endif
+
+restart:
+	len = recvmsg(sock, &msg, 0);
+	if (len >= 0) {
+		if (msg.msg_flags & MSG_CTRUNC || len == 0)
+			return 0;
+		else
+			return len;
+	}
+	if (errno == EINTR)
+		goto restart;
+	return -1;
+}
+
+/*
+ * Interface between xdr serializer and unix connection.
+ * Behaves like the system calls, read & write, but keeps some error state
+ * around for the rpc level.
+ */
+static int readproxy(char *ctptr, char *buf, int len)
+{
+	struct ct_data *ct = (struct ct_data *)ctptr;
+	struct pollfd fd;
+	int milliseconds = ((ct->ct_wait.tv_sec * 1000) + (ct->ct_wait.tv_usec / 1000));
+
+	if (len == 0)
+		return 0;
+
+	fd.fd = ct->ct_sock;
+	fd.events = POLLIN;
+	while (1) {
+		switch (poll(&fd, 1, milliseconds)) {
+		case 0:
+			ct->ct_error.re_status = RPC_TIMEDOUT;
+			return -1;
+		case -1:
+			if (errno == EINTR)
+				continue;
+			ct->ct_error.re_status = RPC_CANTRECV;
+			ct->ct_error.re_errno = errno;
+			return -1;
+		}
+		break;
+	}
+	switch (len = __msgread(ct->ct_sock, buf, len)) {
+	case 0:
+		/* premature eof */
+		ct->ct_error.re_errno = ECONNRESET;
+		ct->ct_error.re_status = RPC_CANTRECV;
+		len = -1;			/* it's really an error */
+		break;
+	case -1:
+		ct->ct_error.re_errno = errno;
+		ct->ct_error.re_status = RPC_CANTRECV;
+		break;
+	}
+	return len;
+}
+
+static int __msgwrite(int sock, void *data, size_t cnt) {
+#ifndef SCM_CREDENTIALS
+	/* We cannot implement this reliably.	*/
+	errno = ENOSYS;
+	return -1;
+#else
+	struct iovec iov;
+	struct msghdr msg;
+	struct cmsghdr *cmsg = alloca(CMSG_SPACE(sizeof(struct ucred)));
+	struct ucred cred;
+	int len;
+
+	/*
+	 * XXX I'm not sure, if gete?id() is always correct, or if we should use
+	 * get?id(). But since keyserv needs geteuid(), we have no other chance.
+	 * It would be much better, if the kernel could pass both to the server.
+	 */
+	cred.pid = getpid();
+	cred.uid = geteuid();
+	cred.gid = getegid();
+
+	memcpy(CMSG_DATA(cmsg), &cred, sizeof(struct ucred));
+	cmsg->cmsg_level = SOL_SOCKET;
+	cmsg->cmsg_type = SCM_CREDENTIALS;
+	cmsg->cmsg_len = sizeof(*cmsg) + sizeof(struct ucred);
+
+	iov.iov_base = data;
+	iov.iov_len = cnt;
+
+	msg.msg_iov = &iov;
+	msg.msg_iovlen = 1;
+	msg.msg_name = NULL;
+	msg.msg_namelen = 0;
+	msg.msg_control = cmsg;
+	msg.msg_controllen = CMSG_ALIGN(cmsg->cmsg_len);
+	msg.msg_flags = 0;
+
+restart:
+	len = sendmsg(sock, &msg, 0);
+	if (len >= 0)
+		return len;
+	if (errno == EINTR)
+		goto restart;
+	return -1;
+#endif
+}
+
+static int writeproxy(char *ctptr, char *buf, int len) {
+	int i, cnt;
+	struct ct_data *ct = (struct ct_data *)ctptr;
+
+	for (cnt = len; cnt > 0; cnt -= i, buf += i) {
+		if ((i = __msgwrite(ct->ct_sock, buf, cnt)) == -1) {
+			ct->ct_error.re_errno = errno;
+			ct->ct_error.re_status = RPC_CANTSEND;
+			return -1;
+		}
+	}
+	return len;
+}
+
+/*
+ * Create a client handle for a proxied connection.
+ * If addr->sin_port is 0, then a binder on the remote machine is
+ * consulted for the right port number.
+ * NB: The rpch->cl_auth is set null authentication.  Caller may wish to set
+ * this something more useful.
+ */
+CLIENT *clntproxy_create(unsigned long domain, unsigned long type, struct sockaddr *addr, unsigned long addrlen, unsigned long prog, unsigned long vers)
+{
+	CLIENT *h = NULL;
+	struct ct_data *ct = malloc(sizeof(*ct));
+	struct rpc_createerr *ce = &get_rpc_createerr();
+	struct rpc_msg call_msg;
+	int proxyfd = -1;
+
+	if (fix_up_port(domain, type, addr, prog, vers)) {
+		ce->cf_stat = RPC_RPCBFAILURE;
+		goto fail;
+	}
+
+	h = malloc(sizeof(*h));
+	if (h == NULL || ct == NULL) {
+		struct rpc_createerr *ce = &get_rpc_createerr();
+		fputs("clntproxy_create: out of memory\n", stderr);
+		ce->cf_stat = RPC_SYSTEMERROR;
+		ce->cf_error.re_errno = ENOMEM;
+		goto fail;
+	}
+
+	/*
+	 * Connect to the proxy
+	 */
+	proxyfd = try_to_connect_to_proxy();
+	if (proxyfd == -1)
+		goto fail;
+
+	/* TODO: handle getting closed */
+
+	if (send_info(proxyfd, domain, type, addr, addrlen, prog, vers))
+		goto fail;
+
+	/*
+	 * Set up private data struct
+	 */
+	ct->ct_sock = proxyfd;
+	ct->ct_wait.tv_usec = 0;
+	ct->ct_waitset = 0;
+	memcpy(ct->ct_addr, addr, addrlen);
+	ct->ct_addrlen = addrlen;
+
+	/*
+	 * Initialize call message
+	 */
+	call_msg.rm_xid = create_xid();
+	call_msg.rm_direction = CALL;
+	call_msg.rm_call.cb_rpcvers = RPC_MSG_VERSION;
+	call_msg.rm_call.cb_prog = prog;
+	call_msg.rm_call.cb_vers = vers;
+
+	/*
+	 * pre-serialize the static part of the call msg and stash it away
+	 */
+	xdrmem_create(&ct->ct_xdrs, ct->ct_mcall, MCALL_MSG_SIZE, XDR_ENCODE);
+	if (!xdr_callhdr(&ct->ct_xdrs, &call_msg)) {
+		goto fail;
+	}
+	ct->ct_mpos = XDR_GETPOS(&ct->ct_xdrs);
+	XDR_DESTROY(&ct->ct_xdrs);
+
+	/*
+	 * Create a client handle which uses xdrrec for serialization
+	 * and authnone for authentication.
+	 */
+	xdrrec_create(&ct->ct_xdrs, 0, 0, (caddr_t) ct, readproxy, writeproxy);
+	h->cl_ops = &proxy_ops;
+	h->cl_private = (caddr_t) ct;
+	h->cl_auth = authnone_create();
+	return h;
+
+fail:
+	/*
+	 * Something goofed, free stuff and barf
+	 */
+	close(proxyfd);
+	mem_free ((caddr_t) ct, sizeof (struct ct_data));
+	mem_free ((caddr_t) h, sizeof (CLIENT));
+	return (CLIENT *) NULL;
+}
+
Index: util-linux-2.12p/sys-utils/Makefile
===================================================================
--- util-linux-2.12p.orig/sys-utils/Makefile	2005-03-07 15:21:28.810709856 -0500
+++ util-linux-2.12p/sys-utils/Makefile	2005-03-07 15:22:00.510890696 -0500
@@ -12,7 +12,8 @@
 
 MAN8= 		ctrlaltdel.8 cytune.8 dmesg.8 \
 		ipcrm.8 ipcs.8 renice.8 \
-		setsid.8 sln.8 tunelp.8
+		setsid.8 sln.8 tunelp.8 \
+		rpcproxyd.8
 
 # Where to put binaries?
 # See the "install" rule for the links. . .
@@ -23,7 +24,7 @@
 
 USRSBIN=	readprofile tunelp
 
-SBIN= 		ctrlaltdel
+SBIN= 		ctrlaltdel rpcproxyd
 
 NOTMADE=
 
@@ -76,6 +77,8 @@
 rdev: rdev.o
 renice: renice.o
 readprofile: readprofile.o
+rpcproxyd: rpcproxyd.o 
+rpcproxyd.o: $(LIB)/clnt_proxy.h
 setsid: setsid.o
 
 ipc.info: ipc.texi
@@ -93,6 +96,7 @@
 	(cd $(USRSBINDIR); ln -sf rdev rootflags)
 endif
 	$(INSTALLDIR) $(MAN1DIR) $(MAN8DIR) $(INFODIR)
+	$(INSTALLDIR) $(RPCPROXYDIR)
 	$(INSTALLMAN) $(MAN1) $(MAN1DIR)
 	$(INSTALLMAN) $(MAN8) $(MAN8DIR)
 	$(INSTALLMAN) $(USRINFO) $(INFODIR)
Index: util-linux-2.12p/sys-utils/list.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ util-linux-2.12p/sys-utils/list.h	2005-03-07 15:22:00.511890544 -0500
@@ -0,0 +1,473 @@
+#ifndef _LIST_H
+#define _LIST_H
+
+/* Shamelessly culled from the Linux kernel sources */
+
+/*
+ * These are non-NULL pointers that will result in page faults
+ * under normal circumstances, used to verify that nobody uses
+ * non-initialized list entries.
+ */
+
+#define LIST_POISON1  ((void *) 0x00100100)
+#define LIST_POISON2  ((void *) 0x00200200)
+
+#define offsetof(TYPE, MEMBER) ((size_t) &((TYPE *)0)->MEMBER)
+#define prefetch(x) ((void)0)
+
+/**
+ * container_of - cast a member of a structure out to the containing structure
+ *
+ * @ptr:	the pointer to the member.
+ * @type:	the type of the container struct this is embedded in.
+ * @member:	the name of the member within the struct.
+ *
+ */
+#define container_of(ptr, type, member) ({			\
+        const typeof( ((type *)0)->member ) *__mptr = (ptr);	\
+        (type *)( (char *)__mptr - offsetof(type,member) );})
+
+struct list_head {
+	struct list_head *next, *prev;
+};
+
+#define LIST_HEAD_INIT(name) { &(name), &(name) }
+
+#define LIST_HEAD(name) \
+	struct list_head name = LIST_HEAD_INIT(name)
+
+#define INIT_LIST_HEAD(ptr) do { \
+	(ptr)->next = (ptr); (ptr)->prev = (ptr); \
+} while (0)
+
+/*
+ * Insert a new entry between two known consecutive entries.
+ *
+ * This is only for internal list manipulation where we know
+ * the prev/next entries already!
+ */
+static inline void __list_add(struct list_head *new,
+			      struct list_head *prev,
+			      struct list_head *next)
+{
+	next->prev = new;
+	new->next = next;
+	new->prev = prev;
+	prev->next = new;
+}
+
+/**
+ * list_add - add a new entry
+ * @new: new entry to be added
+ * @head: list head to add it after
+ *
+ * Insert a new entry after the specified head.
+ * This is good for implementing stacks.
+ */
+static inline void list_add(struct list_head *new, struct list_head *head)
+{
+	__list_add(new, head, head->next);
+}
+
+/**
+ * list_add_tail - add a new entry
+ * @new: new entry to be added
+ * @head: list head to add it before
+ *
+ * Insert a new entry before the specified head.
+ * This is useful for implementing queues.
+ */
+static inline void list_add_tail(struct list_head *new, struct list_head *head)
+{
+	__list_add(new, head->prev, head);
+}
+
+/*
+ * Delete a list entry by making the prev/next entries
+ * point to each other.
+ *
+ * This is only for internal list manipulation where we know
+ * the prev/next entries already!
+ */
+static inline void __list_del(struct list_head * prev, struct list_head * next)
+{
+	next->prev = prev;
+	prev->next = next;
+}
+
+/**
+ * list_del - deletes entry from list.
+ * @entry: the element to delete from the list.
+ * Note: list_empty on entry does not return true after this, the entry is
+ * in an undefined state.
+ */
+static inline void list_del(struct list_head *entry)
+{
+	__list_del(entry->prev, entry->next);
+	entry->next = LIST_POISON1;
+	entry->prev = LIST_POISON2;
+}
+
+/**
+ * list_del_init - deletes entry from list and reinitialize it.
+ * @entry: the element to delete from the list.
+ */
+static inline void list_del_init(struct list_head *entry)
+{
+	__list_del(entry->prev, entry->next);
+	INIT_LIST_HEAD(entry);
+}
+
+/**
+ * list_move - delete from one list and add as another's head
+ * @list: the entry to move
+ * @head: the head that will precede our entry
+ */
+static inline void list_move(struct list_head *list, struct list_head *head)
+{
+        __list_del(list->prev, list->next);
+        list_add(list, head);
+}
+
+/**
+ * list_move_tail - delete from one list and add as another's tail
+ * @list: the entry to move
+ * @head: the head that will follow our entry
+ */
+static inline void list_move_tail(struct list_head *list,
+				  struct list_head *head)
+{
+        __list_del(list->prev, list->next);
+        list_add_tail(list, head);
+}
+
+/**
+ * list_empty - tests whether a list is empty
+ * @head: the list to test.
+ */
+static inline int list_empty(const struct list_head *head)
+{
+	return head->next == head;
+}
+
+/**
+ * list_empty_careful - tests whether a list is
+ * empty _and_ checks that no other CPU might be
+ * in the process of still modifying either member
+ *
+ * NOTE: using list_empty_careful() without synchronization
+ * can only be safe if the only activity that can happen
+ * to the list entry is list_del_init(). Eg. it cannot be used
+ * if another CPU could re-list_add() it.
+ *
+ * @head: the list to test.
+ */
+static inline int list_empty_careful(const struct list_head *head)
+{
+	struct list_head *next = head->next;
+	return (next == head) && (next == head->prev);
+}
+
+static inline void __list_splice(struct list_head *list,
+				 struct list_head *head)
+{
+	struct list_head *first = list->next;
+	struct list_head *last = list->prev;
+	struct list_head *at = head->next;
+
+	first->prev = head;
+	head->next = first;
+
+	last->next = at;
+	at->prev = last;
+}
+
+/**
+ * list_splice - join two lists
+ * @list: the new list to add.
+ * @head: the place to add it in the first list.
+ */
+static inline void list_splice(struct list_head *list, struct list_head *head)
+{
+	if (!list_empty(list))
+		__list_splice(list, head);
+}
+
+/**
+ * list_splice_init - join two lists and reinitialise the emptied list.
+ * @list: the new list to add.
+ * @head: the place to add it in the first list.
+ *
+ * The list at @list is reinitialised
+ */
+static inline void list_splice_init(struct list_head *list,
+				    struct list_head *head)
+{
+	if (!list_empty(list)) {
+		__list_splice(list, head);
+		INIT_LIST_HEAD(list);
+	}
+}
+
+/**
+ * list_entry - get the struct for this entry
+ * @ptr:	the &struct list_head pointer.
+ * @type:	the type of the struct this is embedded in.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_entry(ptr, type, member) \
+	container_of(ptr, type, member)
+
+/**
+ * list_for_each	-	iterate over a list
+ * @pos:	the &struct list_head to use as a loop counter.
+ * @head:	the head for your list.
+ */
+#define list_for_each(pos, head) \
+	for (pos = (head)->next, prefetch(pos->next); pos != (head); \
+        	pos = pos->next, prefetch(pos->next))
+
+/**
+ * __list_for_each	-	iterate over a list
+ * @pos:	the &struct list_head to use as a loop counter.
+ * @head:	the head for your list.
+ *
+ * This variant differs from list_for_each() in that it's the
+ * simplest possible list iteration code, no prefetching is done.
+ * Use this for code that knows the list to be very short (empty
+ * or 1 entry) most of the time.
+ */
+#define __list_for_each(pos, head) \
+	for (pos = (head)->next; pos != (head); pos = pos->next)
+
+/**
+ * list_for_each_prev	-	iterate over a list backwards
+ * @pos:	the &struct list_head to use as a loop counter.
+ * @head:	the head for your list.
+ */
+#define list_for_each_prev(pos, head) \
+	for (pos = (head)->prev, prefetch(pos->prev); pos != (head); \
+        	pos = pos->prev, prefetch(pos->prev))
+
+/**
+ * list_for_each_safe	-	iterate over a list safe against removal of list entry
+ * @pos:	the &struct list_head to use as a loop counter.
+ * @n:		another &struct list_head to use as temporary storage
+ * @head:	the head for your list.
+ */
+#define list_for_each_safe(pos, n, head) \
+	for (pos = (head)->next, n = pos->next; pos != (head); \
+		pos = n, n = pos->next)
+
+/**
+ * list_for_each_entry	-	iterate over list of given type
+ * @pos:	the type * to use as a loop counter.
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_for_each_entry(pos, head, member)				\
+	for (pos = list_entry((head)->next, typeof(*pos), member),	\
+		     prefetch(pos->member.next);			\
+	     &pos->member != (head); 					\
+	     pos = list_entry(pos->member.next, typeof(*pos), member),	\
+		     prefetch(pos->member.next))
+
+/**
+ * list_for_each_entry_reverse - iterate backwards over list of given type.
+ * @pos:	the type * to use as a loop counter.
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_for_each_entry_reverse(pos, head, member)			\
+	for (pos = list_entry((head)->prev, typeof(*pos), member),	\
+		     prefetch(pos->member.prev);			\
+	     &pos->member != (head); 					\
+	     pos = list_entry(pos->member.prev, typeof(*pos), member),	\
+		     prefetch(pos->member.prev))
+
+/**
+ * list_prepare_entry - prepare a pos entry for use as a start point in
+ *			list_for_each_entry_continue
+ * @pos:	the type * to use as a start point
+ * @head:	the head of the list
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_prepare_entry(pos, head, member) \
+	((pos) ? : list_entry(head, typeof(*pos), member))
+
+/**
+ * list_for_each_entry_continue -	iterate over list of given type
+ *			continuing after existing point
+ * @pos:	the type * to use as a loop counter.
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_for_each_entry_continue(pos, head, member) 		\
+	for (pos = list_entry(pos->member.next, typeof(*pos), member),	\
+		     prefetch(pos->member.next);			\
+	     &pos->member != (head);					\
+	     pos = list_entry(pos->member.next, typeof(*pos), member),	\
+		     prefetch(pos->member.next))
+
+/**
+ * list_for_each_entry_safe - iterate over list of given type safe against removal of list entry
+ * @pos:	the type * to use as a loop counter.
+ * @n:		another type * to use as temporary storage
+ * @head:	the head for your list.
+ * @member:	the name of the list_struct within the struct.
+ */
+#define list_for_each_entry_safe(pos, n, head, member)			\
+	for (pos = list_entry((head)->next, typeof(*pos), member),	\
+		n = list_entry(pos->member.next, typeof(*pos), member);	\
+	     &pos->member != (head); 					\
+	     pos = n, n = list_entry(n->member.next, typeof(*n), member))
+
+/*
+ * Double linked lists with a single pointer list head.
+ * Mostly useful for hash tables where the two pointer list head is
+ * too wasteful.
+ * You lose the ability to access the tail in O(1).
+ */
+
+struct hlist_head {
+	struct hlist_node *first;
+};
+
+struct hlist_node {
+	struct hlist_node *next, **pprev;
+};
+
+#define HLIST_HEAD_INIT { .first = NULL }
+#define HLIST_HEAD(name) struct hlist_head name = {  .first = NULL }
+#define INIT_HLIST_HEAD(ptr) ((ptr)->first = NULL)
+#define INIT_HLIST_NODE(ptr) ((ptr)->next = NULL, (ptr)->pprev = NULL)
+
+static inline int hlist_unhashed(const struct hlist_node *h)
+{
+	return !h->pprev;
+}
+
+static inline int hlist_empty(const struct hlist_head *h)
+{
+	return !h->first;
+}
+
+static inline void __hlist_del(struct hlist_node *n)
+{
+	struct hlist_node *next = n->next;
+	struct hlist_node **pprev = n->pprev;
+	*pprev = next;
+	if (next)
+		next->pprev = pprev;
+}
+
+static inline void hlist_del(struct hlist_node *n)
+{
+	__hlist_del(n);
+	n->next = LIST_POISON1;
+	n->pprev = LIST_POISON2;
+}
+
+static inline void hlist_del_init(struct hlist_node *n)
+{
+	if (n->pprev)  {
+		__hlist_del(n);
+		INIT_HLIST_NODE(n);
+	}
+}
+
+#define hlist_del_rcu_init hlist_del_init
+
+static inline void hlist_add_head(struct hlist_node *n, struct hlist_head *h)
+{
+	struct hlist_node *first = h->first;
+	n->next = first;
+	if (first)
+		first->pprev = &n->next;
+	h->first = n;
+	n->pprev = &h->first;
+}
+
+
+/* next must be != NULL */
+static inline void hlist_add_before(struct hlist_node *n,
+					struct hlist_node *next)
+{
+	n->pprev = next->pprev;
+	n->next = next;
+	next->pprev = &n->next;
+	*(n->pprev) = n;
+}
+
+static inline void hlist_add_after(struct hlist_node *n,
+					struct hlist_node *next)
+{
+	next->next = n->next;
+	n->next = next;
+	next->pprev = &n->next;
+
+	if(next->next)
+		next->next->pprev  = &next->next;
+}
+
+#define hlist_entry(ptr, type, member) container_of(ptr,type,member)
+
+#define hlist_for_each(pos, head) \
+	for (pos = (head)->first; pos && ({ prefetch(pos->next); 1; }); \
+	     pos = pos->next)
+
+#define hlist_for_each_safe(pos, n, head) \
+	for (pos = (head)->first; pos && ({ n = pos->next; 1; }); \
+	     pos = n)
+
+/**
+ * hlist_for_each_entry	- iterate over list of given type
+ * @tpos:	the type * to use as a loop counter.
+ * @pos:	the &struct hlist_node to use as a loop counter.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry(tpos, pos, head, member)			 \
+	for (pos = (head)->first;					 \
+	     pos && ({ prefetch(pos->next); 1;}) &&			 \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
+
+/**
+ * hlist_for_each_entry_continue - iterate over a hlist continuing after existing point
+ * @tpos:	the type * to use as a loop counter.
+ * @pos:	the &struct hlist_node to use as a loop counter.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry_continue(tpos, pos, member)		 \
+	for (pos = (pos)->next;						 \
+	     pos && ({ prefetch(pos->next); 1;}) &&			 \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
+
+/**
+ * hlist_for_each_entry_from - iterate over a hlist continuing from existing point
+ * @tpos:	the type * to use as a loop counter.
+ * @pos:	the &struct hlist_node to use as a loop counter.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry_from(tpos, pos, member)			 \
+	for (; pos && ({ prefetch(pos->next); 1;}) &&			 \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = pos->next)
+
+/**
+ * hlist_for_each_entry_safe - iterate over list of given type safe against removal of list entry
+ * @tpos:	the type * to use as a loop counter.
+ * @pos:	the &struct hlist_node to use as a loop counter.
+ * @n:		another &struct hlist_node to use as temporary storage
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ */
+#define hlist_for_each_entry_safe(tpos, pos, n, head, member) 		 \
+	for (pos = (head)->first;					 \
+	     pos && ({ n = pos->next; 1; }) && 				 \
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1;}); \
+	     pos = n)
+
+#endif
Index: util-linux-2.12p/sys-utils/rpcproxyd.8
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ util-linux-2.12p/sys-utils/rpcproxyd.8	2005-03-07 15:22:00.512890392 -0500
@@ -0,0 +1,28 @@
+.\" Copyright 2005 Mike Waychison (mike@waychison.com)
+.\" May be distributed under the GNU General Public License
+.TH RPCPROXYD 8 "2 March 2005" "Linux 0.99" "Linux Programmer's Manual"
+.SH NAME
+rpcproxyd \- daemon that proxies tcp / udp requests.
+.SH SYNOPSIS
+.nf
+.BR "rpcproxyd [ \-d | \-h ]"
+.fi
+.SH DESCRIPTION
+With no arguments,
+.B rpcproxyd
+daemonizes itself and listens on a unix socket for incoming clnt_proxy requests.
+
+There is no need to manually start the rpcproxyd service as it is started by a
+call to clntproxy_create().
+
+.SH OPTIONS
+.TP
+.B -d
+Run in the foreground with debug messages enabled.
+.TP
+.BI -h
+Print a usage message and quit.
+.SH AUTHORS
+.nf
+Originally by Mike Waychison (mike@waychison.com)
+.fi
Index: util-linux-2.12p/MCONFIG
===================================================================
--- util-linux-2.12p.orig/MCONFIG	2005-03-07 15:21:28.808710160 -0500
+++ util-linux-2.12p/MCONFIG	2005-03-07 15:22:00.512890392 -0500
@@ -179,6 +179,7 @@
 LOG_DIR=	/var/log
 MAN_DIR=	/usr/share/man
 INFO_DIR=	/usr/share/info
+RPCPROXY_DIR=	$(VAR_PATH)/run/rpcproxyd
 
 #
 # Paths used for install
@@ -202,6 +203,7 @@
 MAN6DIR=	$(MANDIR)/man6
 MAN8DIR=	$(MANDIR)/man8
 INFODIR=	$(DESTDIR)$(INFO_DIR)
+RPCPROXYDIR=	$(DESTDIR)$(RPCPROXY_DIR)
 
 # Directory for shutdown, halt, reboot, etc.
 SHUTDOWNDIR=	$(SBINDIR)
@@ -234,6 +236,7 @@
 			-DLOGDIR=\"$(LOG_DIR)\" \
 			-DVARPATH=\"$(VAR_PATH)\" \
 			-DLOCALEDIR=\"$(LOCALE_DIR)\" \
+			-DRPCPROXYDIR=\"$(RPCPROXY_DIR)\" \
 			$(CFLAGS)
 
 
------=_20050307155339_78816
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
autofs mailing list
autofs@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/autofs

------=_20050307155339_78816--
