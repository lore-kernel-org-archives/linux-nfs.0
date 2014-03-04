Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f173.google.com ([209.85.215.173]:33060 "EHLO
	mail-ea0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756329AbaCDHiQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 02:38:16 -0500
Received: by mail-ea0-f173.google.com with SMTP id r15so136444ead.18
        for <linux-nfs@vger.kernel.org>; Mon, 03 Mar 2014 23:38:15 -0800 (PST)
From: Noam Meltzer <noam@primarydata.com>
To: noam@primarydata.com, linux-nfs@vger.kernel.org,
        sssd-devel@lists.fedorahosted.org
Subject: [PATCH v2 4/5] NFSv4 client: man page
Date: Tue,  4 Mar 2014 09:37:55 +0200
Message-Id: <1393918676-20865-5-git-send-email-noam@primarydata.com>
In-Reply-To: <1393918676-20865-1-git-send-email-noam@primarydata.com>
References: <1393918676-20865-1-git-send-email-noam@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---
 src/man/Makefile.am         |  4 +-
 src/man/include/seealso.xml |  4 ++
 src/man/sss_rpcidmapd.5.xml | 97 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 104 insertions(+), 1 deletion(-)
 create mode 100644 src/man/sss_rpcidmapd.5.xml

diff --git a/src/man/Makefile.am b/src/man/Makefile.am
index eb87980..97a1b66 100644
--- a/src/man/Makefile.am
+++ b/src/man/Makefile.am
@@ -42,7 +42,9 @@ man_MANS = \
     sssd.8 sssd.conf.5 sssd-ldap.5 \
     sssd-krb5.5 sssd-ipa.5 sssd-simple.5 sssd-ad.5 \
     sssd_krb5_locator_plugin.8 sss_groupshow.8 \
-    pam_sss.8 sss_obfuscate.8 sss_cache.8 sss_debuglevel.8 sss_seed.8
+    pam_sss.8 sss_obfuscate.8 sss_cache.8 sss_debuglevel.8 sss_seed.8 \
+    sss_rpcidmapd.5 \
+    $(NULL)
 
 if BUILD_SSH
 man_MANS += sss_ssh_authorizedkeys.1 sss_ssh_knownhostsproxy.1
diff --git a/src/man/include/seealso.xml b/src/man/include/seealso.xml
index 4f79431..ad6aaab 100644
--- a/src/man/include/seealso.xml
+++ b/src/man/include/seealso.xml
@@ -77,5 +77,9 @@
             <citerefentry>
                 <refentrytitle>pam_sss</refentrytitle><manvolnum>8</manvolnum>
             </citerefentry>.
+            <citerefentry>
+                <refentrytitle>sss_rpcidmapd</refentrytitle>
+                <manvolnum>5</manvolnum>
+            </citerefentry>
         </para>
     </refsect1>
diff --git a/src/man/sss_rpcidmapd.5.xml b/src/man/sss_rpcidmapd.5.xml
new file mode 100644
index 0000000..791870e
--- /dev/null
+++ b/src/man/sss_rpcidmapd.5.xml
@@ -0,0 +1,97 @@
+<?xml version="1.0" encoding="UTF-8"?>
+<!DOCTYPE reference PUBLIC "-//OASIS//DTD DocBook V4.4//EN"
+"http://www.oasis-open.org/docbook/xml/4.4/docbookx.dtd">
+<reference>
+<title>SSSD Manual pages</title>
+<refentry>
+    <refentryinfo>
+        <productname>sss_nfs</productname>
+        <orgname>Noam Meltzer, Primary Data Inc. - noam@primarydata.com</orgname>
+    </refentryinfo>
+
+    <refmeta>
+        <refentrytitle>sss_rpcidmapd</refentrytitle>
+        <manvolnum>5</manvolnum>
+        <refmiscinfo class="manual">File Formats and Conventions</refmiscinfo>
+    </refmeta>
+
+    <refnamediv id='name'>
+        <refname>sss_rpcidmapd</refname>
+        <refpurpose>sss_nfs plugin configuration directives for rpc.idmapd</refpurpose>
+    </refnamediv>
+
+    <refsect1 id='conf-file'>
+        <title>CONFIGURATION FILE</title>
+        <para>
+            rpc.idmapd configuration file is usually found at
+            <emphasis>/etc/idmapd.conf</emphasis>. See
+            <citerefentry>
+                <refentrytitle>idmapd.conf</refentrytitle>
+                <manvolnum>5</manvolnum>
+            </citerefentry> for more information.
+        </para>
+    </refsect1>
+
+    <refsect1 id='sss-conf-extension'>
+        <title>SSS CONFIGURATION EXTENSION</title>
+        <refsect2 id='enable-sss'>
+            <title>Enable SSS plugin</title>
+            <para>
+                In section <quote>[Translation]</quote>, modify/set
+                <quote>Method</quote> attribute to contain
+                <emphasis>sss_nfs</emphasis>.
+            </para>
+        </refsect2>
+        <refsect2 id='sss_nfs-conf-sect'>
+            <title>[sss_nfs] config section</title>
+            <para>
+                In order to change the default of one of the configuration
+                attributes of the <emphasis>sss_nfs</emphasis> plugin listed
+                below you will need to create a config section for it, named
+                <quote>[sss_nfs]</quote>.
+            </para>
+            <variablelist>
+                <title>Configuration attributes</title>
+                <varlistentry>
+                    <term>memcache (bool)</term>
+                    <listitem>
+                        <para>
+                            Indicates whether or not to use memcache
+                            optimisation technique.
+                        </para>
+                        <para>
+                            Default: True
+                        </para>
+                    </listitem>
+                </varlistentry>
+            </variablelist>
+        </refsect2>
+    </refsect1>
+
+    <refsect1 id='sssd-integration'>
+        <title>SSSD INTEGRATION</title>
+        <para>
+            The sss_nfs plugin requires the <emphasis>NSS Responder</emphasis>
+            to be enabled in sssd.
+        </para>
+        <para>
+            The attribute <quote>use_fully_qualified_names</quote> must be
+            enabled on all domains (NFSv4 clients expect a fully qualified name
+            to be sent on the wire).
+        </para>
+    </refsect1>
+
+    <refsect1 id='see_also'>
+        <title>SEE ALSO</title>
+        <para>
+            <citerefentry>
+                <refentrytitle>sssd</refentrytitle><manvolnum>8</manvolnum>
+            </citerefentry>,
+            <citerefentry>
+                <refentrytitle>idmapd.conf</refentrytitle>
+                <manvolnum>5</manvolnum>
+            </citerefentry>
+        </para>
+    </refsect1>
+</refentry>
+</reference>
-- 
1.8.5.3

