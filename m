Return-Path: linux-nfs-owner@vger.kernel.org
Received: from countercultured.net ([209.51.175.25]:33808 "HELO
	countercultured.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752254Ab2KUA31 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Nov 2012 19:29:27 -0500
Message-ID: <50AC2062.20907@davequigley.com>
Date: Tue, 20 Nov 2012 19:29:22 -0500
From: Dave Quigley <dpquigl@davequigley.com>
MIME-Version: 1.0
To: Casey Schaufler <casey@schaufler-ca.com>
CC: bfields@fieldses.org, trond.myklebust@netapp.com, sds@tycho.nsa.gov,
        linux-nfs@vger.kernel.org, selinux@tycho.nsa.gov,
        linux-security-module@vger.kernel.org
Subject: Re: Labeled NFS [v5]
References: <1352700947-3915-1-git-send-email-dpquigl@davequigley.com> <50ABF1A5.2010406@schaufler-ca.com> <50AC1A74.7080105@davequigley.com>
In-Reply-To: <50AC1A74.7080105@davequigley.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 From the spec file these are the BuildRequires statements. I'm trying 
to build an rpm for it right now. Should be done soon.

BuildRequires: libgssglue-devel libevent-devel libcap-devel
BuildRequires: libnfsidmap-devel libtirpc-devel libblkid-devel
BuildRequires: krb5-libs >= 1.4 autoconf >= 2.57 openldap-devel >= 2.2
BuildRequires: automake, libtool, glibc-headers, device-mapper-devel
BuildRequires: krb5-devel, tcp_wrappers-devel, libmount-devel

