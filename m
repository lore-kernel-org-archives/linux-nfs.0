Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33156 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727367AbeJDUVR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Oct 2018 16:21:17 -0400
Subject: [PATCH net-next] dns: Allow the dns resolver to retrieve a server
 set
From: David Howells <dhowells@redhat.com>
To: netdev@vger.kernel.org
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org
Date: Thu, 04 Oct 2018 14:27:55 +0100
Message-ID: <153865967530.25761.13226347009462917363.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Allow the DNS resolver to retrieve a set of servers and their associated
addresses, ports, preference and weight ratings.

In terms of communication with userspace, "srv=1" is added to the callout
string (the '1' indicating the maximum data version supported by the
kernel) to ask the userspace side for this.

If the userspace side doesn't recognise it, it will ignore the option and
return the usual text address list.

If the userspace side does recognise it, it will return some binary data
that begins with a zero byte that would cause the string parsers to give an
error.  The second byte contains the version of the data in the blob (this
may be between 1 and the version specified in the callout data).  The
remainder of the payload is version-specific.

In version 1, the payload looks like (note that this is packed):

	u8	Non-string marker (ie. 0)
	u8	Content (0 => Server list)
	u8	Version (ie. 1)
	u8	Source (eg. DNS_RECORD_FROM_DNS_SRV)
	u8	Status (eg. DNS_LOOKUP_GOOD)
	u8	Number of servers
	foreach-server {
		u16	Name length (LE)
		u16	Priority (as per SRV record) (LE)
		u16	Weight (as per SRV record) (LE)
		u16	Port (LE)
		u8	Source (eg. DNS_RECORD_FROM_NSS)
		u8	Status (eg. DNS_LOOKUP_GOT_NOT_FOUND)
		u8	Protocol (eg. DNS_SERVER_PROTOCOL_UDP)
		u8	Number of addresses
		char[]	Name (not NUL-terminated)
		foreach-address {
			u8		Family (AF_INET{,6})
			union {
				u8[4]	ipv4_addr
				u8[16]	ipv6_addr
			}
		}
	}

This can then be used to fetch a whole cell's VL-server configuration for
AFS, for example.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/dns_resolver.h      |    4 -
 include/uapi/linux/dns_resolver.h |  116 +++++++++++++++++++++++++++++++++++++
 net/dns_resolver/dns_key.c        |   67 ++++++++++++++++++++-
 net/dns_resolver/dns_query.c      |    5 --
 4 files changed, 182 insertions(+), 10 deletions(-)
 create mode 100644 include/uapi/linux/dns_resolver.h

diff --git a/include/linux/dns_resolver.h b/include/linux/dns_resolver.h
index 6ac3cad9aef1..34a744a1bafc 100644
--- a/include/linux/dns_resolver.h
+++ b/include/linux/dns_resolver.h
@@ -24,11 +24,9 @@
 #ifndef _LINUX_DNS_RESOLVER_H
 #define _LINUX_DNS_RESOLVER_H
 
-#ifdef __KERNEL__
+#include <uapi/linux/dns_resolver.h>
 
 extern int dns_query(const char *type, const char *name, size_t namelen,
 		     const char *options, char **_result, time64_t *_expiry);
 
-#endif /* KERNEL */
-
 #endif /* _LINUX_DNS_RESOLVER_H */
diff --git a/include/uapi/linux/dns_resolver.h b/include/uapi/linux/dns_resolver.h
new file mode 100644
index 000000000000..129745f9c794
--- /dev/null
+++ b/include/uapi/linux/dns_resolver.h
@@ -0,0 +1,116 @@
+/* SPDX-License-Identifier: GPL-2.0+ WITH Linux-syscall-note */
+/* DNS resolver interface definitions.
+ *
+ * Copyright (C) 2018 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#ifndef _UAPI_LINUX_DNS_RESOLVER_H
+#define _UAPI_LINUX_DNS_RESOLVER_H
+
+#include <linux/types.h>
+
+/*
+ * Type of payload.
+ */
+enum dns_payload_content_type {
+	DNS_PAYLOAD_IS_SERVER_LIST	= 0, /* List of servers, requested by srv=1 */
+};
+
+/*
+ * Type of address that might be found in an address record.
+ */
+enum dns_payload_address_type {
+	DNS_ADDRESS_IS_IPV4		= 0, /* 4-byte AF_INET address */
+	DNS_ADDRESS_IS_IPV6		= 1, /* 16-byte AF_INET6 address */
+};
+
+/*
+ * Type of protocol used to access a server.
+ */
+enum dns_payload_protocol_type {
+	DNS_SERVER_PROTOCOL_UNSPECIFIED	= 0,
+	DNS_SERVER_PROTOCOL_UDP		= 1, /* Use UDP to talk to the server */
+	DNS_SERVER_PROTOCOL_TCP		= 2, /* Use TCP to talk to the server */
+};
+
+/*
+ * Source of record included in DNS resolver payload.
+ */
+enum dns_record_source {
+	DNS_RECORD_UNAVAILABLE		= 0, /* No source available (empty record) */
+	DNS_RECORD_FROM_CONFIG		= 1, /* From local configuration data */
+	DNS_RECORD_FROM_DNS_A		= 2, /* From DNS A or AAAA record */
+	DNS_RECORD_FROM_DNS_AFSDB	= 3, /* From DNS AFSDB record */
+	DNS_RECORD_FROM_DNS_SRV		= 4, /* From DNS SRV record */
+	DNS_RECORD_FROM_NSS		= 5, /* From NSS */
+	NR__dns_record_source
+};
+
+/*
+ * Status of record included in DNS resolver payload.
+ */
+enum dns_lookup_status {
+	DNS_LOOKUP_NOT_DONE		= 0, /* No lookup has been made */
+	DNS_LOOKUP_GOOD			= 1, /* Good records obtained */
+	DNS_LOOKUP_GOOD_WITH_BAD	= 2, /* Good records, some decoding errors */
+	DNS_LOOKUP_BAD			= 3, /* Couldn't decode results */
+	DNS_LOOKUP_GOT_NOT_FOUND	= 4, /* Got a "Not Found" result */
+	DNS_LOOKUP_GOT_LOCAL_FAILURE	= 5, /* Local failure during lookup */
+	DNS_LOOKUP_GOT_TEMP_FAILURE	= 6, /* Temporary failure during lookup */
+	DNS_LOOKUP_GOT_NS_FAILURE	= 7, /* Name server failure */
+	NR__dns_lookup_status
+};
+
+/*
+ * Header at the beginning of binary format payload.
+ */
+struct dns_payload_header {
+	__u8		zero;		/* Zero byte: marks this as not being text */
+	__u8		content;	/* enum dns_payload_content_type */
+	__u8		version;	/* Encoding version */
+} __packed;
+
+/*
+ * Header at the beginning of a V1 server list.  This is followed directly by
+ * the server records.  Each server records begins with a struct of type
+ * dns_server_list_v1_server.
+ */
+struct dns_server_list_v1_header {
+	struct dns_payload_header hdr;
+	__u8		source;		/* enum dns_record_source */
+	__u8		status;		/* enum dns_lookup_status */
+	__u8		nr_servers;	/* Number of server records following this */
+} __packed;
+
+/*
+ * Header at the beginning of each V1 server record.  This is followed by the
+ * characters of the name with no NUL-terminator, followed by the address
+ * records for that server.  Each address record begins with a struct of type
+ * struct dns_server_list_v1_address.
+ */
+struct dns_server_list_v1_server {
+	__u16		name_len;	/* Length of name (LE) */
+	__u16		priority;	/* Priority (as SRV record) (LE) */
+	__u16		weight;		/* Weight (as SRV record) (LE) */
+	__u16		port;		/* UDP/TCP port number (LE) */
+	__u8		source;		/* enum dns_record_source */
+	__u8		status;		/* enum dns_lookup_status */
+	__u8		protocol;	/* enum dns_payload_protocol_type */
+	__u8		nr_addrs;
+} __packed;
+
+/*
+ * Header at the beginning of each V1 address record.  This is followed by the
+ * bytes of the address, 4 for IPV4 and 16 for IPV6.
+ */
+struct dns_server_list_v1_address {
+	__u8		address_type;	/* enum dns_payload_address_type */
+} __packed;
+
+#endif /* _UAPI_LINUX_DNS_RESOLVER_H */
diff --git a/net/dns_resolver/dns_key.c b/net/dns_resolver/dns_key.c
index 7f4534828f6c..a65d553e730d 100644
--- a/net/dns_resolver/dns_key.c
+++ b/net/dns_resolver/dns_key.c
@@ -29,6 +29,7 @@
 #include <linux/keyctl.h>
 #include <linux/err.h>
 #include <linux/seq_file.h>
+#include <linux/dns_resolver.h>
 #include <keys/dns_resolver-type.h>
 #include <keys/user-type.h>
 #include "internal.h"
@@ -48,27 +49,86 @@ const struct cred *dns_resolver_cache;
 /*
  * Preparse instantiation data for a dns_resolver key.
  *
- * The data must be a NUL-terminated string, with the NUL char accounted in
- * datalen.
+ * For normal hostname lookups, the data must be a NUL-terminated string, with
+ * the NUL char accounted in datalen.
  *
  * If the data contains a '#' characters, then we take the clause after each
  * one to be an option of the form 'key=value'.  The actual data of interest is
  * the string leading up to the first '#'.  For instance:
  *
  *        "ip1,ip2,...#foo=bar"
+ *
+ * For server list requests, the data must begin with a NUL char and be
+ * followed by a byte indicating the version of the data format.  Version 1
+ * looks something like (note this is packed):
+ *
+ *	u8      Non-string marker (ie. 0)
+ *	u8	Content (DNS_PAYLOAD_IS_*)
+ *	u8	Version (e.g. 1)
+ *	u8	Source of server list
+ *	u8	Lookup status of server list
+ *	u8	Number of servers
+ *	foreach-server {
+ *		__le16	Name length
+ *		__le16	Priority (as per SRV record, low first)
+ *		__le16	Weight (as per SRV record, higher first)
+ *		__le16	Port
+ *		u8	Source of address list
+ *		u8	Lookup status of address list
+ *		u8	Protocol (DNS_SERVER_PROTOCOL_*)
+ *		u8	Number of addresses
+ *		char[]	Name (not NUL-terminated)
+ *		foreach-address {
+ *			u8		Family (DNS_ADDRESS_IS_*)
+ *			union {
+ *				u8[4]	ipv4_addr
+ *				u8[16]	ipv6_addr
+ *			}
+ *		}
+ *	}
+ *
  */
 static int
 dns_resolver_preparse(struct key_preparsed_payload *prep)
 {
+	const struct dns_payload_header *bin;
 	struct user_key_payload *upayload;
 	unsigned long derrno;
 	int ret;
 	int datalen = prep->datalen, result_len = 0;
 	const char *data = prep->data, *end, *opt;
 
+	if (datalen <= 1 || !data)
+		return -EINVAL;
+
+	if (data[0] == 0) {
+		/* It may be a server list. */
+		if (datalen <= sizeof(*bin))
+			return -EINVAL;
+
+		bin = (const struct dns_payload_header *)data;
+		kenter("[%u,%u],%u", bin->content, bin->version, datalen);
+		if (bin->content != DNS_PAYLOAD_IS_SERVER_LIST) {
+			pr_warn_ratelimited(
+				"dns_resolver: Unsupported content type (%u)\n",
+				bin->content);
+			return -EINVAL;
+		}
+
+		if (bin->version != 1) {
+			pr_warn_ratelimited(
+				"dns_resolver: Unsupported server list version (%u)\n",
+				bin->version);
+			return -EINVAL;
+		}
+
+		result_len = datalen;
+		goto store_result;
+	}
+
 	kenter("'%*.*s',%u", datalen, datalen, data, datalen);
 
-	if (datalen <= 1 || !data || data[datalen - 1] != '\0')
+	if (!data || data[datalen - 1] != '\0')
 		return -EINVAL;
 	datalen--;
 
@@ -144,6 +204,7 @@ dns_resolver_preparse(struct key_preparsed_payload *prep)
 		return 0;
 	}
 
+store_result:
 	kdebug("store result");
 	prep->quotalen = result_len;
 
diff --git a/net/dns_resolver/dns_query.c b/net/dns_resolver/dns_query.c
index 49da67034f29..76338c38738a 100644
--- a/net/dns_resolver/dns_query.c
+++ b/net/dns_resolver/dns_query.c
@@ -148,12 +148,9 @@ int dns_query(const char *type, const char *name, size_t namelen,
 
 	if (_result) {
 		ret = -ENOMEM;
-		*_result = kmalloc(len + 1, GFP_KERNEL);
+		*_result = kmemdup_nul(upayload->data, len, GFP_KERNEL);
 		if (!*_result)
 			goto put;
-
-		memcpy(*_result, upayload->data, len);
-		(*_result)[len] = '\0';
 	}
 
 	if (_expiry)
