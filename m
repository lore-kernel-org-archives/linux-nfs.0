Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29076 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755239Ab0I0LNs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 07:13:48 -0400
Message-ID: <4CA07C67.2060201@RedHat.com>
Date: Mon, 27 Sep 2010 07:13:43 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Eberhard Kuemmerle <E.Kuemmerle@fz-juelich.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: Patch proposal for svcgssd
References: <201009271029.43607.E.Kuemmerle@fz-juelich.de>
In-Reply-To: <201009271029.43607.E.Kuemmerle@fz-juelich.de>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 09/27/2010 04:29 AM, Eberhard Kuemmerle wrote:
> Hello,
> 
> we use a two-node cluster (pacemaker, corosync, drbd) as nfs-server.
> We configured a virtual cluster-IP (using ocf::heartbeat:IPaddr2, iptables CLUSTERIP),
> i.e. the nfs clients call the server as OurClusterIP.OurDomain.de while the real hostnames of the servers are
> OurServer1.OurDomain.de and OurServer2.OurDomain.de.
> 
> If I tried to use the mount option krb5, svcgssd denied the mount with the message:
> ERROR: GSS-API: error in handle_nullreq: gss_accept_sec_context(): Unspecified GSS failure.  Minor code may provide more information - Wrong principal in request
> 
> I patched svcgssd that we can specify the principal to use as an option:
> svcgssd -p nfs/OurClusterIP.OurDomain.de
> 
> Now, krb5 works fine!
> 
> I suggest to include that patch in the main line of nfs-utils to enable the use of krb5 with such virtual IP's.
> The small patch is appended to the mail.
This looks like a reasonable idea... but a couple of nits...

1) There needs to be an update to the man page, in a separate patch, preferably.

2) Please don't make the patch an email attachment, inline it in
   email. See http://www.kernel.org/pub/linux/docs/lkml/#s1-10
   for details.

3) Please add the 'Signed-off-by:' line after your patch description.

Note, in the next day or so I will be doing nfs-utils release.
If you are interested in having this patch included please repost 
it in a timely matter... 

tia,

steved.

> 
> Best regards
>   Eberhard Kuemmerle
> 
> ------------------------------------------------------------------------------------------------
> ------------------------------------------------------------------------------------------------
> Forschungszentrum Juelich GmbH
> 52425 Juelich
> Sitz der Gesellschaft: Juelich
> Eingetragen im Handelsregister des Amtsgerichts Dueren Nr. HR B 3498
> Vorsitzender des Aufsichtsrats: MinDirig Dr. Karl Eugen Huthmacher
> Geschaeftsfuehrung: Prof. Dr. Achim Bachem (Vorsitzender),
> Dr. Ulrich Krafft (stellv. Vorsitzender), Prof. Dr.-Ing. Harald Bolt,
> Prof. Dr. Sebastian M. Schmidt
> ------------------------------------------------------------------------------------------------
> ------------------------------------------------------------------------------------------------
