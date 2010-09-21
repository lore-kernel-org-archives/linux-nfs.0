Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from vergina.eng.auth.gr ([155.207.18.1]:52432 "EHLO
	vergina.eng.auth.gr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753029Ab0IUOTO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Sep 2010 10:19:14 -0400
Received: from mamalacation.ee.auth.gr (mamalacation.ee.auth.gr [155.207.33.29])
	by vergina.eng.auth.gr (8.14.3/8.14.1) with ESMTP id o8LEJCxc074452
	for <linux-nfs@vger.kernel.org>; Tue, 21 Sep 2010 17:19:12 +0300 (EEST)
	(envelope-from mamalos@eng.auth.gr)
Message-ID: <4C98BEDB.4050500@eng.auth.gr>
Date: Tue, 21 Sep 2010 17:19:07 +0300
From: George Mamalakis <mamalos@eng.auth.gr>
To: linux-nfs@vger.kernel.org
Subject: Re: nfsv3 gssapi client?
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

  I did some more testing, so I run a new kdc (heimdal again) on the 
fbsd server (just to eliminate one candidate from my problematic-boxes); 
this one is from the fbsd base system (the previous one was from ports), 
and the version is 1.1.0. I init'd my realm, and changed the 
/etc/krb.conf files on server and client to reflect my new kerberos 
implementation.

When I tried to mount the remote share using sec=krb5, gssd segfaulted 
again; I was on the exact place as before. Then I started deleting 
encryption types from the keytab (using kadmin and del_enctype) to see 
if this would help, until only one encryption type was left 
(des3-cbc-sha1), but gssd segfaulted repeatedly. Two funny things that I 
noticed:

1) when I del_enctype'd des3-cbc-sha1 and tried to kinit -t keytab -k 
host/linclient on the linuxbox I got the error:
[root@linuxclient ]# kinit -t keytab -k host/linclient
kinit: krb5_get_init_creds: Looping 11 times while getting initial 
credentials
[root@linuxclient ]#

and on the server tail /var/heimdal/kdc.log showed:

2010-09-21T16:26:36 AS-REQ host/linclient@EXAMPLE from 
IPv4:192.168.0.235 for krbtgt/EXAMPLE@EXAMPLE
2010-09-21T16:26:36 No preauth found, returning PREAUTH-REQUIRED -- 
host/linclient@EXAMPLE
2010-09-21T16:26:36 AS-REQ host/linclient@EXAMPLE from 
IPv4:192.168.0.235 for krbtgt/EXAMPLE@EXAMPLE
2010-09-21T16:26:36 No preauth found, returning PREAUTH-REQUIRED -- 
host/linclient@EXAMPLE
2010-09-21T16:26:36 AS-REQ host/linclient@EXAMPLE from 
IPv4:192.168.0.235 for krbtgt/EXAMPLE@EXAMPLE
2010-09-21T16:26:36 No preauth found, returning PREAUTH-REQUIRED -- 
host/linclient@EXAMPLE
2010-09-21T16:26:36 AS-REQ host/linclient@EXAMPLE from 
IPv4:192.168.0.235 for krbtgt/EXAMPLE@EXAMPLE
2010-09-21T16:26:36 No preauth found, returning PREAUTH-REQUIRED -- 
host/linclient@EXAMPLE
2010-09-21T16:26:36 AS-REQ host/linclient@EXAMPLE from 
IPv4:192.168.0.235 for krbtgt/EXAMPLE@EXAMPLE
2010-09-21T16:26:36 No preauth found, returning PREAUTH-REQUIRED -- 
host/linclient@EXAMPLE
2010-09-21T16:26:36 AS-REQ host/linclient@EXAMPLE from 
IPv4:192.168.0.235 for krbtgt/EXAMPLE@EXAMPLE
2010-09-21T16:26:36 No preauth found, returning PREAUTH-REQUIRED -- 
host/linclient@EXAMPLE
2010-09-21T16:26:36 AS-REQ host/linclient@EXAMPLE from 
IPv4:192.168.0.235 for krbtgt/EXAMPLE@EXAMPLE
2010-09-21T16:26:36 No preauth found, returning PREAUTH-REQUIRED -- 
host/linclient@EXAMPLE
2010-09-21T16:26:36 AS-REQ host/linclient@EXAMPLE from 
IPv4:192.168.0.235 for krbtgt/EXAMPLE@EXAMPLE
2010-09-21T16:26:36 No preauth found, returning PREAUTH-REQUIRED -- 
host/linclient@EXAMPLE
2010-09-21T16:26:36 AS-REQ host/linclient@EXAMPLE from 
IPv4:192.168.0.235 for krbtgt/EXAMPLE@EXAMPLE
2010-09-21T16:26:36 No preauth found, returning PREAUTH-REQUIRED -- 
host/linclient@EXAMPLE
2010-09-21T16:26:36 AS-REQ host/linclient@EXAMPLE from 
IPv4:192.168.0.235 for krbtgt/EXAMPLE@EXAMPLE
2010-09-21T16:26:36 No preauth found, returning PREAUTH-REQUIRED -- 
host/linclient@EXAMPLE
2010-09-21T16:26:36 AS-REQ host/linclient@EXAMPLE from 
IPv4:192.168.0.235 for krbtgt/EXAMPLE@EXAMPLE
2010-09-21T16:26:36 No preauth found, returning PREAUTH-REQUIRED -- 
host/linclient@EXAMPLE

which means that there is
a) some strange "incompatibility" issue with the keytabs provided by 
fbsd's heimdal version and the one that linux ships with.
b) the way linux kinit renders a keytab file becomes "problematic" when 
des3-cbc-sha1 is absent (on fbsd kinit worked fine with the same 
keytab). Haven't setup a linux heimdal server (yet...) to clear this.
but this is a complete different discussion.

The thing is that gssd creates it's krb5 cache in /tmp without any 
issues, and dies only after trying to "create context with the server". 
This is illustrated below, where gssd is run manually with verbose flags:

destroying client /var/lib/nfs/rpc_pipefs/nfs/clnt49
handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt4b)
handle_gssd_upcall: 'mech=krb5 uid=0 enctypes=18,17,16,23,3,1,2 '
handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfs/clnt4b)
process_krb5_upcall: service is '<null>'
Full hostname for 'filesrv' is 'filesrv'
Full hostname for 'linclient' is 'linclient'
Failed to find root/linclient@EXAMPLE in keytab FILE:/etc/krb5.keytab 
(null) while getting keytab entry for 'root/linclient@EXAMPLE'
Failed to find nfs/linclient@EXAMPLE in keytab FILE:/etc/krb5.keytab 
(null) while getting keytab entry for 'nfs/linclient@EXAMPLE'
Success getting keytab entry for 'host/linclient@EXAMPLE'
Successfully obtained machine credentials for principal 
'host/linclient@EXAMPLE' stored in ccache 'FILE:/tmp/krb5cc_machine_EXAMPLE'
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_EXAMPLE' are good 
until 1285112422
using FILE:/tmp/krb5cc_machine_EXAMPLE as credentials cache for machine 
creds
using gss_krb5_ccache_name to select krb5 ccache 
FILE:/tmp/krb5cc_machine_EXAMPLE
creating context using fsuid 0 (save_uid 0)
creating tcp client for server filesrv
DEBUG: port already set to 2049
creating context with server nfs@filesrv
Segmentation fault

The cache in /tmp/krb5cc_machine_EXAMPLE file is ok, since I am able to 
klist -c /tmp/krb5cc_machine_EXAMPLE and read its content. The problem 
comes after that step, when the client tries to find available 
mechanisms (stated in my last email).

2) The second funny thing was that when I searched the list for relevant 
problems I found a mail I had sent on the 5th March 2010, where I was 
facing some analogous problems, only this time with nfsv4 and a solaris 
nfs server. The subject was "mount.nfs4: Broken pipe", and from my 
"investigation" that far, I saw that there had to be a mix with MIT and 
heimdal on arch-linux. I think that this must be the case now, since 
when I read /etc/gssapi_mech.conf, I realized that it discussed about 
MIT kerberos5, and /usr/lib/libgssapi.so must be relevant to MIT too. 
But pacman -Qo /usr/lib/libgssapi.so showed that it is installed by 
heimdal 1.3.3-1...

...I don't know, I am confused! Is there a config 
(/etc/conf.d/nfs-common.conf, relevant packages, etc.) with which 
someone is able to mount nfsv3 shares using sec=krb5? If anyone is able 
to shed some light, it would be reaaally helpful.

Regards,

mamalos

-- 
George Mamalakis

IT Officer
Electrical and Computer Engineer (Aristotle Un. of Thessaloniki),
MSc (Imperial College of London)

Department of Electrical and Computer Engineering
Faculty of Engineering
Aristotle University of Thessaloniki

phone number : +30 (2310) 994379




