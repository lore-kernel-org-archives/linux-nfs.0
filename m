Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:47351 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932180AbZLDQvM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Dec 2009 11:51:12 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1NGbNF-0001W6-1O
	for linux-nfs@vger.kernel.org; Sat, 05 Dec 2009 03:51:17 +1100
Date: Fri, 4 Dec 2009 16:50:34 +0000 (GMT)
From: Neil Hoggarth <neil.hoggarth@dpag.ox.ac.uk>
To: nfs@lists.sourceforge.net
Message-ID: <alpine.DEB.2.00.0912041615060.7612@pc-mike.dpag.ox.ac.uk>
Subject: [NFS] Sort order of exported "machine name formats"
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I find myself wanting to NFS export a filesystem to all the machines on 
a network with one set of export options, and to a restricted subset of 
machines on the same network with a slightly different set of options. I 
expected to be able to do this with an /etc/exports line something like 
this:

/export -rw,sync,fsid=0,sec=krb5 163.1.248.0/22 @trusted(sec=sys)

the intention being that any machine on the subnet can mount the 
filesystem, if they use Kerberos authentication, and the members of the 
netgroup "trusted" can opt to use AUTH_SYS rather than Kerberos.

However, it appears that the export lists in-core are always held in 
some sort of sorted order. No matter how the /etc/exports file is 
written, if a filesystem is exported to several different "machine name 
formats" then at mount request time the checks always seem to be done in 
the order: match against FQDN; match against IP addresses and IP ranges; 
match against wildcard hostnames; match match against netgroups; match 
"<world>". First positive match determines the NFS export parameters 
that the server applies to the

If the client matches both a subnet "name format" and is a member of a 
netgroup then the options set for the subnet always get applied to a 
mount request, and the client is never tested for membership of the 
netgroup. The same applies to clients that match both a wildcarded 
domain name and are also a member of a netgroup.

The relatively low position of netgroups in the pecking order means that 
they are far less useful than might otherwise be the case. If they were 
treated as ranking after FQDNs but before IP addresses then there would 
be a relatively easy way to express an access control rule of the form 
"all the machines in the organisation can access this resource with one 
set of options, and a subset of those machines get this alternative set 
of options".

As things stand, it looks to me as though the only way to implement the 
sort of rule that I want is to maintain two netgroups: the "trusted" 
one, and a manually maintained list of all the machines in the 
organisation that aren't on the "trusted" list?

Regards,
-- 
Neil Hoggarth -------------- Department of Physiology, Anatomy and Genetics
Head of IT --------------------------------------- University of Oxford, UK


------------------------------------------------------------------------------
Join us December 9, 2009 for the Red Hat Virtual Experience,
a free event focused on virtualization and cloud computing. 
Attend in-depth sessions from your desk. Your couch. Anywhere.
http://p.sf.net/sfu/redhat-sfdev2dev
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

