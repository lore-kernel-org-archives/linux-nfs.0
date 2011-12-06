Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26337 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752227Ab1LFTCB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Dec 2011 14:02:01 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id pB6J20CW006138
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 6 Dec 2011 14:02:00 -0500
Received: from badhat.bos.devel.redhat.com (badhat.boston.devel.redhat.com [10.16.60.49])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id pB6J20FV012549
	for <linux-nfs@vger.kernel.org>; Tue, 6 Dec 2011 14:02:00 -0500
Message-ID: <4EDE66A7.30901@RedHat.com>
Date: Tue, 06 Dec 2011 14:01:59 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: (Updated) libnfsidmap-0.25 is available
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[This time with the correct link ]

A new version of libnfsidmap is now available from
http://www.citi.umich.edu/projects/nfsv4/linux/libnfsidmap/libnfsidmap-0.25.tar.gz

Changes since libnfsidmap-0.24

commit 0c1766af5bf125a56fbf589111aa2f3876a5d709
Author: Steve Dickson <steved@redhat.com>
Date:   Sat Nov 12 10:19:52 2011 -0500

    nss_getpwnam: ignore case when comparing domain names
    
    nss_getpwnam() fails to find the password entry when the
    DNS domain name has both upper and lower characters,
    which is wrong. Case need to be ignored when comparing
    domain names.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit d9f2fcd93e033b8a5d4a56ddd6c7d316fdd8516d
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Mar 7 10:57:44 2011 -0500

    rpc.idmapd fails to load plugings
    
    Due to commit 9acc85db,  PATH_PLUGINS becomes redefined when the
    --with-pluginpath configuration flag is used due to a
    Makefile.ac rule.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 8752edac80a250095dc920a5a5c3bedc4cbeeb4b
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jan 14 10:43:53 2011 -0500

    Cleaned up some warnings
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 634debd8f180004108b874d271f6c6246b62d411
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jan 14 10:25:26 2011 -0500

    Ignoring more files.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 9ed53a42a93095deb84c22155a6e346851a11c8f
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jan 14 10:18:33 2011 -0500

    Improve debugging during lib initialization.
    
    Removed unnecessary new lines and dded debug code that
    displays what Realms will be used.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

commit 9acc85db7d15a12cb50db98f614b2340e856373c
Author: Steve Dickson <steved@redhat.com>
Date:   Wed Dec 22 13:58:17 2010 -0500

    Added new --with-pluginpath configuration flag
    
    Added new configuration flage so the plugin path
    can be redefined when the library is built.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

steved.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
