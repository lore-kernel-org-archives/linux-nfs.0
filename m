Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51700 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751650AbdH3L62 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Aug 2017 07:58:28 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id ED975495
        for <linux-nfs@vger.kernel.org>; Wed, 30 Aug 2017 11:58:27 +0000 (UTC)
Message-ID: <1504094305.10850.10.camel@redhat.com>
Subject: [PATCH 6/7] libnfsidmap: Use libnfsconf instead of builtin cfg
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 30 Aug 2017 12:58:25 +0100
In-Reply-To: <1504093866.10850.1.camel@redhat.com>
References: <1504093866.10850.1.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

libnfsidmap contained almost identical config parsing code to that in
nfs-utils which caused issues when that code got updated, it also
suffered from issues with parsing spaces in tag names which has been
fixed in nfs-utils, so solve both issues by removing the local config
parsing code and linking to the nfsconf shared library instead.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 Makefile.am   |  11 +-
 cfg.c         | 913 ----------------------------------------------------------
 cfg.h         |  68 -----
 configure.ac  |   3 +
 gums.c        |   2 +-
 libnfsidmap.c |   5 +-
 nss.c         |   2 +-
 queue.h       | 499 --------------------------------
 static.c      |   5 +-
 umich_ldap.c  |   2 +-
 10 files changed, 18 insertions(+), 1492 deletions(-)
 delete mode 100644 cfg.c
 delete mode 100644 cfg.h
 delete mode 100644 queue.h

diff --git a/Makefile.am b/Makefile.am
index 85f19c8..ffb6717 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -25,15 +25,18 @@ pkglib_LTLIBRARIES = nsswitch.la static.la $(UMICH_LDAP_LIB) $(GUMS_MAPPING_LIB)
 #  <age> 	The number of previous additional interfaces supported
 #  		by this library.
 
-libnfsidmap_la_SOURCES = libnfsidmap.c cfg.c strlcpy.c cfg.h nfsidmap_internal.h queue.h
+libnfsidmap_la_SOURCES = libnfsidmap.c strlcpy.c nfsidmap_internal.h queue.h
 libnfsidmap_la_LDFLAGS = -version-info 3:0:3
-libnfsidmap_la_LIBADD = -ldl
+libnfsidmap_la_LIBADD = -ldl $(NFSCONF_LIBS)
+libnfsidmap_la_CPPFLAGS = $(NFSCONF_CFLAGS)
 
 nsswitch_la_SOURCES = nss.c
-nsswitch_la_LDFLAGS = -module -avoid-version
+nsswitch_la_LDFLAGS = -module -avoid-version $(NFSCONF_LIBS)
+nsswitch_la_CPPFLAGS = $(NFSCONF_CFLAGS)
 
 static_la_SOURCES = static.c
-static_la_LDFLAGS = -module -avoid-version
+static_la_LDFLAGS = -module -avoid-version $(NFSCONF_LIBS)
+static_la_CPPFLAGS = $(NFSCONF_CFLAGS)
 
 umich_ldap_la_SOURCES = umich_ldap.c
 umich_ldap_la_LDFLAGS = -module -avoid-version
diff --git a/cfg.c b/cfg.c
deleted file mode 100644
index e0ab839..0000000
--- a/cfg.c
+++ /dev/null
@@ -1,913 +0,0 @@
-/*	$OpenBSD: conf.c,v 1.55 2003/06/03 14:28:16 ho Exp $	*/
-/*	$EOM: conf.c,v 1.48 2000/12/04 02:04:29 angelos Exp $	*/
-
-/*
- * Copyright (c) 1998, 1999, 2000, 2001 Niklas Hallqvist.  All rights reserved.
- * Copyright (c) 2000, 2001, 2002 H�kan Olsson.  All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- *
- * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
- * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
- * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
- * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
- * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
- * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
- * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- */
-
-/*
- * This code was written under funding by Ericsson Radio Systems.
- */
-
-#include <sys/param.h>
-#include <sys/mman.h>
-#include <sys/socket.h>
-#include <sys/stat.h>
-#include <netinet/in.h>
-#include <arpa/inet.h>
-#include <ctype.h>
-#include <fcntl.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
-#include <unistd.h>
-#include <errno.h>
-#include <err.h>
-
-#include "cfg.h"
-
-static void conf_load_defaults (int);
-#if 0
-static int conf_find_trans_xf (int, char *);
-#endif
-
-size_t  strlcpy(char *, const char *, size_t);
-
-struct conf_trans {
-  TAILQ_ENTRY (conf_trans) link;
-  int trans;
-  enum conf_op { CONF_SET, CONF_REMOVE, CONF_REMOVE_SECTION } op;
-  char *section;
-  char *tag;
-  char *value;
-  int override;
-  int is_default;
-};
-
-TAILQ_HEAD (conf_trans_head, conf_trans) conf_trans_queue;
-
-/*
- * Radix-64 Encoding.
- */
-const u_int8_t bin2asc[]
-  = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
-
-const u_int8_t asc2bin[] =
-{
-  255, 255, 255, 255, 255, 255, 255, 255,
-  255, 255, 255, 255, 255, 255, 255, 255,
-  255, 255, 255, 255, 255, 255, 255, 255,
-  255, 255, 255, 255, 255, 255, 255, 255,
-  255, 255, 255, 255, 255, 255, 255, 255,
-  255, 255, 255,  62, 255, 255, 255,  63,
-   52,  53,  54,  55,  56,  57,  58,  59,
-   60,  61, 255, 255, 255, 255, 255, 255,
-  255,   0,   1,   2,   3,   4,   5,   6,
-    7,   8,   9,  10,  11,  12,  13,  14,
-   15,  16,  17,  18,  19,  20,  21,  22,
-   23,  24,  25, 255, 255, 255, 255, 255,
-  255,  26,  27,  28,  29,  30,  31,  32,
-   33,  34,  35,  36,  37,  38,  39,  40,
-   41,  42,  43,  44,  45,  46,  47,  48,
-   49,  50,  51, 255, 255, 255, 255, 255
-};
-
-struct conf_binding {
-  LIST_ENTRY (conf_binding) link;
-  char *section;
-  char *tag;
-  char *value;
-  int is_default;
-};
-
-char *conf_path;
-LIST_HEAD (conf_bindings, conf_binding) conf_bindings[256];
-
-static char *conf_addr;
-
-static __inline__ u_int8_t
-conf_hash (char *s)
-{
-  u_int8_t hash = 0;
-
-  while (*s)
-    {
-      hash = ((hash << 1) | (hash >> 7)) ^ tolower (*s);
-      s++;
-    }
-  return hash;
-}
-
-/*
- * Insert a tag-value combination from LINE (the equal sign is at POS)
- */
-static int
-conf_remove_now (char *section, char *tag)
-{
-  struct conf_binding *cb, *next;
-
-  for (cb = LIST_FIRST (&conf_bindings[conf_hash (section)]); cb; cb = next)
-    {
-      next = LIST_NEXT (cb, link);
-      if (strcasecmp (cb->section, section) == 0
-	  && strcasecmp (cb->tag, tag) == 0)
-	{
-	  LIST_REMOVE (cb, link);
-	  warnx("[%s]:%s->%s removed", section, tag, cb->value);
-	  free (cb->section);
-	  free (cb->tag);
-	  free (cb->value);
-	  free (cb);
-	  return 0;
-	}
-    }
-  return 1;
-}
-
-static int
-conf_remove_section_now (char *section)
-{
-  struct conf_binding *cb, *next;
-  int unseen = 1;
-
-  for (cb = LIST_FIRST (&conf_bindings[conf_hash (section)]); cb; cb = next)
-    {
-      next = LIST_NEXT (cb, link);
-      if (strcasecmp (cb->section, section) == 0)
-	{
-	  unseen = 0;
-	  LIST_REMOVE (cb, link);
-	  warnx("[%s]:%s->%s removed", section, cb->tag, cb->value);
-	  free (cb->section);
-	  free (cb->tag);
-	  free (cb->value);
-	  free (cb);
-	}
-    }
-  return unseen;
-}
-
-/*
- * Insert a tag-value combination from LINE (the equal sign is at POS)
- * into SECTION of our configuration database.
- */
-static int
-conf_set_now (char *section, char *tag, char *value, int override,
-	      int is_default)
-{
-  struct conf_binding *node = 0;
-
-  if (override)
-    conf_remove_now (section, tag);
-  else if (conf_get_str (section, tag))
-    {
-      if (!is_default)
-	warnx("conf_set: duplicate tag [%s]:%s, ignoring...\n", section, tag);
-      return 1;
-    }
-
-  node = calloc (1, sizeof *node);
-  if (!node)
-    {
-      warnx("conf_set: calloc (1, %lu) failed", (unsigned long)sizeof *node);
-      return 1;
-    }
-  node->section = strdup (section);
-  node->tag = strdup (tag);
-  node->value = strdup (value);
-  node->is_default = is_default;
-
-  LIST_INSERT_HEAD (&conf_bindings[conf_hash (section)], node, link);
-  return 0;
-}
-
-/*
- * Parse the line LINE of SZ bytes.  Skip Comments, recognize section
- * headers and feed tag-value pairs into our configuration database.
- */
-static void
-conf_parse_line (int trans, char *line, size_t sz)
-{
-  char *val;
-  char *tag;
-  size_t i;
-  int j;
-  static char *section = 0;
-  static int ln = 0;
-
-  ln++;
-
-  /* Lines starting with '#' or ';' are comments.  */
-  if (*line == '#' || *line == ';')
-    return;
-
-  /* '[section]' parsing...  */
-  if (*line == '[')
-    {
-      for (i = 1; i < sz; i++)
-	if (line[i] == ']')
-	  break;
-      if (section)
-	free (section);
-      if (i == sz)
-	{
-	  warnx("conf_parse_line: %d:"
-		     "non-matched ']', ignoring until next section", ln);
-	  section = 0;
-	  return;
-	}
-      section = malloc (i);
-      if (!section)
-	{
-	  warnx("conf_parse_line: %d: malloc (%lu) failed", ln,
-		(unsigned long)i);
-	  return;
-	}
-      strlcpy (section, line + 1, i);
-      return;
-    }
-
-  /* Deal with assignments.  */
-  for (i = 0; i < sz; i++)
-    if (line[i] == '=')
-      {
-	/* If no section, we are ignoring the lines.  */
-	if (!section)
-	  {
-	    warnx("conf_parse_line: %d: ignoring line due to no section", ln);
-	    return;
-	  }
-	line[strcspn (line, " \t=")] = '\0';
-	val = line + i + 1 + strspn (line + i + 1, " \t");
-	/* Skip trailing whitespace, if any */
-	for (j = sz - (val - line) - 1; j > 0 && isspace (val[j]); j--)
-	  val[j] = '\0';
-
-	/* Skip beginning white space */
-	tag = line;
-	while (isspace(*tag))
-		tag++;
-
-	/* XXX Perhaps should we not ignore errors?  */
-	conf_set (trans, section, tag, val, 0, 0);
-	return;
-      }
-
-  /* Other non-empty lines are weird.  */
-  i = strspn (line, " \t");
-  if (line[i])
-    warnx("conf_parse_line: %d: syntax error", ln);
-
-  return;
-}
-
-/* Parse the mapped configuration file.  */
-static void
-conf_parse (int trans, char *buf, size_t sz)
-{
-  char *cp = buf;
-  char *bufend = buf + sz;
-  char *line;
-
-  line = cp;
-  while (cp < bufend)
-    {
-      if (*cp == '\n')
-	{
-	  /* Check for escaped newlines.  */
-	  if (cp > buf && *(cp - 1) == '\\')
-	    *(cp - 1) = *cp = ' ';
-	  else
-	    {
-	      *cp = '\0';
-	      conf_parse_line (trans, line, cp - line);
-	      line = cp + 1;
-	    }
-	}
-      cp++;
-    }
-  if (cp != line)
-    warnx("conf_parse: last line non-terminated, ignored.");
-}
-
-static void
-conf_load_defaults (int tr)
-{
-	/* No defaults */
-	return;
-}
-
-void
-conf_init (void)
-{
-  unsigned int i;
-
-  for (i = 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++)
-    LIST_INIT (&conf_bindings[i]);
-  TAILQ_INIT (&conf_trans_queue);
-  conf_reinit ();
-}
-
-/* Open the config file and map it into our address space, then parse it.  */
-void
-conf_reinit (void)
-{
-  struct conf_binding *cb = 0;
-  int fd, trans;
-  unsigned int i;
-  size_t sz;
-  char *new_conf_addr = 0;
-  struct stat sb;
-
-  if ((stat (conf_path, &sb) == 0) || (errno != ENOENT))
-    {
-      sz = sb.st_size;
-      fd = open (conf_path, O_RDONLY, 0);
-      if (fd == -1)
-        {
-	  warnx("conf_reinit: open (\"%s\", O_RDONLY) failed", conf_path);
-	  return;
-	}
-
-      new_conf_addr = malloc (sz);
-      if (!new_conf_addr)
-        {
-	  warnx("conf_reinit: malloc (%lu) failed", (unsigned long)sz);
-	  goto fail;
-	}
-
-      /* XXX I assume short reads won't happen here.  */
-      if (read (fd, new_conf_addr, sz) != (int)sz)
-        {
-	    warnx("conf_reinit: read (%d, %p, %lu) failed",
-		       fd, new_conf_addr, (unsigned long)sz);
-	    goto fail;
-	}
-      close (fd);
-
-      trans = conf_begin ();
-
-      /* XXX Should we not care about errors and rollback?  */
-      conf_parse (trans, new_conf_addr, sz);
-    }
-  else
-    trans = conf_begin ();
-
-  /* Load default configuration values.  */
-  conf_load_defaults (trans);
-
-  /* Free potential existing configuration.  */
-  if (conf_addr)
-    {
-      for (i = 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++)
-	for (cb = LIST_FIRST (&conf_bindings[i]); cb;
-	     cb = LIST_FIRST (&conf_bindings[i]))
-	  conf_remove_now (cb->section, cb->tag);
-      free (conf_addr);
-    }
-
-  conf_end (trans, 1);
-  conf_addr = new_conf_addr;
-  return;
-
- fail:
-  if (new_conf_addr)
-    free (new_conf_addr);
-  close (fd);
-}
-
-/*
- * Return the numeric value denoted by TAG in section SECTION or DEF
- * if that tag does not exist.
- */
-int
-conf_get_num (char *section, char *tag, int def)
-{
-  char *value = conf_get_str (section, tag);
-
-  if (value)
-      return atoi (value);
-  return def;
-}
-
-/* Validate X according to the range denoted by TAG in section SECTION.  */
-int
-conf_match_num (char *section, char *tag, int x)
-{
-  char *value = conf_get_str (section, tag);
-  int val, min, max, n;
-
-  if (!value)
-    return 0;
-  n = sscanf (value, "%d,%d:%d", &val, &min, &max);
-  switch (n)
-    {
-    case 1:
-      warnx("conf_match_num: %s:%s %d==%d?", section, tag, val, x);
-      return x == val;
-    case 3:
-      warnx("conf_match_num: %s:%s %d<=%d<=%d?", section, tag, min, x, max);
-      return min <= x && max >= x;
-    default:
-      warnx("conf_match_num: section %s tag %s: invalid number spec %s",
-		 section, tag, value);
-    }
-  return 0;
-}
-
-/* Return the string value denoted by TAG in section SECTION.  */
-char *
-conf_get_str (char *section, char *tag)
-{
-  struct conf_binding *cb;
-
-  for (cb = LIST_FIRST (&conf_bindings[conf_hash (section)]); cb;
-       cb = LIST_NEXT (cb, link))
-    if (strcasecmp (section, cb->section) == 0
-	&& strcasecmp (tag, cb->tag) == 0)
-      {
-	return cb->value;
-      }
-  return 0;
-}
-
-/* Return the string value denoted by TAG in section SECTION
-   returns DEF if not found .  */
-char *
-conf_get_str_with_def(char *section, char *tag, char *def)
-{
-  struct conf_binding *cb;
-
-  for (cb = LIST_FIRST (&conf_bindings[conf_hash (section)]); cb;
-       cb = LIST_NEXT (cb, link))
-    if (strcasecmp (section, cb->section) == 0
-	&& strcasecmp (tag, cb->tag) == 0)
-      {
-	return cb->value;
-      }
-  return def;
-}
-
-/*
- * Build a list of string values out of the comma separated value denoted by
- * TAG in SECTION.
- */
-struct conf_list *
-conf_get_list (char *section, char *tag)
-{
-  char *liststr = 0, *p, *field, *t;
-  struct conf_list *list = 0;
-  struct conf_list_node *node;
-
-  list = malloc (sizeof *list);
-  if (!list)
-    goto cleanup;
-  TAILQ_INIT (&list->fields);
-  list->cnt = 0;
-  liststr = conf_get_str (section, tag);
-  if (!liststr)
-    goto cleanup;
-  liststr = strdup (liststr);
-  if (!liststr)
-    goto cleanup;
-  p = liststr;
-  while ((field = strsep (&p, ",")) != NULL)
-    {
-      /* Skip leading whitespace */
-      while (isspace (*field))
-	field++;
-      /* Skip trailing whitespace */
-      if (p)
-	for (t = p - 1; t > field && isspace (*t); t--)
-	  *t = '\0';
-      if (*field == '\0')
-	{
-	  warnx("conf_get_list: empty field, ignoring...");
-	  continue;
-	}
-      list->cnt++;
-      node = calloc (1, sizeof *node);
-      if (!node)
-	goto cleanup;
-      node->field = strdup (field);
-      if (!node->field)
-	goto cleanup;
-      TAILQ_INSERT_TAIL (&list->fields, node, link);
-    }
-  free (liststr);
-  return list;
-
- cleanup:
-  if (list)
-    conf_free_list (list);
-  if (liststr)
-    free (liststr);
-  return 0;
-}
-
-struct conf_list *
-conf_get_tag_list (char *section)
-{
-  struct conf_list *list = 0;
-  struct conf_list_node *node;
-  struct conf_binding *cb;
-
-  list = malloc (sizeof *list);
-  if (!list)
-    goto cleanup;
-  TAILQ_INIT (&list->fields);
-  list->cnt = 0;
-  for (cb = LIST_FIRST (&conf_bindings[conf_hash (section)]); cb;
-       cb = LIST_NEXT (cb, link))
-    if (strcasecmp (section, cb->section) == 0)
-      {
-	list->cnt++;
-	node = calloc (1, sizeof *node);
-	if (!node)
-	  goto cleanup;
-	node->field = strdup (cb->tag);
-	if (!node->field)
-	  goto cleanup;
-	TAILQ_INSERT_TAIL (&list->fields, node, link);
-      }
-  return list;
-
- cleanup:
-  if (list)
-    conf_free_list (list);
-  return 0;
-}
-
-/* Decode a PEM encoded buffer.  */
-int
-conf_decode_base64 (u_int8_t *out, u_int32_t *len, u_char *buf)
-{
-  u_int32_t c = 0;
-  u_int8_t c1, c2, c3, c4;
-
-  while (*buf)
-    {
-      if (*buf > 127 || (c1 = asc2bin[*buf]) == 255)
-	return 0;
-      buf++;
-
-      if (*buf > 127 || (c2 = asc2bin[*buf]) == 255)
-	return 0;
-      buf++;
-
-      if (*buf == '=')
-	{
-	  c3 = c4 = 0;
-	  c++;
-
-	  /* Check last four bit */
-	  if (c2 & 0xF)
-	    return 0;
-
-	  if (strcmp ((char *)buf, "==") == 0)
-	    buf++;
-	  else
-	    return 0;
-	}
-      else if (*buf > 127 || (c3 = asc2bin[*buf]) == 255)
-	return 0;
-      else
-	{
-	  if (*++buf == '=')
-	    {
-	      c4 = 0;
-	      c += 2;
-
-	      /* Check last two bit */
-	      if (c3 & 3)
-		return 0;
-
-	      if (strcmp ((char *)buf, "="))
-		return 0;
-
-	    }
-	  else if (*buf > 127 || (c4 = asc2bin[*buf]) == 255)
-	      return 0;
-	  else
-	      c += 3;
-	}
-
-      buf++;
-      *out++ = (c1 << 2) | (c2 >> 4);
-      *out++ = (c2 << 4) | (c3 >> 2);
-      *out++ = (c3 << 6) | c4;
-    }
-
-  *len = c;
-  return 1;
-
-}
-
-void
-conf_free_list (struct conf_list *list)
-{
-  struct conf_list_node *node = TAILQ_FIRST (&list->fields);
-
-  while (node)
-    {
-      TAILQ_REMOVE (&list->fields, node, link);
-      if (node->field)
-	free (node->field);
-      free (node);
-      node = TAILQ_FIRST (&list->fields);
-    }
-  free (list);
-}
-
-int
-conf_begin (void)
-{
-  static int seq = 0;
-
-  return ++seq;
-}
-
-static struct conf_trans *
-conf_trans_node (int transaction, enum conf_op op)
-{
-  struct conf_trans *node;
-
-  node = calloc (1, sizeof *node);
-  if (!node)
-    {
-      warnx("conf_trans_node: calloc (1, %lu) failed",
-	(unsigned long)sizeof *node);
-      return 0;
-    }
-  node->trans = transaction;
-  node->op = op;
-  TAILQ_INSERT_TAIL (&conf_trans_queue, node, link);
-  return node;
-}
-
-/* Queue a set operation.  */
-int
-conf_set (int transaction, char *section, char *tag, char *value, int override,
-	  int is_default)
-{
-  struct conf_trans *node;
-
-  node = conf_trans_node (transaction, CONF_SET);
-  if (!node)
-    return 1;
-  node->section = strdup (section);
-  if (!node->section)
-    {
-      warnx("conf_set: strdup (\"%s\") failed", section);
-      goto fail;
-    }
-  node->tag = strdup (tag);
-  if (!node->tag)
-    {
-      warnx("conf_set: strdup (\"%s\") failed", tag);
-      goto fail;
-    }
-  node->value = strdup (value);
-  if (!node->value)
-    {
-      warnx("conf_set: strdup (\"%s\") failed", value);
-      goto fail;
-    }
-  node->override = override;
-  node->is_default = is_default;
-  return 0;
-
- fail:
-  if (node->tag)
-    free (node->tag);
-  if (node->section)
-    free (node->section);
-  if (node)
-    free (node);
-  return 1;
-}
-
-/* Queue a remove operation.  */
-int
-conf_remove (int transaction, char *section, char *tag)
-{
-  struct conf_trans *node;
-
-  node = conf_trans_node (transaction, CONF_REMOVE);
-  if (!node)
-    goto fail;
-  node->section = strdup (section);
-  if (!node->section)
-    {
-      warnx("conf_remove: strdup (\"%s\") failed", section);
-      goto fail;
-    }
-  node->tag = strdup (tag);
-  if (!node->tag)
-    {
-      warnx("conf_remove: strdup (\"%s\") failed", tag);
-      goto fail;
-    }
-  return 0;
-
- fail:
-  if (node->section)
-    free (node->section);
-  if (node)
-    free (node);
-  return 1;
-}
-
-/* Queue a remove section operation.  */
-int
-conf_remove_section (int transaction, char *section)
-{
-  struct conf_trans *node;
-
-  node = conf_trans_node (transaction, CONF_REMOVE_SECTION);
-  if (!node)
-    goto fail;
-  node->section = strdup (section);
-  if (!node->section)
-    {
-      warnx("conf_remove_section: strdup (\"%s\") failed", section);
-      goto fail;
-    }
-  return 0;
-
- fail:
-  if (node)
-    free (node);
-  return 1;
-}
-
-/* Execute all queued operations for this transaction.  Cleanup.  */
-int
-conf_end (int transaction, int commit)
-{
-  struct conf_trans *node, *next;
-
-  for (node = TAILQ_FIRST (&conf_trans_queue); node; node = next)
-    {
-      next = TAILQ_NEXT (node, link);
-      if (node->trans == transaction)
-	{
-	  if (commit)
-	    switch (node->op)
-	      {
-	      case CONF_SET:
-		conf_set_now (node->section, node->tag, node->value,
-			      node->override, node->is_default);
-		break;
-	      case CONF_REMOVE:
-		conf_remove_now (node->section, node->tag);
-		break;
-	      case CONF_REMOVE_SECTION:
-		conf_remove_section_now (node->section);
-		break;
-	      default:
-		warnx("conf_end: unknown operation: %d", node->op);
-	      }
-	  TAILQ_REMOVE (&conf_trans_queue, node, link);
-	  if (node->section)
-	    free (node->section);
-	  if (node->tag)
-	    free (node->tag);
-	  if (node->value)
-	    free (node->value);
-	  free (node);
-	}
-    }
-  return 0;
-}
-
-/*
- * Dump running configuration upon SIGUSR1.
- * Configuration is "stored in reverse order", so reverse it again.
- */
-struct dumper {
-  char *s, *v;
-  struct dumper *next;
-};
-
-static void
-conf_report_dump (struct dumper *node)
-{
-  /* Recursive, cleanup when we're done.  */
-
-  if (node->next)
-    conf_report_dump (node->next);
-
-  if (node->v)
-    warnx("%s=\t%s", node->s, node->v);
-  else if (node->s)
-    {
-      warnx("%s", node->s);
-      if (strlen (node->s) > 0)
-	free (node->s);
-    }
-
-  free (node);
-}
-
-void
-conf_report (void)
-{
-  struct conf_binding *cb, *last = 0;
-  unsigned int i, len;
-  char *current_section = (char *)0;
-  struct dumper *dumper, *dnode;
-
-  dumper = dnode = (struct dumper *)calloc (1, sizeof *dumper);
-  if (!dumper)
-    goto mem_fail;
-
-  warnx("conf_report: dumping running configuration");
-
-  for (i = 0; i < sizeof conf_bindings / sizeof conf_bindings[0]; i++)
-    for (cb = LIST_FIRST (&conf_bindings[i]); cb;
-	 cb = LIST_NEXT (cb, link))
-      {
-	if (!cb->is_default)
-	  {
-	    /* Dump this entry.  */
-	    if (!current_section || strcmp (cb->section, current_section))
-	      {
-		if (current_section)
-		  {
-		    len = strlen (current_section) + 3;
-		    dnode->s = malloc (len);
-		    if (!dnode->s)
-		      goto mem_fail;
-
-		    snprintf (dnode->s, len, "[%s]", current_section);
-		    dnode->next
-		      = (struct dumper *)calloc (1, sizeof (struct dumper));
-		    dnode = dnode->next;
-		    if (!dnode)
-		      goto mem_fail;
-
-		    dnode->s = "";
-		    dnode->next
-		      = (struct dumper *)calloc (1, sizeof (struct dumper));
-		    dnode = dnode->next;
-		    if (!dnode)
-		      goto mem_fail;
-		  }
-		current_section = cb->section;
-	      }
-	    dnode->s = cb->tag;
-	    dnode->v = cb->value;
-	    dnode->next = (struct dumper *)calloc (1, sizeof (struct dumper));
-	    dnode = dnode->next;
-	    if (!dnode)
-	      goto mem_fail;
-	    last = cb;
-	  }
-      }
-
-  if (last)
-    {
-      len = strlen (last->section) + 3;
-      dnode->s = malloc (len);
-      if (!dnode->s)
-	goto mem_fail;
-      snprintf (dnode->s, len, "[%s]", last->section);
-    }
-
-  conf_report_dump (dumper);
-
-  return;
-
- mem_fail:
-  warnx("conf_report: malloc/calloc failed");
-  while ((dnode = dumper) != 0)
-    {
-      dumper = dumper->next;
-      if (dnode->s)
-	free (dnode->s);
-      free (dnode);
-    }
-  return;
-}
diff --git a/cfg.h b/cfg.h
deleted file mode 100644
index d4d4cab..0000000
--- a/cfg.h
+++ /dev/null
@@ -1,68 +0,0 @@
-/* $OpenBSD: conf.h,v 1.30 2004/06/25 20:25:34 hshoexer Exp $	 */
-/* $EOM: conf.h,v 1.13 2000/09/18 00:01:47 ho Exp $	 */
-
-/*
- * Copyright (c) 1998, 1999, 2001 Niklas Hallqvist.  All rights reserved.
- * Copyright (c) 2000, 2003 H�kan Olsson.  All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- *
- * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
- * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
- * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
- * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
- * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
- * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
- * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- */
-
-/*
- * This code was written under funding by Ericsson Radio Systems.
- */
-
-#ifndef _CONF_H_
-#define _CONF_H_
-
-#include "queue.h"
-
-struct conf_list_node {
-	TAILQ_ENTRY(conf_list_node) link;
-	char	*field;
-};
-
-struct conf_list {
-	size_t	cnt;
-	TAILQ_HEAD(conf_list_fields_head, conf_list_node) fields;
-};
-
-extern char    *conf_path;
-
-extern int      conf_begin(void);
-extern int      conf_decode_base64(u_int8_t *, u_int32_t *, u_char *);
-extern int      conf_end(int, int);
-extern void     conf_free_list(struct conf_list *);
-extern struct sockaddr *conf_get_address(char *, char *);
-extern struct conf_list *conf_get_list(char *, char *);
-extern struct conf_list *conf_get_tag_list(char *);
-extern int      conf_get_num(char *, char *, int);
-extern char    *conf_get_str(char *, char *);
-extern char    *conf_get_str_with_def(char *, char *, char*);
-extern void     conf_init(void);
-extern int      conf_match_num(char *, char *, int);
-extern void     conf_reinit(void);
-extern int      conf_remove(int, char *, char *);
-extern int      conf_remove_section(int, char *);
-extern int      conf_set(int, char *, char *, char *, int, int);
-extern void     conf_report(void);
-
-#endif				/* _CONF_H_ */
diff --git a/configure.ac b/configure.ac
index dd1b365..35445bc 100644
--- a/configure.ac
+++ b/configure.ac
@@ -52,6 +52,9 @@ if test -n "$path_plugins" ; then
 fi
 AM_CONDITIONAL(PATH_PLUGINS, test -n "$path_plugins")
 
+# where is nfsconf library
+PKG_CHECK_MODULES(NFSCONF, libnfsconf)
+
 AC_CONFIG_HEADERS([./config.h])
 # Checks for header files.
 AC_HEADER_STDC
diff --git a/gums.c b/gums.c
index 2b12d95..5c16dd0 100644
--- a/gums.c
+++ b/gums.c
@@ -43,7 +43,7 @@
 #include <syslog.h>
 #include "nfsidmap.h"
 #include "nfsidmap_internal.h"
-#include "cfg.h"
+#include <conffile.h>
 
 #include <voms_apic.h>
 
diff --git a/libnfsidmap.c b/libnfsidmap.c
index d484101..afe84ef 100644
--- a/libnfsidmap.c
+++ b/libnfsidmap.c
@@ -59,7 +59,7 @@
 
 #include "nfsidmap.h"
 #include "nfsidmap_internal.h"
-#include "cfg.h"
+#include <conffile.h>
 
 static char *default_domain;
 static struct conf_list *local_realms;
@@ -340,6 +340,7 @@ int nfs4_init_name_mapping(char *conffile)
 	char *nobody_user, *nobody_group;
 	char *nostrip;
 	char *reformatgroup;
+	char *conf_path;
 
 	/* XXX: need to be able to reload configurations... */
 	if (nfs4_plugins) /* already succesfully initialized */
@@ -348,7 +349,7 @@ int nfs4_init_name_mapping(char *conffile)
 		conf_path = conffile;
 	else
 		conf_path = PATH_IDMAPDCONF;
-	conf_init();
+	conf_init(conf_path);
 	default_domain = conf_get_str("General", "Domain");
 	if (default_domain == NULL) {
 		dflt = 1;
diff --git a/nss.c b/nss.c
index 82799ce..6c090bc 100644
--- a/nss.c
+++ b/nss.c
@@ -48,7 +48,7 @@
 #include <ctype.h>
 #include "nfsidmap.h"
 #include "nfsidmap_internal.h"
-#include "cfg.h"
+#include <conffile.h>
 #include <syslog.h>
 
 /*
diff --git a/queue.h b/queue.h
deleted file mode 100644
index 2823fe7..0000000
--- a/queue.h
+++ /dev/null
@@ -1,499 +0,0 @@
-/*	$OpenBSD: queue.h,v 1.22 2001/06/23 04:39:35 angelos Exp $	*/
-/*	$NetBSD: queue.h,v 1.11 1996/05/16 05:17:14 mycroft Exp $	*/
-
-/*
- * Copyright (c) 1991, 1993
- *	The Regents of the University of California.  All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. Neither the name of the University nor the names of its contributors
- *    may be used to endorse or promote products derived from this software
- *    without specific prior written permission.
- *
- * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
- * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
- * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
- * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
- * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
- * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
- * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
- * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
- * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
- * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
- * SUCH DAMAGE.
- *
- *	@(#)queue.h	8.5 (Berkeley) 8/20/94
- */
-
-#ifndef	_SYS_QUEUE_H_
-#define	_SYS_QUEUE_H_
-
-/*
- * This file defines five types of data structures: singly-linked lists,
- * lists, simple queues, tail queues, and circular queues.
- *
- *
- * A singly-linked list is headed by a single forward pointer. The elements
- * are singly linked for minimum space and pointer manipulation overhead at
- * the expense of O(n) removal for arbitrary elements. New elements can be
- * added to the list after an existing element or at the head of the list.
- * Elements being removed from the head of the list should use the explicit
- * macro for this purpose for optimum efficiency. A singly-linked list may
- * only be traversed in the forward direction.  Singly-linked lists are ideal
- * for applications with large datasets and few or no removals or for
- * implementing a LIFO queue.
- *
- * A list is headed by a single forward pointer (or an array of forward
- * pointers for a hash table header). The elements are doubly linked
- * so that an arbitrary element can be removed without a need to
- * traverse the list. New elements can be added to the list before
- * or after an existing element or at the head of the list. A list
- * may only be traversed in the forward direction.
- *
- * A simple queue is headed by a pair of pointers, one the head of the
- * list and the other to the tail of the list. The elements are singly
- * linked to save space, so elements can only be removed from the
- * head of the list. New elements can be added to the list before or after
- * an existing element, at the head of the list, or at the end of the
- * list. A simple queue may only be traversed in the forward direction.
- *
- * A tail queue is headed by a pair of pointers, one to the head of the
- * list and the other to the tail of the list. The elements are doubly
- * linked so that an arbitrary element can be removed without a need to
- * traverse the list. New elements can be added to the list before or
- * after an existing element, at the head of the list, or at the end of
- * the list. A tail queue may be traversed in either direction.
- *
- * A circle queue is headed by a pair of pointers, one to the head of the
- * list and the other to the tail of the list. The elements are doubly
- * linked so that an arbitrary element can be removed without a need to
- * traverse the list. New elements can be added to the list before or after
- * an existing element, at the head of the list, or at the end of the list.
- * A circle queue may be traversed in either direction, but has a more
- * complex end of list detection.
- *
- * For details on the use of these macros, see the queue(3) manual page.
- */
-
-/*
- * Singly-linked List definitions.
- */
-#define SLIST_HEAD(name, type)						\
-struct name {								\
-	struct type *slh_first;	/* first element */			\
-}
-
-#define	SLIST_HEAD_INITIALIZER(head)					\
-	{ NULL }
-
-#define SLIST_ENTRY(type)						\
-struct {								\
-	struct type *sle_next;	/* next element */			\
-}
-
-/*
- * Singly-linked List access methods.
- */
-#define	SLIST_FIRST(head)	((head)->slh_first)
-#define	SLIST_END(head)		NULL
-#define	SLIST_EMPTY(head)	(SLIST_FIRST(head) == SLIST_END(head))
-#define	SLIST_NEXT(elm, field)	((elm)->field.sle_next)
-
-#define	SLIST_FOREACH(var, head, field)					\
-	for((var) = SLIST_FIRST(head);					\
-	    (var) != SLIST_END(head);					\
-	    (var) = SLIST_NEXT(var, field))
-
-/*
- * Singly-linked List functions.
- */
-#define	SLIST_INIT(head) {						\
-	SLIST_FIRST(head) = SLIST_END(head);				\
-}
-
-#define	SLIST_INSERT_AFTER(slistelm, elm, field) do {			\
-	(elm)->field.sle_next = (slistelm)->field.sle_next;		\
-	(slistelm)->field.sle_next = (elm);				\
-} while (0)
-
-#define	SLIST_INSERT_HEAD(head, elm, field) do {			\
-	(elm)->field.sle_next = (head)->slh_first;			\
-	(head)->slh_first = (elm);					\
-} while (0)
-
-#define	SLIST_REMOVE_HEAD(head, field) do {				\
-	(head)->slh_first = (head)->slh_first->field.sle_next;		\
-} while (0)
-
-#define SLIST_REMOVE(head, elm, type, field) do {			\
-	if ((head)->slh_first == (elm)) {				\
-		SLIST_REMOVE_HEAD((head), field);			\
-	}								\
-	else {								\
-		struct type *curelm = (head)->slh_first;		\
-		while( curelm->field.sle_next != (elm) )		\
-			curelm = curelm->field.sle_next;		\
-		curelm->field.sle_next =				\
-		    curelm->field.sle_next->field.sle_next;		\
-	}								\
-} while (0)
-
-/*
- * List definitions.
- */
-#define LIST_HEAD(name, type)						\
-struct name {								\
-	struct type *lh_first;	/* first element */			\
-}
-
-#define LIST_HEAD_INITIALIZER(head)					\
-	{ NULL }
-
-#define LIST_ENTRY(type)						\
-struct {								\
-	struct type *le_next;	/* next element */			\
-	struct type **le_prev;	/* address of previous next element */	\
-}
-
-/*
- * List access methods
- */
-#define	LIST_FIRST(head)		((head)->lh_first)
-#define	LIST_END(head)			NULL
-#define	LIST_EMPTY(head)		(LIST_FIRST(head) == LIST_END(head))
-#define	LIST_NEXT(elm, field)		((elm)->field.le_next)
-
-#define LIST_FOREACH(var, head, field)					\
-	for((var) = LIST_FIRST(head);					\
-	    (var)!= LIST_END(head);					\
-	    (var) = LIST_NEXT(var, field))
-
-/*
- * List functions.
- */
-#define	LIST_INIT(head) do {						\
-	LIST_FIRST(head) = LIST_END(head);				\
-} while (0)
-
-#define LIST_INSERT_AFTER(listelm, elm, field) do {			\
-	if (((elm)->field.le_next = (listelm)->field.le_next) != NULL)	\
-		(listelm)->field.le_next->field.le_prev =		\
-		    &(elm)->field.le_next;				\
-	(listelm)->field.le_next = (elm);				\
-	(elm)->field.le_prev = &(listelm)->field.le_next;		\
-} while (0)
-
-#define	LIST_INSERT_BEFORE(listelm, elm, field) do {			\
-	(elm)->field.le_prev = (listelm)->field.le_prev;		\
-	(elm)->field.le_next = (listelm);				\
-	*(listelm)->field.le_prev = (elm);				\
-	(listelm)->field.le_prev = &(elm)->field.le_next;		\
-} while (0)
-
-#define LIST_INSERT_HEAD(head, elm, field) do {				\
-	if (((elm)->field.le_next = (head)->lh_first) != NULL)		\
-		(head)->lh_first->field.le_prev = &(elm)->field.le_next;\
-	(head)->lh_first = (elm);					\
-	(elm)->field.le_prev = &(head)->lh_first;			\
-} while (0)
-
-#define LIST_REMOVE(elm, field) do {					\
-	if ((elm)->field.le_next != NULL)				\
-		(elm)->field.le_next->field.le_prev =			\
-		    (elm)->field.le_prev;				\
-	*(elm)->field.le_prev = (elm)->field.le_next;			\
-} while (0)
-
-#define LIST_REPLACE(elm, elm2, field) do {				\
-	if (((elm2)->field.le_next = (elm)->field.le_next) != NULL)	\
-		(elm2)->field.le_next->field.le_prev =			\
-		    &(elm2)->field.le_next;				\
-	(elm2)->field.le_prev = (elm)->field.le_prev;			\
-	*(elm2)->field.le_prev = (elm2);				\
-} while (0)
-
-/*
- * Simple queue definitions.
- */
-#define SIMPLEQ_HEAD(name, type)					\
-struct name {								\
-	struct type *sqh_first;	/* first element */			\
-	struct type **sqh_last;	/* addr of last next element */		\
-}
-
-#define SIMPLEQ_HEAD_INITIALIZER(head)					\
-	{ NULL, &(head).sqh_first }
-
-#define SIMPLEQ_ENTRY(type)						\
-struct {								\
-	struct type *sqe_next;	/* next element */			\
-}
-
-/*
- * Simple queue access methods.
- */
-#define	SIMPLEQ_FIRST(head)	    ((head)->sqh_first)
-#define	SIMPLEQ_END(head)	    NULL
-#define	SIMPLEQ_EMPTY(head)	    (SIMPLEQ_FIRST(head) == SIMPLEQ_END(head))
-#define	SIMPLEQ_NEXT(elm, field)    ((elm)->field.sqe_next)
-
-#define SIMPLEQ_FOREACH(var, head, field)				\
-	for((var) = SIMPLEQ_FIRST(head);				\
-	    (var) != SIMPLEQ_END(head);					\
-	    (var) = SIMPLEQ_NEXT(var, field))
-
-/*
- * Simple queue functions.
- */
-#define	SIMPLEQ_INIT(head) do {						\
-	(head)->sqh_first = NULL;					\
-	(head)->sqh_last = &(head)->sqh_first;				\
-} while (0)
-
-#define SIMPLEQ_INSERT_HEAD(head, elm, field) do {			\
-	if (((elm)->field.sqe_next = (head)->sqh_first) == NULL)	\
-		(head)->sqh_last = &(elm)->field.sqe_next;		\
-	(head)->sqh_first = (elm);					\
-} while (0)
-
-#define SIMPLEQ_INSERT_TAIL(head, elm, field) do {			\
-	(elm)->field.sqe_next = NULL;					\
-	*(head)->sqh_last = (elm);					\
-	(head)->sqh_last = &(elm)->field.sqe_next;			\
-} while (0)
-
-#define SIMPLEQ_INSERT_AFTER(head, listelm, elm, field) do {		\
-	if (((elm)->field.sqe_next = (listelm)->field.sqe_next) == NULL)\
-		(head)->sqh_last = &(elm)->field.sqe_next;		\
-	(listelm)->field.sqe_next = (elm);				\
-} while (0)
-
-#define SIMPLEQ_REMOVE_HEAD(head, elm, field) do {			\
-	if (((head)->sqh_first = (elm)->field.sqe_next) == NULL)	\
-		(head)->sqh_last = &(head)->sqh_first;			\
-} while (0)
-
-/*
- * Tail queue definitions.
- */
-#define TAILQ_HEAD(name, type)						\
-struct name {								\
-	struct type *tqh_first;	/* first element */			\
-	struct type **tqh_last;	/* addr of last next element */		\
-}
-
-#define TAILQ_HEAD_INITIALIZER(head)					\
-	{ NULL, &(head).tqh_first }
-
-#define TAILQ_ENTRY(type)						\
-struct {								\
-	struct type *tqe_next;	/* next element */			\
-	struct type **tqe_prev;	/* address of previous next element */	\
-}
-
-/*
- * tail queue access methods
- */
-#define	TAILQ_FIRST(head)		((head)->tqh_first)
-#define	TAILQ_END(head)			NULL
-#define	TAILQ_NEXT(elm, field)		((elm)->field.tqe_next)
-#define TAILQ_LAST(head, headname)					\
-	(*(((struct headname *)((head)->tqh_last))->tqh_last))
-/* XXX */
-#define TAILQ_PREV(elm, headname, field)				\
-	(*(((struct headname *)((elm)->field.tqe_prev))->tqh_last))
-#define	TAILQ_EMPTY(head)						\
-	(TAILQ_FIRST(head) == TAILQ_END(head))
-
-#define TAILQ_FOREACH(var, head, field)					\
-	for((var) = TAILQ_FIRST(head);					\
-	    (var) != TAILQ_END(head);					\
-	    (var) = TAILQ_NEXT(var, field))
-
-#define TAILQ_FOREACH_REVERSE(var, head, field, headname)		\
-	for((var) = TAILQ_LAST(head, headname);				\
-	    (var) != TAILQ_END(head);					\
-	    (var) = TAILQ_PREV(var, headname, field))
-
-/*
- * Tail queue functions.
- */
-#define	TAILQ_INIT(head) do {						\
-	(head)->tqh_first = NULL;					\
-	(head)->tqh_last = &(head)->tqh_first;				\
-} while (0)
-
-#define TAILQ_INSERT_HEAD(head, elm, field) do {			\
-	if (((elm)->field.tqe_next = (head)->tqh_first) != NULL)	\
-		(head)->tqh_first->field.tqe_prev =			\
-		    &(elm)->field.tqe_next;				\
-	else								\
-		(head)->tqh_last = &(elm)->field.tqe_next;		\
-	(head)->tqh_first = (elm);					\
-	(elm)->field.tqe_prev = &(head)->tqh_first;			\
-} while (0)
-
-#define TAILQ_INSERT_TAIL(head, elm, field) do {			\
-	(elm)->field.tqe_next = NULL;					\
-	(elm)->field.tqe_prev = (head)->tqh_last;			\
-	*(head)->tqh_last = (elm);					\
-	(head)->tqh_last = &(elm)->field.tqe_next;			\
-} while (0)
-
-#define TAILQ_INSERT_AFTER(head, listelm, elm, field) do {		\
-	if (((elm)->field.tqe_next = (listelm)->field.tqe_next) != NULL)\
-		(elm)->field.tqe_next->field.tqe_prev =			\
-		    &(elm)->field.tqe_next;				\
-	else								\
-		(head)->tqh_last = &(elm)->field.tqe_next;		\
-	(listelm)->field.tqe_next = (elm);				\
-	(elm)->field.tqe_prev = &(listelm)->field.tqe_next;		\
-} while (0)
-
-#define	TAILQ_INSERT_BEFORE(listelm, elm, field) do {			\
-	(elm)->field.tqe_prev = (listelm)->field.tqe_prev;		\
-	(elm)->field.tqe_next = (listelm);				\
-	*(listelm)->field.tqe_prev = (elm);				\
-	(listelm)->field.tqe_prev = &(elm)->field.tqe_next;		\
-} while (0)
-
-#define TAILQ_REMOVE(head, elm, field) do {				\
-	if (((elm)->field.tqe_next) != NULL)				\
-		(elm)->field.tqe_next->field.tqe_prev =			\
-		    (elm)->field.tqe_prev;				\
-	else								\
-		(head)->tqh_last = (elm)->field.tqe_prev;		\
-	*(elm)->field.tqe_prev = (elm)->field.tqe_next;			\
-} while (0)
-
-#define TAILQ_REPLACE(head, elm, elm2, field) do {			\
-	if (((elm2)->field.tqe_next = (elm)->field.tqe_next) != NULL)	\
-		(elm2)->field.tqe_next->field.tqe_prev =		\
-		    &(elm2)->field.tqe_next;				\
-	else								\
-		(head)->tqh_last = &(elm2)->field.tqe_next;		\
-	(elm2)->field.tqe_prev = (elm)->field.tqe_prev;			\
-	*(elm2)->field.tqe_prev = (elm2);				\
-} while (0)
-
-/*
- * Circular queue definitions.
- */
-#define CIRCLEQ_HEAD(name, type)					\
-struct name {								\
-	struct type *cqh_first;		/* first element */		\
-	struct type *cqh_last;		/* last element */		\
-}
-
-#define CIRCLEQ_HEAD_INITIALIZER(head)					\
-	{ CIRCLEQ_END(&head), CIRCLEQ_END(&head) }
-
-#define CIRCLEQ_ENTRY(type)						\
-struct {								\
-	struct type *cqe_next;		/* next element */		\
-	struct type *cqe_prev;		/* previous element */		\
-}
-
-/*
- * Circular queue access methods
- */
-#define	CIRCLEQ_FIRST(head)		((head)->cqh_first)
-#define	CIRCLEQ_LAST(head)		((head)->cqh_last)
-#define	CIRCLEQ_END(head)		((void *)(head))
-#define	CIRCLEQ_NEXT(elm, field)	((elm)->field.cqe_next)
-#define	CIRCLEQ_PREV(elm, field)	((elm)->field.cqe_prev)
-#define	CIRCLEQ_EMPTY(head)						\
-	(CIRCLEQ_FIRST(head) == CIRCLEQ_END(head))
-
-#define CIRCLEQ_FOREACH(var, head, field)				\
-	for((var) = CIRCLEQ_FIRST(head);				\
-	    (var) != CIRCLEQ_END(head);					\
-	    (var) = CIRCLEQ_NEXT(var, field))
-
-#define CIRCLEQ_FOREACH_REVERSE(var, head, field)			\
-	for((var) = CIRCLEQ_LAST(head);					\
-	    (var) != CIRCLEQ_END(head);					\
-	    (var) = CIRCLEQ_PREV(var, field))
-
-/*
- * Circular queue functions.
- */
-#define	CIRCLEQ_INIT(head) do {						\
-	(head)->cqh_first = CIRCLEQ_END(head);				\
-	(head)->cqh_last = CIRCLEQ_END(head);				\
-} while (0)
-
-#define CIRCLEQ_INSERT_AFTER(head, listelm, elm, field) do {		\
-	(elm)->field.cqe_next = (listelm)->field.cqe_next;		\
-	(elm)->field.cqe_prev = (listelm);				\
-	if ((listelm)->field.cqe_next == CIRCLEQ_END(head))		\
-		(head)->cqh_last = (elm);				\
-	else								\
-		(listelm)->field.cqe_next->field.cqe_prev = (elm);	\
-	(listelm)->field.cqe_next = (elm);				\
-} while (0)
-
-#define CIRCLEQ_INSERT_BEFORE(head, listelm, elm, field) do {		\
-	(elm)->field.cqe_next = (listelm);				\
-	(elm)->field.cqe_prev = (listelm)->field.cqe_prev;		\
-	if ((listelm)->field.cqe_prev == CIRCLEQ_END(head))		\
-		(head)->cqh_first = (elm);				\
-	else								\
-		(listelm)->field.cqe_prev->field.cqe_next = (elm);	\
-	(listelm)->field.cqe_prev = (elm);				\
-} while (0)
-
-#define CIRCLEQ_INSERT_HEAD(head, elm, field) do {			\
-	(elm)->field.cqe_next = (head)->cqh_first;			\
-	(elm)->field.cqe_prev = CIRCLEQ_END(head);			\
-	if ((head)->cqh_last == CIRCLEQ_END(head))			\
-		(head)->cqh_last = (elm);				\
-	else								\
-		(head)->cqh_first->field.cqe_prev = (elm);		\
-	(head)->cqh_first = (elm);					\
-} while (0)
-
-#define CIRCLEQ_INSERT_TAIL(head, elm, field) do {			\
-	(elm)->field.cqe_next = CIRCLEQ_END(head);			\
-	(elm)->field.cqe_prev = (head)->cqh_last;			\
-	if ((head)->cqh_first == CIRCLEQ_END(head))			\
-		(head)->cqh_first = (elm);				\
-	else								\
-		(head)->cqh_last->field.cqe_next = (elm);		\
-	(head)->cqh_last = (elm);					\
-} while (0)
-
-#define	CIRCLEQ_REMOVE(head, elm, field) do {				\
-	if ((elm)->field.cqe_next == CIRCLEQ_END(head))			\
-		(head)->cqh_last = (elm)->field.cqe_prev;		\
-	else								\
-		(elm)->field.cqe_next->field.cqe_prev =			\
-		    (elm)->field.cqe_prev;				\
-	if ((elm)->field.cqe_prev == CIRCLEQ_END(head))			\
-		(head)->cqh_first = (elm)->field.cqe_next;		\
-	else								\
-		(elm)->field.cqe_prev->field.cqe_next =			\
-		    (elm)->field.cqe_next;				\
-} while (0)
-
-#define CIRCLEQ_REPLACE(head, elm, elm2, field) do {			\
-	if (((elm2)->field.cqe_next = (elm)->field.cqe_next) ==		\
-	    CIRCLEQ_END(head))						\
-		(head).cqh_last = (elm2);				\
-	else								\
-		(elm2)->field.cqe_next->field.cqe_prev = (elm2);	\
-	if (((elm2)->field.cqe_prev = (elm)->field.cqe_prev) ==		\
-	    CIRCLEQ_END(head))						\
-		(head).cqh_first = (elm2);				\
-	else								\
-		(elm2)->field.cqe_prev->field.cqe_next = (elm2);	\
-} while (0)
-
-#endif	/* !_SYS_QUEUE_H_ */
diff --git a/static.c b/static.c
index 9f587af..ff4179b 100644
--- a/static.c
+++ b/static.c
@@ -41,8 +41,7 @@
 #include <errno.h>
 #include <err.h>
 
-#include "queue.h"
-#include "cfg.h"
+#include <conffile.h>
 #include "nfsidmap.h"
 #include "nfsidmap_internal.h"
 
@@ -317,7 +316,7 @@ static int static_init() {
 		LIST_INIT (&uid_mappings[i]);
 
 	//get all principals for which we have mappings
-	princ_list = conf_get_tag_list("Static");
+	princ_list = conf_get_tag_list("Static", NULL);
 
 	if (!princ_list) {
 		return -ENOENT;
diff --git a/umich_ldap.c b/umich_ldap.c
index 886fa0c..6e01cc3 100644
--- a/umich_ldap.c
+++ b/umich_ldap.c
@@ -48,7 +48,7 @@
 #include <ldap.h>
 #include "nfsidmap.h"
 #include "nfsidmap_internal.h"
-#include "cfg.h"
+#include <conffile.h>
 
 /* attribute/objectclass default mappings */
 #define DEFAULT_UMICH_OBJCLASS_REMOTE_PERSON	"NFSv4RemotePerson"
-- 
1.8.3.1



