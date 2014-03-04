Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f54.google.com ([74.125.83.54]:40885 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756329AbaCDHiS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Mar 2014 02:38:18 -0500
Received: by mail-ee0-f54.google.com with SMTP id d49so1264701eek.27
        for <linux-nfs@vger.kernel.org>; Mon, 03 Mar 2014 23:38:17 -0800 (PST)
From: Noam Meltzer <noam@primarydata.com>
To: noam@primarydata.com, linux-nfs@vger.kernel.org,
        sssd-devel@lists.fedorahosted.org
Subject: [PATCH v2 5/5] NFSv4 client: add to RPM spec
Date: Tue,  4 Mar 2014 09:37:56 +0200
Message-Id: <1393918676-20865-6-git-send-email-noam@primarydata.com>
In-Reply-To: <1393918676-20865-1-git-send-email-noam@primarydata.com>
References: <1393918676-20865-1-git-send-email-noam@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---
 contrib/sssd.spec.in | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/contrib/sssd.spec.in b/contrib/sssd.spec.in
index 055de4a..30ab9a5 100644
--- a/contrib/sssd.spec.in
+++ b/contrib/sssd.spec.in
@@ -138,6 +138,11 @@ BuildRequires: systemd-devel
 %if (0%{?with_cifs_utils_plugin} == 1)
 BuildRequires: cifs-utils-devel
 %endif
+%if ((0%{?fedora} >= 15) || (0%{?rhel} >= 7))
+BuildRequires: libnfsidmap-devel
+%else
+BuildRequires: nfs-utils-lib-devel
+%endif
 
 # RHEL 5 is too old to support samba4 and the PAC responder
 %if !0%{?is_rhel5}
@@ -418,6 +423,7 @@ autoreconf -ivf
     --with-krb5-rcache-dir=%{_localstatedir}/cache/krb5rcache \
     --enable-nsslibdir=/%{_lib} \
     --enable-pammoddir=/%{_lib}/security \
+    --enable-nfsidmaplibdir=%{_libdir}/libnfsidmap \
     --disable-static \
     --disable-rpath \
     %{?with_ccache} \
@@ -567,6 +573,7 @@ rm -rf $RPM_BUILD_ROOT
 # 3rd party application libraries
 %{_libdir}/sssd/modules/libsss_autofs.so
 %{_libdir}/libsss_sudo.so
+%{_libdir}/libnfsidmap/sss_nfs.so
 
 %{ldb_modulesdir}/memberof.so
 %{_bindir}/sss_ssh_authorizedkeys
@@ -597,6 +604,7 @@ rm -rf $RPM_BUILD_ROOT
 %{_mandir}/man5/sssd.conf.5*
 %{_mandir}/man5/sssd-simple.5*
 %{_mandir}/man5/sssd-sudo.5*
+%{_mandir}/man5/sss_rpcidmapd.5*
 %{_mandir}/man8/sssd.8*
 %{_mandir}/man8/sss_cache.8*
 %{_mandir}/man1/sss_ssh_authorizedkeys.1*
-- 
1.8.5.3

