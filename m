From: barry sabsevitz <barry_sabsevitz@yahoo.com>
Subject: Kerberos question related to NFSV3
Date: Wed, 13 May 2009 11:01:43 -0700 (PDT)
Message-ID: <392702.81064.qm@web43513.mail.sp1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from n69.bullet.mail.sp1.yahoo.com ([98.136.44.41]:26284 "HELO
	n69.bullet.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756803AbZEMSBm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 13 May 2009 14:01:42 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi, 
I have a question regarding NFSV3 and Kerberos that I was hoping someone could help me with.

I have setup Kerberos successfully on a red hat 5.2 system using NFSV3. I am using nfs-utils-1.1.6 and have a patch to rpc.svcgssd where I can specify a -h option and tell it to use a principal name that is different than the name of the system. 

My question is related to Kerberos and how it gets configured for NFS. I have a cluster with 2 nodes in it and each node can have multiple virtual ip addressess accessing NFS Kerberos shares from it. I have previously successfully setup a configuration where I create 1 service principal for every virtual IP address that will be processing the Kerberos NFSV3 exports. And then I modify DNS to have a forward and reverse mapping between the fqdn used for creating the service principal and the VIP.  This works for me. It seems a bit inefficient though.

 My question is: Does Kerberos allow me to set up 1 service principal that can be used at the same time by multiple virtual ip addresses. For example: If I have 2 VIP's - 10.1.1.1 and 10.1.1.2, can I create 1 service principal called nfs/nfs-pkg1.activedir.net-jPvyhR5Pr7e588XsNBc39w@public.gmane.org and then have DNS configured to map nfs-pkg1 -> 10.1.1.1  and nfs-pkg1 also to -> 10.1.1.2 and then both those VIP's reverse mapped to nfs-pkg1. Is Kerberos with NFS expected to work in this configuration? Or do I need to have a seperate service principal for every virtual ip address that will be processing the Kerberos NFS exports?

Thanks for your help.
Barry



      

