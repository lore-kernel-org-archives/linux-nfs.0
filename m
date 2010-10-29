Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from blue.agorabox.fr ([91.121.20.208]:37848 "EHLO blue.yxes.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756364Ab0J2Iti (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Oct 2010 04:49:38 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by blue.yxes.fr (Postfix) with ESMTP id 8081017696E
	for <linux-nfs@vger.kernel.org>; Fri, 29 Oct 2010 10:40:04 +0200 (CEST)
Received: from blue.yxes.fr ([127.0.0.1])
	by localhost (blue.agorabox.fr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id fKfmVdppiuQo for <linux-nfs@vger.kernel.org>;
	Fri, 29 Oct 2010 10:40:03 +0200 (CEST)
Received: from hutsys.alpha.agorabox.org (unknown [132.227.168.7])
	(Authenticated sender: marc.schlinger@agorabox.org)
	by blue.yxes.fr (Postfix) with ESMTPA id C0E3417696C
	for <linux-nfs@vger.kernel.org>; Fri, 29 Oct 2010 10:40:03 +0200 (CEST)
Message-ID: <4CCA8863.6040505@agorabox.org>
Date: Fri, 29 Oct 2010 10:40:03 +0200
From: Marc Schlinger <marc.schlinger@agorabox.org>
To: linux-nfs@vger.kernel.org
Subject: rpc.gssd and proxiable/forwardable tickets.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Hello,

I'm using WebAuth to authenticate my user and provide them a mean to
join their NFSv4 files through a web page.
I'd  like to have the kerberos credentials used by the web server, but I
didn't managed to impersonate the kerberos user with nfsv4 in a webauth
protected page.
When I try to list the an nfs directory  from the webpage I've got this
error from rpc.gssd:

CC file '/tmp/krb5cc_500' is expired or corrupt

My distribution is Fedora 12 and i'm using nfs-utils 1.2.1.

WebAuth is configured to ask the client a forwardable ticket for
nfs/<mynfsserver>@<myrealm>. In my application's code I can see the
ticket and even do a klist with it. The output looks like this:

$ klist
Ticket cache: FILE:/tmp/krb5cc_500
Default principal: marc@<myrealm>

Valid starting     Expires            Service principal
10/28/10 20:15:17  10/29/10 20:15:15  nfs/<mynfsserver>@<myrealm>
     Flags: FAT

So my application never gets the krbtgt tickets. Considering security, I
believe this is a good point.

I must confess that I didn't manage to follow rpc.gssd process with gdb
or with ltrace.
So until I'm able to trace gssd execution all things that follows are
pure suppositions.


While trying to find a valid credential_cache gssd calls a function in
utils/krb5_utils.c, "check_for_tgt", that does this loop:

     while (!found&&   (ret = krb5_cc_next_cred(context, ccache,&cur,
&creds)) == 0) {
         if (creds.server->length == 2&&
                 data_is_equal(creds.server->realm, principal->realm)&&
                 creds.server->data[0].length == 6&&
->              memcmp(creds.server->data[0].data, "krbtgt", 6) == 0&&
                 data_is_equal(creds.server->data[1], principal->realm)&&
                 creds.times.endtime>   time(NULL))
             found = 1;
         krb5_free_cred_contents(context,&creds);
     }


What I understand is that without a krbtgt entry, a credential cache
will be considered invalid.

Is there some reasons for this?
For what I've understand about kerberos protocol, a proxiable or
forwardable service ticket is sufficient to communicate with the nfs
server. But I may be wrong.


Thanks for your help.

Marc Schlinger




