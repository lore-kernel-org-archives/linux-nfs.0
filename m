From: Eugene <hdejin@yahoo.com>
Subject: nfs-utils-1.0.8-rc2: Makefile DESTDIR problem (patch)
Date: Wed, 4 Jan 2006 07:24:58 -0800 (PST)
Message-ID: <20060104152458.77638.qmail@web50211.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EuAVh-00013Z-02
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 07:25:09 -0800
Received: from web50211.mail.yahoo.com ([206.190.39.175])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EuAVc-0005KI-Tl
	for nfs@lists.sourceforge.net; Wed, 04 Jan 2006 07:25:09 -0800
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Sorry, the attachment didn't go thru earlier.

~~BEGIN PATCH~~
--- nfs-utils-1.0.8-rc2.orig/Makefile.am	2006-01-04
20:31:07.000000000 +0800
+++ nfs-utils-1.0.8-rc2/Makefile.am	2006-01-04
20:36:28.000000000 +0800
@@ -40,11 +40,11 @@
 	aclocal/tcp-wrappers.m4
=20
 install-data-hook:
-	if [ ! -d $(statedir) ]; then mkdir -p $(statedir);
fi
-	touch $(statedir)/xtab; chmod 644 $(statedir)/xtab
-	touch $(statedir)/etab; chmod 644 $(statedir)/etab
-	touch $(statedir)/rmtab; chmod 644 $(statedir)/rmtab
-	mkdir -p $(statedir)/sm $(statedir)/sm.bak
-	touch $(statedir)/state
-	chmod go-rwx $(statedir)/sm $(statedir)/sm.bak
$(statedir)/state
-	chown $(statduser) $(statedir)/sm $(statedir)/sm.bak
$(statedir)/state
+	if [ ! -d $(DESTDIR)/$(statedir) ]; then mkdir -p=20
$(DESTDIR)/$(statedir); fi
+	touch  $(DESTDIR)/$(statedir)/xtab; chmod 644=20
$(DESTDIR)/$(statedir)/xtab
+	touch  $(DESTDIR)/$(statedir)/etab; chmod 644=20
$(DESTDIR)/$(statedir)/etab
+	touch  $(DESTDIR)/$(statedir)/rmtab; chmod 644=20
$(DESTDIR)/$(statedir)/rmtab
+	mkdir -p  $(DESTDIR)/$(statedir)/sm=20
$(DESTDIR)/$(statedir)/sm.bak
+	touch  $(DESTDIR)/$(statedir)/state
+	chmod go-rwx  $(DESTDIR)/$(statedir)/sm=20
$(DESTDIR)/$(statedir)/sm.bak=20
$(DESTDIR)/$(statedir)/state
+	chown  $(statduser)  $(DESTDIR)/$(statedir)/sm=20
$(DESTDIR)/$(statedir)/sm.bak=20
$(DESTDIR)/$(statedir)/state
~~ END PATCH ~~



	=09
__________________________________________=20
Yahoo! DSL =96 Something to write home about.=20
Just $16.99/mo. or less.=20
dsl.yahoo.com=20



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log fi=
les
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=3D7637&alloc_id=3D16865&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
