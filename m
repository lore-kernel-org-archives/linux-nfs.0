From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 0/3] nfs-utils: Enabling TCP wrappers Part 2
Date: Fri, 23 Jan 2009 12:59:10 -0500
Message-ID: <497A056E.1030606@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43734 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756783AbZAWSBf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jan 2009 13:01:35 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n0NI1Zdh031773
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2009 13:01:35 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n0NI1ZQ1005111
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2009 13:01:35 -0500
Received: from xenhat.boston.devel.redhat.com (vpn-10-54.bos.redhat.com [10.16.10.54])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n0NI1YX6001185
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2009 13:01:35 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that TCP wrapper are actually working as expected, it causing
problems in configuration that don't support reverse host name
lookups.

For TCP wrappers to actually work correctly, an IP address have to be
converted into host name, to cover the possibility that host names
are used in either the /etc/hosts.deny or /etc/hosts.allow files.
If that IP conversion (i.e. reverse hostname lookup) fails, the
mount has to failed otherwise it open up a security hole since
the host name can not be checked.

In smaller "at home" configurations, this failure cause a great deal
of pain since there will never any type of DNS services and for some
reasons (which were beyond me) adding the IP address to /etc/hosts
was not an option. So this patch set allows configurations like
those to, once again, just work, plus it also stop a needless lookup
when there are no tcp wrapper rules, which is %99.99 of the time.

Patch 01 - I was caching the results of the host access query using 
           the IP address, program number and produce number which 
           was creating too many cache entries for a single host.
           All that's really needed is to has on the the IP address
           and program number.

Patch 02 - This is a repost of a previous patch that will not
           do the host access checks if there are no rules in 
           either hosts.allow or hosts.deny. This version includes
           the suggestion from Chuck Lever that blank lines should 
           also be ignored.

Patch 03 - This patch adds a --insecure | -i command line argument that
           completely turns all of the host access checking. I was a bit
           hesitant about doing this, but once I saw other daemon having
           option I figured it would be good to have.

Comments/Issues?

steved.  

  
