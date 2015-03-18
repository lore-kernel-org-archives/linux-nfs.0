Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kammerl.de ([176.28.8.19]:45590 "EHLO mail.kammerl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752041AbbCRWaM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Mar 2015 18:30:12 -0400
Received: from [192.168.42.36] (ppp-88-217-0-163.dynamic.mnet-online.de [88.217.0.163])
	(using TLSv1 with cipher ECDHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: robert@huitl.de)
	by mail.kammerl.de (Postfix) with ESMTPSA id 26EE4A033F
	for <linux-nfs@vger.kernel.org>; Wed, 18 Mar 2015 23:21:22 +0100 (CET)
Message-ID: <5509FA61.2060401@huitl.de>
Date: Wed, 18 Mar 2015 23:21:21 +0100
From: Robert Huitl <linux-nfs@huitl.de>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: rpc.gssd picks wrong credential cache file in multi-realm setup
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I have the following krb5.conf setup with two realms and an NFS4 server
at fileserver.ads.other.com@ADS.OTHER.COM:

[libdefaults]
        default_realm = ADS.DEFAULT.COM

[domain_realm]
        .ads.other.com = ADS.OTHER.COM


The two realms do not know of each other. Mounting the share works fine,
but the user is denied access if there are ticket caches for *both*
ADS.DEFAULT.COM and ADS.OTHER.COM:


handling gssd upcall (/run/rpc_pipefs/nfs/clnt19c)
handle_gssd_upcall: 'mech=krb5 uid=1000000 enctypes=18,17,16,23,3,1,2 '
handling krb5 upcall (/run/rpc_pipefs/nfs/clnt19c)
process_krb5_upcall: service is '<null>'
creating context using fsuid 1000000 (save_uid 0)
creating tcp client for server fileserver.ads.other.com
DEBUG: port already set to 2049
creating context with server nfs@fileserver.ads.other.com
WARNING: Failed to create krb5 context for user with uid 1000000 for
server fileserver.ads.other.com
getting credentials for client with uid 1000000 for server
fileserver.ads.other.com
CC '/tmp/krb5cc_1000000' being considered, with preferred realm
'ADS.DEFAULT.COM'
CC 'FILE:/tmp/krb5cc_1000000'(user@ADS.OTHER.COM) passed all checks and
has mtime of 1425824566
CC '/tmp/krb5cc_1000000_vg0rFX' being considered, with preferred realm
'ADS.DEFAULT.COM'
CC 'FILE:/tmp/krb5cc_1000000_vg0rFX'(user@ADS.DEFAULT.COM) passed all
checks and has mtime of 1425822978
CC '��@:/tmp/krb5cc_1000000_vg0rFX' is our current best match with mtime
of 1425822978
using FILE:/tmp/krb5cc_1000000_vg0rFX as credentials cache for client
with uid 1000000 for server fileserver.ads.other.com
using environment variable to select krb5 ccache
FILE:/tmp/krb5cc_1000000_vg0rFX
creating context using fsuid 1000000 (save_uid 0)
creating tcp client for server fileserver.ads.other.com
DEBUG: port already set to 2049
creating context with server nfs@fileserver.ads.other.com
WARNING: Failed to create krb5 context for user with uid 1000000 for
server fileserver.ads.other.com
getting credentials for client with uid 1000000 for server
fileserver.ads.other.com
WARNING: Failed to create krb5 context for user with uid 1000000 for
server fileserver.ads.other.com
doing error downcall


The problem is caused by gssd_setup_krb5_user_gss_ccache(uid,
servername, dirpattern) calling gssd_find_existing_krb5_ccache(uid,
dirname, &cctype, &d) which picks the wrong cache as it does not take
into account servername and will always pick the cache for preferred_realm.

My understanding of the code is limited, but it looks like caches for
the realm configured in [domain_realm] section of krb5.conf should take
precedence over preferred_realm. Other parts of the code like
find_keytab_entry() seem to be multi-realm-aware and use
krb5_get_host_realm() to locate a ticket.

As a workaround, running rpc.gssd -R ADS.OTHER.COM forces gssd to pick
the right cache, but that breaks access to ADS.DEFAULT.COM.

Note: this bug is also tracked as #94541 on Bugzilla.

Robert

